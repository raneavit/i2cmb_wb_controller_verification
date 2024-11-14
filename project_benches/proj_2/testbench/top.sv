`timescale 1ns / 10ps

module top();

import ncsu_pkg::*;
import wb_pkg::*;
import i2c_pkg::*;
import i2cmb_env_pkg::*;

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
tri  [NUM_I2C_BUSES-1:0] scl;
triand  [NUM_I2C_BUSES-1:0] sda;


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

//Assign statements
assign interrup_from_dut = irq;

//Class handles
// ****************************************************************************
i2cmb_test test;
// ****************************************************************************

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
  .irq_i(irq),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
//Instantiate the I2C BUs Functional Model
i2c_if #(.ADDR_WIDTH(I2C_ADDR_WIDTH),
      .DATA_WIDTH(I2C_DATA_WIDTH),
      .SLAVE_ADDR(I2C_SLAVE_ADDRESS))
i2c_bus (.scl_i(scl), .sda_i(sda), .scl_o(scl), .sda_o(sda));

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSES)) DUT
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
// Define the flow of the simulation
initial begin: test_flow
  ncsu_config_db#(virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH)))::set("i2c_interface", i2c_bus);
  ncsu_config_db#(virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)))::set("wb_interface", wb_bus);

  test = new("test", null);
  wait(rst == 1'b0);
  test.run();
  #500 $finish;
  end

endmodule
