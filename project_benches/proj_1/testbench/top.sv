`timescale 1ns / 10ps
import i2c_pkg::*;

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;
parameter int I2C_SLAVE_ADDR = 7'h22; //remember to change it and try different addresses in top.sv as well as here
parameter int NUM_I2C_BUSSES = 1;

parameter logic [1:0] CSR = 2'b00;
parameter logic [1:0] DPR = 2'b01;
parameter logic [1:0] CMDR = 2'b10;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
triand  [NUM_I2C_BUSSES-1:0] sda;


//My variables
// ****************************************************************************
typedef struct {
  bit [WB_ADDR_WIDTH-1:0] addr;
  bit [WB_DATA_WIDTH-1:0] data;
  bit we;
} wb_transfer;

wb_transfer transfer1;

wire interrup_from_dut;

bit [WB_DATA_WIDTH-1:0] wb_read_data;
bit [WB_DATA_WIDTH-1:0] wb_read_data_arr_1 [];
bit [WB_DATA_WIDTH-1:0] wb_read_data_arr_2 [];
bit [I2C_DATA_WIDTH-1:0] i2c_write_data [];
bit is_transfer_complete;

bit [I2C_ADDR_WIDTH-1:0] i2c_monitor_addr;
bit [I2C_DATA_WIDTH-1:0] i2c_monitor_data [];

// ****************************************************************************

// ****************************************************************************
// Clock generator
  initial begin: clk_gen
    clk = 1'b0;
    forever #10 clk = ~clk; // Toggle the clock every 10ns
  end

// ****************************************************************************
// Reset generator
  initial begin: rst_gen
    rst = 1'b1; // Assert reset
    #113 rst = 1'b0; // De-assert reset after 10 time units
  end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
  initial begin: wb_monitoring
    forever @(posedge we or negedge we)begin
    wb_bus.master_monitor(transfer1.addr, transfer1.data, transfer1.we);
    // $display("Observed WB transaction: Address=%0d, Data=%0d, WE=%0d", transfer1.addr, transfer1.data, transfer1.we);
    end
  end

//Assign statements
assign interrup_from_dut = irq;


// ****************************************************************************
// Define the flow of the simulation
initial begin: test_flow
    
  //Enable core and interrupt
  wb_bus.master_write(CSR, 8'b11xxxxxx);

  //********** Test 1 *****************
  $display("Initiating I2C Write of incrementing values 0-31 to Slave Address %0h",8'h22);
  wb_send_start_condition(8'h00);
  wb_address(8'h22, 1'b0);
  for(int i = 0; i < 32; i++ ) wb_write_data(i);
  wb_send_stop_condition();
  //***********************************

  //********** Test 2 *****************
  wb_send_start_condition(8'h00);
  wb_address(8'h22, 1'b1);
  $display("Initiating I2C Read of incrementing values 100-131 from Slave Address %0h",8'h22);
  for(int i = 0; i < 31; i++ )begin
    wb_ack(); //acks
    wb_dpr_read();
  end

  wb_nack(); //nacks
  wb_dpr_read();
  wb_send_stop_condition();
  //***********************************

  //********** Test 3 *****************
  for(int i = 0; i < 64; i++ ) begin
    wb_send_start_condition(8'h00);
    $display("Initiating I2C Write of Data %0d to Slave Address %0h", (64 + i), 8'h22);
    wb_address(8'h22, 1'b0);
    wb_write_data(64 + i);
    wb_send_start_condition(8'h00);
    $display("Initiating I2C Read of Data %0d from Slave Address %0h", (63 - i), 8'h22);
    wb_address(8'h22, 1'b1);
    wb_nack(); //nacks
    wb_dpr_read();
  end
  wb_send_stop_condition();
  #500 $finish;

  //***********************************
  end

  initial begin: i2c_handler
    i2c_bus.sda_en = 1'b0;
    //Initialize Arrays
    wb_read_data_arr_1 = new[32];
    for(int i = 0; i < 32; i++) begin
      wb_read_data_arr_1[i] = i + 100;
    end

    wb_read_data_arr_2 = new[1];

    //Test 1
    i2c_bus.wait_for_i2c_transfer(i2c_bus.i2_op, i2c_write_data);

    //Test 2
    i2c_bus.wait_for_i2c_transfer(i2c_bus.i2_op, i2c_write_data);
    if(i2c_bus.i2_op == READ) i2c_bus.provide_read_data(wb_read_data_arr_1, is_transfer_complete);

    //Test 3
    for(int i = 0; i < 64; i++ ) begin
      wb_read_data_arr_2[0] = 63-i;
      i2c_bus.wait_for_i2c_transfer(i2c_bus.i2_op, i2c_write_data);
      // if(i2c_bus.i2_op == READ) i2c_bus.provide_read_data(wb_read_data_arr_2, is_transfer_complete);
      i2c_bus.wait_for_i2c_transfer(i2c_bus.i2_op, i2c_write_data);
      if(i2c_bus.i2_op == READ) i2c_bus.provide_read_data(wb_read_data_arr_2, is_transfer_complete);
    end

  end

  initial begin: i2c_monitoring
    forever begin
      #5 i2c_bus.monitor(i2c_monitor_addr, i2c_bus.i2c_monitor_op, i2c_monitor_data);
      if(i2c_bus.i2c_monitor_op == READ) begin
        $display("---------------------------------");
        $display("I2C_BUS READ Transfer :: Slave Address: %0h  :: Data: %p",i2c_monitor_addr, i2c_monitor_data );
        $display("---------------------------------");
      end

      else if(i2c_bus.i2c_monitor_op == WRITE) begin
        $display("---------------------------------");
        $display("I2C_BUS WRITE Transfer :: Slave Address: %0h  :: Data: %p",i2c_monitor_addr, i2c_monitor_data );
        $display("---------------------------------");
      end
    end
  end

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
//Instantiate the I2C BUs Functional Model
i2c_if #(.ADDR_WIDTH(I2C_ADDR_WIDTH),
      .DATA_WIDTH(I2C_DATA_WIDTH),
      .SLAVE_ADDR(I2C_SLAVE_ADDR))
i2c_bus (.scl_i(scl), .sda_i(sda), .scl_o(scl), .sda_o(sda));

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


task wb_send_start_condition (input logic [7:0] bus_id);      
  wb_bus.master_write(DPR, bus_id); //ID of Desired Bus
  wb_bus.master_write(CMDR, 8'bxxxxx110); //Set Bus cmd
  wait(interrup_from_dut == 1'b1);
  wb_bus.master_read(CMDR, wb_read_data);
  wb_bus.master_write(CMDR, 8'bxxxxx100); // Start Command
  wait(interrup_from_dut == 1'b1);
  wb_bus.master_read(CMDR, wb_read_data); 
endtask

task wb_send_stop_condition ();     
  wb_bus.master_write(CMDR, 8'bxxxxx101);
  wait(interrup_from_dut == 1'b1);
  wb_bus.master_read(CMDR, wb_read_data); 
endtask


task wb_address (input logic [I2C_DATA_WIDTH-1:0] address, input bit wbar);    
  wb_bus.master_write(DPR, ((address << 1) | wbar));
  wb_bus.master_write(CMDR, 8'bxxxxx001);
  wait(interrup_from_dut == 1'b1);
  wb_bus.master_read(CMDR, wb_read_data);  
endtask

task wb_write_data (input logic [WB_DATA_WIDTH-1:0] data);      
  wb_bus.master_write(DPR, data);
  wb_bus.master_write(CMDR, 8'bxxxxx001);
  wait(interrup_from_dut == 1'b1);
  wb_bus.master_read(CMDR, wb_read_data);  
endtask

task wb_ack ();
  wb_bus.master_write(CMDR, 8'bxxxxx010); //acks
  wait(interrup_from_dut == 1'b1);
  wb_bus.master_read(CMDR, wb_read_data); 
endtask

task wb_nack ();
  wb_bus.master_write(CMDR, 8'bxxxxx011); //nacks
  wait(interrup_from_dut == 1'b1);
  wb_bus.master_read(CMDR, wb_read_data); 
endtask

task wb_dpr_read();
  wb_bus.master_read(DPR, wb_read_data);
  // $display("Data received from slave %0d", wb_read_data) ;
endtask


endmodule
