`timescale 1ns / 10ps
class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

    virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH)) i2c_bus;

    i2c_configuration i2c_config;
    i2c_transaction i2c_trans;
    ncsu_component#(T) agent;

    function new(string name="", ncsu_component_base parent=null);
        super.new(name, parent);
    endfunction

    function void set_configuration(i2c_configuration cfg);
        i2c_config = cfg;
    endfunction

    function void set_agent(ncsu_component#(T) agent);
        this.agent = agent;
    endfunction

    virtual task run();
        forever begin
                $cast(i2c_trans, ncsu_object_factory::create("i2c_transaction"));
                i2c_bus.monitor(i2c_trans.i2c_addr, i2c_trans.i2c_op, i2c_trans.i2c_data);
                
                // if(i2c_trans.i2c_op == I2C_READ) begin
                //     $display("---------------------------------");
                //     $display("I2C_BUS READ Transfer :: Slave Address: %0h  :: Data: %p",i2c_trans.i2c_addr, i2c_trans.i2c_data);
                //     $display("---------------------------------");
                // end

                // else if(i2c_trans.i2c_op == I2C_WRITE) begin
                //     $display("---------------------------------");
                //     $display("I2C_BUS WRITE Transfer :: Slave Address: %0h  :: Data: %p",i2c_trans.i2c_addr, i2c_trans.i2c_data);
                //     $display("---------------------------------");
                // end

                this.agent.nb_put(i2c_trans);
            end
    endtask

endclass
