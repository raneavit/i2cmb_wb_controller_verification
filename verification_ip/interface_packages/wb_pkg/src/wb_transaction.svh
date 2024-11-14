class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)

    bit [WB_ADDR_WIDTH-1:0] wb_addr;
    bit [WB_DATA_WIDTH-1:0] wb_data;
    wb_op_t wb_op;

    static logic interrup_from_dut = 0;

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return {super.convert2string(),$sformatf("Wishbone addr:0x%x :: Wishbone data:0x%x", wb_addr, wb_data)};
    endfunction

    virtual function bit compare (wb_transaction rhs);
        return  ((this.wb_addr == rhs.wb_addr) &&
                (this.wb_data == rhs.wb_data));
    endfunction

    virtual function void set_data(bit [WB_DATA_WIDTH-1:0] data);
        this.wb_data = data;
    endfunction

    virtual function void get_data(output bit [WB_DATA_WIDTH-1:0] data);
        data = this.wb_data;
    endfunction

    virtual function void set_addr(bit [WB_ADDR_WIDTH-1:0] addr);
        this.wb_addr = addr;
    endfunction

    virtual function bit [WB_ADDR_WIDTH-1:0] get_addr();
        return this.wb_addr;
    endfunction

    virtual function void set_op(wb_op_t op);
        this.wb_op = op;
    endfunction

    virtual function wb_op_t get_op();
        return this.wb_op;
    endfunction

endclass
