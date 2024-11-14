class wb_driver extends ncsu_component#(.T(wb_transaction));
    
    virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) wb_bus;
    wb_configuration wb_config;
    wb_transaction wb_trans;
    bit [WB_DATA_WIDTH-1:0] temp;

    function new(string name="", ncsu_component_base  parent=null);
        super.new(name, parent);
    endfunction

    function void set_configuration(wb_configuration cfg);
    	wb_config = cfg;
    endfunction

    virtual task bl_put(wb_transaction trans);
        if(trans.wb_op == WB_WRITE) wb_bus.master_write(trans.wb_addr, trans.wb_data);
        if(trans.wb_op == WB_READ)  wb_bus.master_read(trans.wb_addr, trans.wb_data);
    	if((trans.wb_op== WB_WRITE) && (trans.wb_addr == CMDR)) begin
            wb_bus.wait_for_interrupt();
            // assert (temp == 8'b1xxxxxxx) else $error("CMDR DON bit not set");
            wb_bus.master_read(CMDR, temp);
        end
    endtask


endclass
