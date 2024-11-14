//I2C interface

interface i2c_if       #(
    int ADDR_WIDTH = 7,
    int DATA_WIDTH = 8,
    int SLAVE_ADDR = 7'h22 //remember it has been changed to 1
)(
    input tri scl_i,
    input triand  sda_i,
    output tri scl_o,
    output triand  sda_o
);

import i2c_pkg::*;

i2c_op_t i2_op;
i2c_op_t i2c_monitor_op;
logic sda_en = 1'b0;
logic sda_data;
bit skip_start;
bit monitor_skip_start;

assign sda_o = sda_en ? sda_data : 1'bz;


task wait_for_i2c_transfer (output i2c_op_t op_o, output bit [DATA_WIDTH-1:0] write_data []);
    automatic bit [ADDR_WIDTH-1:0] address;
    automatic i2c_op_t op;
    automatic bit address_match;
    automatic int write_fork_pid;
    automatic int address_mismatch_fork_pid;
    automatic bit [DATA_WIDTH-1:0] data [$];
    automatic bit [DATA_WIDTH-1:0] data_byte;

    if(skip_start == 1'b0) begin detect_start(); end;
    skip_start = 1'b0;
    get_addr_op(address, op, address_match);

    if(address_match) begin
        if(op == I2C_WRITE) begin
            while(1)begin
                create_write_fork(write_fork_pid, data_byte);
                case(write_fork_pid)
                    1 : begin data.push_back(data_byte); continue; end
                    2 : begin op_o = op; write_data = data; return; end
                    3 : begin skip_start = 1'b1; op_o = op; write_data = data; return; end
                endcase
            end
        end

        else if (op == I2C_READ) begin
            op_o = op;
            data.push_back(address);
            write_data = data; return; //return and call read
        end
    end

    else begin
        fork : address_mismatch_fork
        begin detect_stop(); address_mismatch_fork_pid = 1; end
        begin detect_start(); address_mismatch_fork_pid = 2; end
        join_any

        disable address_mismatch_fork;

        if(address_mismatch_fork_pid == 1) skip_start = 1'b1;
    end  
endtask

task detect_start ();
    while(1) begin
        @(negedge sda_i)begin
            if(scl_i == 1'b1)begin
                // $display("I2C start condition detected");
                return;
            end
        end
    end
endtask

task get_addr_op (output bit [ADDR_WIDTH-1:0] address_o, output i2c_op_t op_o, output bit address_match_o);
    automatic bit [ADDR_WIDTH-1:0] observed_address;
    automatic int iterator;

    iterator = 0;
    repeat (ADDR_WIDTH) @(posedge scl_i) begin
        observed_address = ((observed_address | sda_i << ( (ADDR_WIDTH - 1) - iterator)));
        iterator = iterator + 1;
    end

    // $display("Observed Address %0h", observed_address);
    address_o = observed_address;
    @(posedge scl_i) op_o = sda_i ? I2C_READ : I2C_WRITE;
    // $display("Observed operation %0h", op_o);
    if(op_o == I2C_WRITE) ack();
    else if (op_o == I2C_READ) read_ack();
    
    if(observed_address == SLAVE_ADDR) begin
        // $display("Address match");
        address_match_o = 1'b1;
    end

    else begin
        op_o = I2C_INVALID;
        address_match_o = 1'b0;
    end
endtask

task ack ();
    @(negedge scl_i) begin 
            sda_en = 1'b1; //take control of sda
            sda_data = 1'b0; //ack 
        end

    @(negedge scl_i) begin 
        sda_en = 1'b0; 
    end
endtask

task read_ack ();
    @(negedge scl_i) begin 
            sda_en = 1'b1; //take control of sda
            sda_data = 1'b0; //ack 
    end
endtask

task get_i2c_write_data (output bit [DATA_WIDTH-1:0] data_o);
    automatic bit [DATA_WIDTH-1:0] data;
    automatic int iterator;

    iterator = 0;
    data = {DATA_WIDTH{1'b0}};
    repeat (DATA_WIDTH) begin
        @(posedge scl_i) begin
        data = (data | (sda_i << (DATA_WIDTH - 1 - iterator)));         
        iterator = iterator + 1;   
        end
    end
    data_o = data;
    // $display("Data from master %0d", data);
    ack();
endtask

task detect_stop ();
    while(1) begin
        @(posedge sda_i)begin
            if(scl_i == 1'b1)begin
                // $display("I2C stop condition detected");
                return;
            end
        end
    end
endtask

task create_write_fork (output int pid, output bit [DATA_WIDTH-1:0] data);
    fork : write_fork
        begin get_i2c_write_data(data); pid = 1; end
        begin detect_stop(); pid = 2; end
        begin detect_start(); pid = 3; end
    join_any

    disable write_fork;
endtask

task provide_read_data (input bit [DATA_WIDTH-1:0] read_data [], output bit transfer_complete);
    automatic int array_size;
    automatic int read_fork_pid;
    automatic bit ack_success;
    automatic int iterator;

    array_size = read_data.size();
    iterator = 0;

    while(iterator < array_size) begin
        put_i2c_read_byte(read_data[iterator], ack_success);
        if(!ack_success) begin
            if(iterator == array_size-1) transfer_complete = 1'b1;
            else transfer_complete = 1'b0; 

            fork : check_fork
            begin detect_stop(); read_fork_pid = 1; end
            begin detect_start(); read_fork_pid = 2; end
            join_any
            disable check_fork;

            if(read_fork_pid == 1) return;
            
            else if(read_fork_pid == 2) begin skip_start = 1'b1; return; end
                
        end

        iterator = iterator + 1;

    end
    
endtask

task put_i2c_read_byte (input bit [DATA_WIDTH-1:0] data, output bit ack_success_o);
    automatic bit data_bit;
    automatic bit ack_success;
    automatic int iterator;

    iterator = 0;
    repeat (DATA_WIDTH) begin
        @(negedge scl_i) begin 
            sda_en = 1'b1; //take control of sda
            sda_data = data[DATA_WIDTH-iterator-1];
        end

        iterator = iterator + 1;
    end

    @(negedge scl_i) begin 
        sda_en = 1'b0; 
    end

    detect_ack(ack_success);
    ack_success_o = ack_success;

endtask

task detect_ack (output bit success);
    @(posedge scl_i); begin
    if(sda_i == 1'b1) success = 1'b0;
    else if(sda_i == 1'b0) success = 1'b1;
    end

endtask

task monitor (output bit [ADDR_WIDTH-1:0] addr_o, output i2c_op_t op_o, output bit [DATA_WIDTH-1:0] data_o []);
    automatic bit [ADDR_WIDTH-1:0] address;
    automatic i2c_op_t op;
    automatic bit address_match;
    automatic int address_match_fork_pid;
    automatic bit [DATA_WIDTH-1:0] data_byte;
    automatic bit [DATA_WIDTH-1:0] data [$];
    automatic int iterator;
    automatic bit stop_flag;
    stop_flag = 1'b0;

    if (monitor_skip_start == 1'b0) detect_start();
    monitor_skip_start = 1'b0;
    //Get Address and Op
    iterator = 0;
    repeat (ADDR_WIDTH) @(posedge scl_i) begin
        address = ((address | sda_i << ( (ADDR_WIDTH - 1) - iterator)));
        iterator = iterator + 1;
    end

    addr_o = address;
    @(posedge scl_i) op_o = sda_i ? I2C_READ : I2C_WRITE;

    @(posedge scl_i) ; //skip ack cycle

    if(address == SLAVE_ADDR) begin
        while(!stop_flag) begin
            fork : monitor_address_match_fork
            begin 
                iterator = 0;
                data_byte = {DATA_WIDTH{1'b0}};
                repeat (DATA_WIDTH) begin
                    @(posedge scl_i) begin
                    data_byte = (data_byte | (sda_i << (DATA_WIDTH - 1 - iterator)));         
                    iterator = iterator + 1;   
                    end
                end
                address_match_fork_pid = 1;
                @(posedge scl_i) ; //skip ack cycle
            end

            begin detect_stop(); address_match_fork_pid = 2; end

            begin detect_start(); address_match_fork_pid = 3; end
            join_any

            case(address_match_fork_pid)
                        1 : begin data.push_back(data_byte);
                                  address_match_fork_pid = 1; 
                                  continue; 
                            end
                        2 : begin data_o = data; stop_flag = 1'b1; continue; end
                        3 : begin monitor_skip_start = 1'b1; data_o = data; return; end
            endcase
        end
    end

endtask





endinterface