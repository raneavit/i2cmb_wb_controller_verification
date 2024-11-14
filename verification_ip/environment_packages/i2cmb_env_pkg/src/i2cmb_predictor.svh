class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));


i2cmb_env_configuration i2cmb_env_config;
i2c_transaction predictor_i2c_trans, received_trans;
bit[I2C_DATA_WIDTH-1:0] data[$];
bit transaction_in_progress;
bit address_captured;

ncsu_component#(i2c_transaction) i2cmb_scoreboard;

function new(string name="", ncsu_component_base parent = null);
	super.new(name, parent);
    transaction_in_progress = 1'b0;
endfunction

function void set_configuration(i2cmb_env_configuration cfg);
	i2cmb_env_config = cfg;
endfunction

virtual function void set_scoreboard(ncsu_component#(i2c_transaction) scoreboard);
	this.i2cmb_scoreboard = scoreboard;
endfunction

virtual function void nb_put(T trans);
    
    if((trans.wb_addr == CMDR) && (trans.wb_data[2:0] == 3'b100) && (trans.wb_op == WB_WRITE))begin //start detected
        // $display("Predictor start detected");
        if(transaction_in_progress) begin
            predictor_i2c_trans.i2c_data = data;
            i2cmb_scoreboard.nb_transport(predictor_i2c_trans, received_trans); 
            data = {};
        end //send current transaction to scoreboard, clear databuffer

        transaction_in_progress = 1'b1; // start detected
        $cast(predictor_i2c_trans, ncsu_object_factory::create("i2c_transaction"));
        address_captured = 1'b0;
        return;
    end

    if(transaction_in_progress)begin
        if(address_captured == 1'b0 && (trans.wb_addr == DPR) && (trans.wb_op == WB_WRITE)) begin predictor_i2c_trans.i2c_addr = (trans.wb_data>>1); predictor_i2c_trans.i2c_op = (trans.wb_data[0] ? I2C_READ : I2C_WRITE); address_captured = 1'b1; return; end

        if(predictor_i2c_trans.i2c_op == I2C_WRITE) begin
            if((trans.wb_addr == DPR) && (trans.wb_op == WB_WRITE)) begin data.push_back(trans.wb_data);end
            else if((trans.wb_addr == CMDR) && (trans.wb_data[2:0] == 3'b101)) begin 
                // $display("Predictor i2c write stop detected");
                predictor_i2c_trans.i2c_data = data;
                i2cmb_scoreboard.nb_transport(predictor_i2c_trans, received_trans);
                data = {};
                transaction_in_progress = 1'b0;
                end //send current transaction to scoreboard, clear databuffer, transaction_in_progress = 0
        end

        else if (predictor_i2c_trans.i2c_op == I2C_READ) begin
            if((trans.wb_addr == DPR) && (trans.wb_op == WB_READ)) begin data.push_back(trans.wb_data);end
            else if((trans.wb_addr == CMDR) && (trans.wb_data[2:0] == 3'b101)) begin
                // $display("Predictor i2c read stop detected");
                predictor_i2c_trans.i2c_data = data;
                i2cmb_scoreboard.nb_transport(predictor_i2c_trans, received_trans);
                data = {};
                transaction_in_progress = 1'b0;
                end //send current transaction to scoreboard, clear databuffer, transaction_in_progress = 0
        end
    end
endfunction
endclass