class i2c_driver extends ncsu_component#(.T(i2c_transaction));

  virtual i2c_if #(.ADDR_WIDTH(I2C_ADDR_WIDTH), .DATA_WIDTH(I2C_DATA_WIDTH))	i2c_bus;
  i2c_configuration i2c_config;
  i2c_transaction i2c_trans;

  function void set_configuration(i2c_configuration cfg);
    i2c_config = cfg;
  endfunction

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    if(!(ncsu_config_db#(virtual i2c_if#(.ADDR_WIDTH(I2C_ADDR_WIDTH), .DATA_WIDTH(I2C_DATA_WIDTH)))::get("i2c_interface", this.i2c_bus))) begin
		ncsu_fatal("i2c_agent::new()",$sformatf("ncsu_config_db::get() call failed."));
    end
  endfunction

  virtual task bl_put(T trans);
    automatic bit [I2C_DATA_WIDTH-1:0] data [];
    if(trans.i2c_op == I2C_WRITE) i2c_bus.wait_for_i2c_transfer(trans.i2c_op, trans.i2c_data);

    else if(trans.i2c_op == I2C_READ) begin
      i2c_bus.wait_for_i2c_transfer(trans.i2c_op, data);
			i2c_bus.provide_read_data(trans.i2c_data, trans.i2c_transfer_complete);
    end

    else $error("i2c op invalid");
  endtask

endclass
