package i2c_pkg;
  import ncsu_pkg::*;

  parameter int I2C_ADDR_WIDTH = 7;
  parameter int I2C_DATA_WIDTH = 8;
  parameter int I2C_SLAVE_ADDRESS = 7'h22;

  parameter int NUM_I2C_BUSES = 1;

  parameter int BUS_ID = 0;

  typedef enum {I2C_WRITE, I2C_READ, I2C_INVALID} i2c_op_t;
  
  `include "../../ncsu_pkg/ncsu_macros.svh"
  // `include "ncsu_macros.svh"
  `include "src/i2c_transaction.svh"
  `include "src/i2c_transaction_random.svh"
  `include "src/i2c_configuration.svh"
  `include "src/i2c_coverage.svh"
  `include "src/i2c_driver.svh"
  `include "src/i2c_monitor.svh"
  `include "src/i2c_agent.svh"
  

endpackage

