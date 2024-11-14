class i2c_transaction_random extends i2c_transaction;
	`ncsu_register_object(i2c_transaction_random)
    rand bit[I2C_DATA_WIDTH-1:0] i2c_data_random[];
	constraint transfer_size { 0 < i2c_data_random.size() && i2c_data_random.size() <= 32; }

    function new(string name="");
    super.new(name);
    endfunction

    virtual function put_randomized_data();
    i2c_data = i2c_data_random;
    endfunction
endclass