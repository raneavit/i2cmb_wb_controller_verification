class i2c_agent extends ncsu_component#(.T(i2c_transaction));

    virtual i2c_if #(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH))	i2c_bus;

    i2c_configuration		i2c_config;
    i2c_driver				i2c_driver_1;
    i2c_monitor				i2c_monitor_1;
    i2c_coverage i2c_coverage_1;
    ncsu_component #(T) subscribers[$];

    function new(string name="", ncsu_component_base parent=null);
        super.new(name, parent);
        if(!(ncsu_config_db#(virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH)))::get("i2c_interface", i2c_bus))) begin
            ncsu_fatal("i2c_agent::new()",$sformatf("ncsu_config_db::get() call failed."));
        end
    endfunction

    function void set_configuration(i2c_configuration cfg);
    	i2c_config = cfg;
    endfunction

    virtual function void build();
        i2c_driver_1 = new("i2c_driver_1", this);
        i2c_driver_1.set_configuration(i2c_config);
        i2c_driver_1.build();
        i2c_driver_1.i2c_bus = this.i2c_bus;

        i2c_monitor_1 = new("i2c_monitor_1", this);
        i2c_monitor_1.set_configuration(i2c_config);
        i2c_monitor_1.build();
        i2c_monitor_1.set_agent(this);
        i2c_monitor_1.i2c_bus = this.i2c_bus;

        i2c_coverage_1 = new("i2cmb_coverage_1", this);
        i2c_coverage_1.set_configuration(i2c_config);
        i2c_coverage_1.build();
        this.connect_subscriber(i2c_coverage_1);
    endfunction

    virtual function void nb_put(T trans);
    	foreach(subscribers[i]) subscribers[i].nb_put(trans);
    endfunction

    virtual function void connect_subscriber(ncsu_component#(T) subs);
    	subscribers.push_back(subs);
    endfunction

    virtual task bl_put(i2c_transaction trans);
        i2c_driver_1.bl_put(trans);
    endtask

    virtual task run();
        fork i2c_monitor_1.run(); join_none
    endtask

endclass
