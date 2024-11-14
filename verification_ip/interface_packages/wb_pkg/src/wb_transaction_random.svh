class wb_transaction_random extends wb_transaction;
  `ncsu_register_object(wb_transaction_random)
  rand bit [WB_DATA_WIDTH-1:0] wb_data_random;
  
  function new(string name="");
    super.new(name);
  endfunction

  virtual function void put_randomized_data();
    wb_data = wb_data_random;
  endfunction

endclass