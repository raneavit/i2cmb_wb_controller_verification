// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(i2c_transaction));
class i2cmb_generator_dut_behaviour_test extends i2cmb_generator;
    `ncsu_register_object(i2cmb_generator_dut_behaviour_test)

    i2c_transaction i2c_trans;
    wb_transaction wb_trans;
    bit dut_behaviour_tests_passed;
    bit bus_id_limit_test;
    bit bus_capture_test;

    function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    endfunction

    virtual task run();
    dut_behaviour_tests_passed = 1'b1;
    bus_id_limit_test = 1'b1;
    bus_capture_test = 1'b1;

    //Enable core
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CSR); wb_trans.set_data(8'b11xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    /////////////////////////////////////////////////////////////////////
    $display("********** Bus ID Limit Test **********");
    $display("Writing out of bounds Bus ID...");
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(DPR); wb_trans.set_data(8'b01011110); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx110); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CMDR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    if(wb_trans.wb_data[4])  $display("Test Passed - Out of Bounds Bus ID failed - Error Bit Set"); //MSB - DON bit of CMDR should not be set
    else begin
        $display("Test Failed - Out of Bounds Bus ID set - Error Bit not Set");
        dut_behaviour_tests_passed = 1'b0;
        bus_id_limit_test = 1'b0;
    end
    if(bus_id_limit_test) $display("********** Bus ID Limit Test - PASSED **********");
    else $display("********** Bus ID Limit Test - FAILED **********");

    /////////////////////////////////////////////////////////////////////
    $display("\n");
    $display("********** Bus Capture Test **********");
    $display("Checking Bus Capture bit prior to setting bus...");
    wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    if(wb_trans.wb_data[4] == 1'b0)  $display("Test Passed - Bus Capture bit clear prior to setting bus"); //BC bit of CMDR should not be set
    else begin
        $display("Test Failed - Bus Capture bit set prior to setting bus");
        dut_behaviour_tests_passed = 1'b0;
        bus_capture_test = 1'b0;
    end

    $display("Setting Bus ID 0...");
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(DPR); wb_trans.set_data(8'b00000000); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); 

    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx110); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    $display("Sending Start Command...");
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx100); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

   

    $display("Checking Bus Capture bit after Start Command bus...");
    wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    if(wb_trans.wb_data[4] == 1'b1)  $display("Test Passed - Bus Capture bit set after Start Command"); //MSB - DON bit of CMDR should not be set
    else begin
        $display("Test Failed - Bus Capture bit not set after Start Command");
        dut_behaviour_tests_passed = 1'b0;
        bus_capture_test = 1'b0;
    end

     wb_address(8'h22, 1'b0);
     wb_write_data(0);

    $display("Sending Stop Command...");
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx101); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    $display("Checking Bus Capture bit after Stop Command bus...");
    wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    if(wb_trans.wb_data[4] == 1'b0)  $display("Test Passed - Bus Capture bit clear after Stop command"); //MSB - DON bit of CMDR should not be set
    else begin
        $display("Test Failed - Bus Capture bit not set after Stop command");
        dut_behaviour_tests_passed = 1'b0;
        bus_capture_test = 1'b0;
    end

    if(bus_id_limit_test) $display("********** Bus Capture Test - PASSED **********");
    else $display("********** Bus Capture Test - FAILED **********");
    //Disable core
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CSR); wb_trans.set_data(8'b00xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    /////////////////////////////////////////////////////////////////////
    //Enable core
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CSR); wb_trans.set_data(8'b11xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    $display("\n");
    $display("********** Bus Busy Test **********");
    $display("Checking Bus Busy bit prior to Start Command...");
    wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    if(wb_trans.wb_data[5] == 1'b0)  $display("Test Passed - Bus Busy bit clear prior to Start Command"); //BB bit of CMDR should not be set
    else begin
        $display("Test Failed - Bus Busy bit set prior to Start Command");
        dut_behaviour_tests_passed = 1'b0;
        bus_capture_test = 1'b0;
    end

    $display("Sending Start Command...");
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx100); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    $display("Checking Bus Busy bit after Start Command...");
    wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    if(wb_trans.wb_data[5] == 1'b1)  $display("Test Passed - Bus Busy bit set after Start Command"); //BB bit of CMDR should not be set
    else begin
        $display("Test Failed - Bus Busy bit not set after Start Command");
        dut_behaviour_tests_passed = 1'b0;
        bus_capture_test = 1'b0;
    end

    wb_address(8'h22, 1'b0);
    wb_write_data(0);

    $display("Sending Stop Command...");
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx101); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    $display("Checking Bus Busy bit after Stop Command...");
    wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    if(wb_trans.wb_data[5] == 1'b1)  $display("Test Passed - Bus Busy bit set after Stop Command"); //BB bit of CMDR should not be set
    else begin
        $display("Test Failed - Bus Busy bit not set after Stop Command");
        dut_behaviour_tests_passed = 1'b0;
        bus_capture_test = 1'b0;
    end

    if(bus_id_limit_test) $display("********** Bus Busy Test - PASSED **********");
    else $display("********** Bus Busy Test - FAILED **********");

    //Disable core
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(CSR); wb_trans.set_data(8'b00xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
    


    endtask

endclass
