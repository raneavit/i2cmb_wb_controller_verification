// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(i2c_transaction));
class i2cmb_generator_register_test extends i2cmb_generator;
    `ncsu_register_object(i2cmb_generator_register_test)
    
    i2c_transaction i2c_trans;
    wb_transaction wb_trans;
    bit register_tests_passed;
    bit default_value_test;
    bit aliasing_test;
    bit access_test;
    bit [WB_DATA_WIDTH-1:0] temp_data;

    function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    endfunction

    virtual task run();
        register_tests_passed = 1'b1;
        default_value_test = 1'b1;
        aliasing_test = 1'b1;
        access_test = 1'b1;

        ///////////////////////////////////////////////////////////////////////////
        $display("********** Register Default Value after Reset Test **********");
        $display("Checking CSR Value");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b00000000)  $display("Test Passed - CSR Default Value");
        else begin
            $display("Test Failed - CSR Default Value");
            register_tests_passed = 1'b0;
            default_value_test = 1'b0;
        end

        $display("Checking DPR Value");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(DPR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b00000000)  $display("Test Passed - DPR Default Value");
        else begin
            $display("Test Failed - DPR Default Value");
            register_tests_passed = 1'b0;
            default_value_test = 1'b0;
        end

        $display("Checking CMDR Value");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b10000000)  $display("Test Passed - CMDR Default Value");
        else begin
            $display("Test Failed - CMDR Default Value");
            register_tests_passed = 1'b0;
            default_value_test = 1'b0;
        end

        $display("Checking FSMR Value");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(FSMR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b00000000)  $display("Test Passed - FSMR Default Value");
        else begin
            $display("Test Failed - FSMR Default Value");
            register_tests_passed = 1'b0;
            default_value_test = 1'b0;
        end

        if(default_value_test) $display("********** Register Default Value after Reset Test - PASSED **********");
        else $display("********** Register Default Value after Reset Test - FAILED **********");

        ///////////////////////////////////////////////////////////////////////////
        $display("\n");
        $display("********** Register Core Enable Test **********");
        $display("Setting E bit in CSR to enable core");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_data(8'b10xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
        $display("Clearing E bit in CSR to disable/reset core");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_data(8'b00xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
        $display("********** Register Core Enable Test - PASSED **********");

        ///////////////////////////////////////////////////////////////////////////
        $display("\n");
        $display("********** Register Aliasing Test **********");
        $display("Writing to CSR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_data(8'b11000000); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

        $display("Checking DPR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(DPR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b0) $display("Test Passed : DPR not aliasing when writing to CSR");
        else begin
            $display("Test Failed : DPR Aliasing when writing to CSR"); 
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("Checking CMDR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b10000000) $display("Test Passed : CMDR not aliasing when writing to CSR");
        else begin
            $display("Test Failed : CMDR Aliasing when writing to CSR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("Checking FSMR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(FSMR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b0) $display("Test Passed : FSMR not aliasing when writing to CSR");
        else begin
            $display("Test Failed : FSMR Aliasing when writing to CSR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("..............................");

        $display("Writing to DPR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(DPR); wb_trans.set_data(8'b00000001); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

        $display("Checking CSR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b11000000) $display("Test Passed : CSR not aliasing when writing to DPR");
        else begin
            $display("Test Failed : CSR Aliasing when writing to DPR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("Checking CMDR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b10000000) $display("Test Passed : CMDR not aliasing when writing to DPR");
        else begin
            $display("Test Failed : CMDR Aliasing when writing to DPR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("Checking FSMR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(FSMR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b0) $display("Test Passed : FSMR not aliasing when writing to DPR");
        else begin
            $display("Test Failed : FSMR Aliasing when writing to DPR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("..............................");

        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(DPR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        temp_data = wb_trans.wb_data;

        $display("Writing to CMDR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'b00000110); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

        $display("Checking CSR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b11000000) $display("Test Passed : CSR not aliasing when writing to CMDR");
        else begin
            $display("Test Failed : CSR Aliasing when writing to CMDR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("Checking DPR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(DPR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == temp_data) $display("Test Passed : DPR not aliasing when writing to CMDR");
        else begin
            $display("Test Failed : DPR Aliasing when writing to CMDR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $display("Checking FSMR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(FSMR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == 8'b0) $display("Test Passed : FSMR not aliasing when writing to CMDR");
        else begin
            $display("Test Failed : FSMR Aliasing when writing to CMDR");
            register_tests_passed = 1'b0;
            aliasing_test = 1'b0;
        end

        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_data(8'b00xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
        my_wb_agent.bl_put(wb_trans);

        if(aliasing_test) $display("********** Register Aliasing Test - PASSED **********");
        else $display("********** Register Aliasing Test - FAILED **********");

        ///////////////////////////////////////////////////////////////////////////
        $display("\n");
        $display("********** Register Access Test **********");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(FSMR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        temp_data = wb_trans.wb_data;

        $display("Illegally writing to FSMR...");
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(FSMR); wb_trans.set_data(8'b00000101); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(FSMR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
        if(wb_trans.wb_data == temp_data) $display("Test Passed : Illegal Write to FSMR avoided");
        else begin
            $display("Test Failed : Illegal Write to FSMR allowed");
            register_tests_passed = 1'b0;
            access_test = 1'b0;
        end
        if(access_test) $display("********** Register Access Test - PASSED **********");
        else $display("********** Register Access Test - FAILED **********");

        ///////////////////////////////////////////////////////////////////////////
        $display("\n");
        $display("********** Register Address Validity Test **********");
        $display("Check if all previous tests have completed");
        if(register_tests_passed) $display("********** Register Address Validity Test - PASSED **********");
        else $display("********** Register Address Validity Test - FAILED **********");

        //Disable core at the end
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CSR); wb_trans.set_data(8'b00xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

    endtask

endclass
