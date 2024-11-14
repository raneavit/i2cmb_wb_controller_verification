class wb_monitor extends ncsu_component#(.T(wb_transaction));

    virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) wb_bus;
    wb_configuration wb_config;
    wb_transaction wb_trans;
    ncsu_component#(T) agent;
    bit we_out;

    function new(string name ="", ncsu_component_base parent=null);
        super.new(name, parent);
    endfunction

    function void set_configuration(wb_configuration cfg);
        wb_config = cfg;
    endfunction

    function void set_agent(ncsu_component#(T) agent);
        this.agent = agent;
    endfunction

    virtual task run();
        wb_bus.wait_for_reset();
        forever begin
            $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
            wb_bus.master_monitor(wb_trans.wb_addr, wb_trans.wb_data, we_out);
            wb_trans.wb_op = (we_out) ? WB_WRITE : WB_READ;
            // $display("Observed WB transaction: Address=%0x, Data=%0x, WE=%0b", wb_trans.wb_addr, wb_trans.wb_data, we_out);
            this.agent.nb_put(wb_trans);
        end
    endtask

endclass
