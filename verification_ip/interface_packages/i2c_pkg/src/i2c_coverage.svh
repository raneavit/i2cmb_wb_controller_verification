class i2c_coverage extends ncsu_component#(.T(i2c_transaction));

  i2c_configuration config_1;
  i2c_op_t i2c_op_1;
  bit [I2C_ADDR_WIDTH-1:0] i2c_addr_1;
  bit [I2C_DATA_WIDTH-1:0] i2c_total_data [];
  bit [I2C_DATA_WIDTH-1:0] i2c_data_1;
  int transfer_size_1;

  covergroup i2c_cg;
    i2c_op: coverpoint i2c_op_1{
      bins read = {I2C_READ};
      bins write = {I2C_WRITE};
    }
    i2c_data: coverpoint i2c_data_1{
      option.auto_bin_max = 4;
    }
    i2c_transfer_size: coverpoint transfer_size_1{
      bins single = {1};
      bins multiple = {[2:$]};
    }
    i2c_op_x_transfer_size: cross i2c_op, i2c_transfer_size;
  endgroup

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    i2c_cg = new;
  endfunction

  function void set_configuration(i2c_configuration cfg);
    config_1 = cfg;
  endfunction

  virtual function void nb_put(T trans);
    i2c_op_1 = trans.i2c_op;
    i2c_addr_1 = trans.i2c_addr;
    i2c_total_data = trans.i2c_data;
    transfer_size_1 = i2c_total_data.size();
    for(int i = 0; i<transfer_size_1; i++) begin
      i2c_data_1 = i2c_total_data[i];
      i2c_cg.sample();
    end
    
  endfunction

endclass
