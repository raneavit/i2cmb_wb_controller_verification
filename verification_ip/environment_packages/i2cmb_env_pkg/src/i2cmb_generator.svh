// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(i2c_transaction));
class i2cmb_generator extends ncsu_component#(.T(i2c_transaction));
    `ncsu_register_object(i2cmb_generator)

    i2c_agent my_i2c_agent;
    i2c_transaction i2c_test1_trans, i2c_test2_trans, i2c_test3_write_trans_arr[64], i2c_test3_read_trans_arr[64];
    wb_agent my_wb_agent;
    wb_transaction wb_trans;

    bit [WB_DATA_WIDTH-1:0] wb_read_data_arr_1 [];
    bit [WB_DATA_WIDTH-1:0] wb_read_data_arr_2 [];

    function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);

    //Initialize 
    wb_read_data_arr_1 = new[32];
    wb_read_data_arr_2 = new[1];

    //Create transactions
    $cast(i2c_test1_trans, ncsu_object_factory::create("i2c_transaction"));
    $cast(i2c_test2_trans, ncsu_object_factory::create("i2c_transaction"));

    i2c_test1_trans.set_op(I2C_WRITE);
    i2c_test2_trans.set_op(I2C_READ);

    wb_read_data_arr_1 = new[32];
    for(int i = 0; i < 32; i++) begin
        wb_read_data_arr_1[i] = i + 100;
    end
    i2c_test2_trans.set_data(wb_read_data_arr_1);

    for(int i = 0; i < 64; i++ ) begin
        $cast(i2c_test3_write_trans_arr[i], ncsu_object_factory::create("i2c_transaction"));
        $cast(i2c_test3_read_trans_arr[i], ncsu_object_factory::create("i2c_transaction"));

        i2c_test3_write_trans_arr[i].set_op(I2C_WRITE);
        i2c_test3_read_trans_arr[i].set_op(I2C_READ);

        wb_read_data_arr_2[0] = 63-i;
        i2c_test3_read_trans_arr[i].set_data(wb_read_data_arr_2);
    end


    endfunction

    function void set_i2c_agent(i2c_agent i2c_agent_i);
        this.my_i2c_agent = i2c_agent_i;
    endfunction

    function void set_wb_agent(wb_agent wb_agent_i);
        this.my_wb_agent = wb_agent_i;
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
            // $display("Initiating I2C Write of incrementing values 0-31 to Slave Address %0h",8'h22);
            wb_send_start_condition();
            wb_address(8'h22, 1'b0);
            for(int i = 0; i < 32; i++ ) wb_write_data(i);
            wb_send_stop_condition();
            //***********************************

            //********** Test 2 *****************
            wb_send_start_condition();
            wb_address(8'h22, 1'b1);
            // $display("Initiating I2C Read of incrementing values 100-131 from Slave Address %0h",8'h22);
            for(int i = 0; i < 31; i++ )begin
                wb_ack(); //acks
                wb_dpr_read();
            end

            wb_nack(); //nacks
            wb_dpr_read();
            wb_send_stop_condition();
            //***********************************

            //********** Test 3 *****************
            for(int i = 0; i < 64; i++ ) begin
                wb_send_start_condition();
                // $display("Initiating I2C Write of Data %0d to Slave Address %0h", (64 + i), 8'h22);
                wb_address(8'h22, 1'b0);
                wb_write_data(64 + i);
                wb_send_start_condition();
                // $display("Initiating I2C Read of Data %0d from Slave Address %0h", (63 - i), 8'h22);
                wb_address(8'h22, 1'b1);
                wb_nack(); //nacks
                wb_dpr_read();
            end
            wb_send_stop_condition();
            
            //***********************************
            end


            begin

            //********** Test 1 *****************
            my_i2c_agent.bl_put(i2c_test1_trans);
            //***********************************

            //********** Test 2 *****************
            my_i2c_agent.bl_put(i2c_test2_trans);
            //***********************************

            //********** Test 3 *****************
            for(int i=0;i<64;i++) begin
                my_i2c_agent.bl_put(i2c_test3_write_trans_arr[i]);
                my_i2c_agent.bl_put(i2c_test3_read_trans_arr[i]);
            end
            //***********************************
            end

        join

    endtask

    //----------------------------WB tasks------------------------------
    task wb_send_start_condition();
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx100); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); // Start Command
    endtask

    task wb_send_stop_condition();
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx101); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); // Stop Command
    endtask


    task wb_address(input logic [I2C_DATA_WIDTH-1:0] address, input bit wbar);
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(DPR); wb_trans.set_data(((address << 1) | wbar)); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); //set address and op

        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx001); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans); 
    endtask

    task wb_write_data(input logic [WB_DATA_WIDTH-1:0] data);
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(DPR); wb_trans.set_data(data); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);

        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx001); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
    endtask

    task wb_ack();
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx010); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
    endtask

    task wb_nack();
        $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
        wb_trans.set_addr(CMDR); wb_trans.set_data(8'bxxxxx011); wb_trans.set_op(WB_WRITE); my_wb_agent.bl_put(wb_trans);
    endtask

    task wb_dpr_read();
    $cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
    wb_trans.set_addr(DPR); wb_trans.set_op(WB_READ); my_wb_agent.bl_put(wb_trans);
    endtask

endclass
