class wb_agent extends ncsu_component #(.T(wb_transaction));

	virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) wb_bus;

	wb_configuration 	wb_config;
	wb_driver 		    wb_driver_1;
	wb_monitor          wb_monitor_1;
	//wb_coverage         wb_coverage;
	ncsu_component #(T)	subscribers[$];

	function new(string name= "", ncsu_component_base parent=null);
		super.new(name, parent);
		if(!(ncsu_config_db#(virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)))::get("wb_interface", this.wb_bus))) begin
			ncsu_fatal("wb_agent::new()",$sformatf("ncsu_config_db::get() call failed."));
		end
	endfunction

	function void set_configuration(wb_configuration cfg);
		wb_config = cfg;
	endfunction

	virtual function void connect_subscriber(ncsu_component#(T) subs);
		subscribers.push_back(subs);
	endfunction

	virtual function void build();
		wb_driver_1 = new("wb_driver_1", this);
		wb_driver_1.set_configuration(wb_config);
		wb_driver_1.build();
		wb_driver_1.wb_bus = this.wb_bus;

		wb_monitor_1 = new("wb_monitor_1", this);
		wb_monitor_1.set_configuration(wb_config);
		wb_monitor_1.set_agent(this);
		wb_monitor_1.build();
		wb_monitor_1.wb_bus = this.wb_bus;
	endfunction

	virtual function void nb_put(T trans);
		foreach(subscribers[i]) subscribers[i].nb_put(trans);
	endfunction

	virtual task bl_put(T trans);
		wb_driver_1.bl_put(trans);
	endtask

	virtual task run();
		fork wb_monitor_1.run(); join_none
	endtask

endclass
