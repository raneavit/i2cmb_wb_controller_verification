class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)

  bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
  i2c_op_t i2c_op;
  bit [I2C_DATA_WIDTH-1:0] i2c_data [];
  bit i2c_transfer_complete;

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
    if(this.i2c_op == I2C_WRITE) return {super.convert2string(), $sformatf("write data: %p", i2c_data)};
    else if(this.i2c_op == I2C_READ) return {super.convert2string(), $sformatf("read data: %p", i2c_data)};
  endfunction

  function bit compare(i2c_transaction rhs);
    return ((this.i2c_addr  == rhs.i2c_addr ) && 
            (this.i2c_op == rhs.i2c_op) &&
            (this.i2c_data == rhs.i2c_data) );
  endfunction

  virtual function void set_addr(input bit [I2C_ADDR_WIDTH-1:0] addr);
    this.i2c_addr = addr;
  endfunction

  virtual function void set_data(input bit [I2C_DATA_WIDTH-1:0] data []);
    this.i2c_data = new [data.size()];
    this.i2c_data = data;
  endfunction

  function void set_op(input i2c_op_t op);
    this.i2c_op = op;
  endfunction

  function void set_transfer_complete(input bit tc);
    this.i2c_transfer_complete = tc;
  endfunction

  virtual function void get_addr(output bit [I2C_ADDR_WIDTH-1:0] addr);
    addr = this.i2c_addr;
  endfunction

  virtual function void get_data(output bit [I2C_DATA_WIDTH-1:0] data []);
    data = this.i2c_data;
  endfunction

  function i2c_op_t get_op();
    return this.i2c_op;
  endfunction

  function void get_transfer_complete(output bit tc);
    tc = this.i2c_transfer_complete;
  endfunction

    

endclass
