`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 6;

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
tri  [NUM_I2C_BUSSES-1:0] sda;

//My variables
// ****************************************************************************
typedef struct {
  bit [WB_ADDR_WIDTH-1:0] addr;
  bit [WB_DATA_WIDTH-1:0] data;
  bit we;
} wb_transfer;

wb_transfer transfer1;

wire interrup_from_dut;
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
    $display("Observed WB transaction: Address=%0d, Data=%0d, WE=%0d", transfer1.addr, transfer1.data, transfer1.we);
    end
  end

//Assign statements
assign interrup_from_dut = irq;


// ****************************************************************************
// Define the flow of the simulation
initial begin: test_flow
    
  //Enable core and interrupt
  wb_bus.master_write(2'b00, 8'b11xxxxxx);
  //wb_bus.master_write(2'b00, 8'bx1xxxxxx);

  wb_bus.master_write(2'b01, 8'b00000101);
  wb_bus.master_write(2'b10, 8'bxxxxx110);

  wait(interrup_from_dut == 1'b1);

  wb_bus.master_write(2'b10, 8'bxxxxx100);

  wait(interrup_from_dut == 1'b1);

  wb_bus.master_write(2'b01, 8'b01000100);
  wb_bus.master_write(2'b10, 8'bxxxxx001);

  wait(interrup_from_dut == 1'b1);

  wb_bus.master_write(2'b01, 8'b01111000);
  wb_bus.master_write(2'b10, 8'bxxxxx001);

  wait(interrup_from_dut == 1'b1);

  wb_bus.master_write(2'b01, 8'bxxxxx101);

  wait(interrup_from_dut == 1'b1);

       
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


endmodule
