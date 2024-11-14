class i2cmb_env_configuration extends ncsu_configuration;

i2c_configuration i2c_agent_1_config;
wb_configuration wb_agent_1_config;

function new(string name="");
    super.new(name);
    i2c_agent_1_config = new("i2c_agent_1_config");
    wb_agent_1_config = new("wb_agent_1_config");
endfunction

virtual function string convert2string();
    return {super.convert2string};
endfunction

endclass