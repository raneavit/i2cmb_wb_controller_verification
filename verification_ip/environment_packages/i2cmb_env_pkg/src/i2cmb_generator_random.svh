// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(i2c_transaction));
class i2cmb_generator_random extends i2cmb_generator;
    `ncsu_register_object(i2cmb_generator_random)
    int no_of_random_tests = 50;
	int random_transfer_sizes [];
    i2c_transaction_random i2c_trans_random;
    wb_transaction_random wb_trans_random;

    function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    random_transfer_sizes = new [no_of_random_tests];
    for(int i; i<random_transfer_sizes.size(); i++) random_transfer_sizes[i] = $urandom_range(1, 32);
    endfunction

    virtual task run();
        fork: generator_run
        begin
            //Enable core and interrupt
            $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
            wb_trans.set_addr(CSR); wb_trans.set_data(8'b11xxxxxx); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

            //Setup
            $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
            wb_trans.set_addr(DPR); wb_trans.set_data(BUS_ID); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); //ID of Desired Bus

            $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
            wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx110); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); //Set Bus cmd

            //********** Test 1 *****************
            // Random writes;
            $display("****************** Random Writes ********************");
            for(int i = 0; i < no_of_random_tests; i++ ) begin
            wb_send_start_condition();
            wb_address(8'h22, 1'b0);
            for(int j = 0; j < random_transfer_sizes[i]; j++ ) wb_write_random_data();
            wb_send_stop_condition();
            end
            //***********************************

            // //********** Test 2 *****************
            // // Random Reads;
            $display("\n");
            $display("******************  Random Reads ******************");
            for(int i=0; i<no_of_random_tests; i++) begin
                wb_send_start_condition();
                wb_address(8'h22, 1'b1);
                for(int j= 0; j < random_transfer_sizes[i]; j++ )begin
                    wb_ack(); //acks
                    wb_dpr_read();
                end
                wb_nack(); //nacks
                wb_dpr_read();
            end
            wb_send_stop_condition();
            

            // //***********************************

        end

        begin
            //********** Test 1 *****************
            for(int i=0; i<no_of_random_tests; i++) begin
                $cast(i2c_test1_trans, ncsu_object_factory::create("i2c_transaction"));
                i2c_test1_trans.set_op(I2C_WRITE);
                my_i2c_agent.bl_put(i2c_test1_trans);
            end
            //***********************************

            //********** Test 2 *****************
            for(int i=0; i<no_of_random_tests; i++) begin
                $cast(i2c_trans_random, ncsu_object_factory::create("i2c_transaction_random"));
                i2c_trans_random.set_op(I2C_READ);
                assert(i2c_trans_random.randomize() with { i2c_trans_random.i2c_data_random.size() == random_transfer_sizes[i]; })
                i2c_trans_random.put_randomized_data();
                my_i2c_agent.bl_put(i2c_trans_random);
            end

        end

        join
    endtask

    task wb_write_random_data();
        $cast(wb_trans_random, ncsu_object_factory::create("wb_transaction_random"));
        wb_trans_random.randomize();
        wb_trans_random.put_randomized_data();
        wb_trans_random.set_addr(DPR); wb_trans_random.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans_random); 

        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx001); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); 
    endtask

endclass
