class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

  i2cmb_env_configuration config_1;
  wb_op_t wb_op_1;
  bit [WB_ADDR_WIDTH-1:0] wb_addr_1;
  bit [WB_DATA_WIDTH-1:0] cmdr_commands_1;

  covergroup wb_cg;
    wb_op: coverpoint wb_op_1{
      bins read = {WB_READ};
      bins write = {WB_WRITE};
    }
    wb_addr: coverpoint wb_addr_1{
      bins csr = {CSR};
      bins dpr = {DPR};
      bins cmdr = {CMDR};
      bins fsmr = {FSMR};
    }
    wb_op_x_addr: cross wb_op, wb_addr;
    cmdr_commands: coverpoint cmdr_commands_1{
      bins set_bus = {8'b00000110};
      bins start = {8'b00000100};
      bins write = {8'b00000001};
      bins read_w_nack = {8'b00000011};
      bins read_w_ack = {8'b00000010};
      bins stop = {8'b00000101};
    }
  endgroup

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    wb_cg = new;
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    config_1 = cfg;
  endfunction

  virtual function void nb_put(T trans);
    wb_op_1 = trans.wb_op;
    wb_addr_1 = trans.wb_addr;
    if(wb_addr_1 == CMDR) cmdr_commands_1 = trans.wb_data;
    else cmdr_commands_1 = 8'b0;
    wb_cg.sample();


  endfunction

endclass
