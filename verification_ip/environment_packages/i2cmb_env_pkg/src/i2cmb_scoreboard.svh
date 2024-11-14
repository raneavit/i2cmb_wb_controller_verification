class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));

i2c_transaction expected_trans;
i2c_transaction sent_trans; //empty transaction for transport

function new(string name="", ncsu_component_base parent=null);
	super.new(name,parent);
endfunction

virtual function void nb_transport(input T input_trans, output T output_trans);

        $display({get_full_name()," nb_transport: expected transaction ",input_trans.convert2string()});
        expected_trans = input_trans;
        output_trans = sent_trans;

endfunction

virtual function void nb_put(i2c_transaction trans);

        $display({get_full_name()," nb_put: actual transaction ",trans.convert2string()});
        if ( expected_trans.compare(trans) ) $display({get_full_name()," i2c_transaction MATCH!"});
        else                                 $display({get_full_name()," i2c_transaction MISMATCH!"}); 
        $display("");

endfunction


endclass
