class i2cmb_test extends ncsu_component#(.T(i2c_transaction));

  i2cmb_env_configuration cfg;
  i2cmb_environment env;
  i2cmb_generator gen;
  i2cmb_generator_dut_behaviour_test gen_behaviour_test;
  i2cmb_generator_register_test gen_register_test;
  string gen_type;


  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);
    cfg = new("cfg");
    env = new("env",this);
    env.set_configuration(cfg);
    env.build();
    // gen = new("gen",this);
    if ( !$value$plusargs("GEN_TYPE=%s", gen_type)) begin
      $display("FATAL: +GEN_TYPE plusarg not found on command line");
      $fatal;
    end
    $display("%m found +GEN_TYPE=%s", gen_type);
    $cast(gen, ncsu_object_factory::create(gen_type));
    gen.set_i2c_agent(env.get_i2c_agent());
    gen.set_wb_agent(env.get_wb_agent());
  endfunction

  virtual task run();
     env.run();
     gen.run();
  endtask

endclass
