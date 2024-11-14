class i2cmb_environment extends ncsu_component#(.T(i2c_transaction));

    i2cmb_env_configuration i2c_env_config;
    i2c_agent i2c_agent_1;
    wb_agent wb_agent_1;
    i2cmb_predictor i2cmb_predictor_1;
    i2cmb_scoreboard        i2cmb_scoreboard_1;
    i2cmb_coverage          i2cmb_coverage_1;

    function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    endfunction 

    function void set_configuration(i2cmb_env_configuration cfg);
    i2c_env_config = cfg;
    endfunction

    virtual function void build();
    i2c_agent_1 = new("i2c_agent_1",this);
    i2c_agent_1.set_configuration(i2c_env_config.i2c_agent_1_config);
    i2c_agent_1.build();
    wb_agent_1 = new("wb_agent_1",this);
    wb_agent_1.set_configuration(i2c_env_config.wb_agent_1_config);
    wb_agent_1.build();
    i2cmb_predictor_1  = new("i2cmb_predictor_1", this);
    i2cmb_predictor_1.set_configuration(i2c_env_config);
    i2cmb_predictor_1.build();
    i2cmb_scoreboard_1  = new("i2cmb_scoreboard_1", this);
    i2cmb_scoreboard_1.build();
    i2cmb_coverage_1 = new("i2cmb_coverage_1", this);
    i2cmb_coverage_1.set_configuration(i2c_env_config);
    i2cmb_coverage_1.build();
    wb_agent_1.connect_subscriber(i2cmb_coverage_1);
    wb_agent_1.connect_subscriber(i2cmb_predictor_1);
    i2cmb_predictor_1.set_scoreboard(i2cmb_scoreboard_1);
    i2c_agent_1.connect_subscriber(i2cmb_scoreboard_1);
    endfunction

    function i2c_agent get_i2c_agent();
        return i2c_agent_1;
    endfunction

    function wb_agent get_wb_agent();
        return wb_agent_1;
    endfunction

    virtual task run();
        wb_agent_1.run();
        i2c_agent_1.run();
    endtask

endclass
