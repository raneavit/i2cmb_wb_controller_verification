package wb_pkg;
  import ncsu_pkg::*;

  parameter int WB_ADDR_WIDTH = 2;
  parameter int WB_DATA_WIDTH = 8;

  parameter logic [1:0] CSR = 2'b00;
  parameter logic [1:0] DPR = 2'b01;
  parameter logic [1:0] CMDR = 2'b10;
  parameter logic [1:0] FSMR = 2'b11;

  typedef enum {WB_WRITE, WB_READ, WB_INVALID} wb_op_t;

  `include "../../ncsu_pkg/ncsu_macros.svh"
  `include "src/wb_transaction.svh"
  `include "src/wb_transaction_random.svh"
  `include "src/wb_configuration.svh"
  `include "src/wb_driver.svh"
  `include "src/wb_monitor.svh"
  `include "src/wb_agent.svh"
  
endpackage