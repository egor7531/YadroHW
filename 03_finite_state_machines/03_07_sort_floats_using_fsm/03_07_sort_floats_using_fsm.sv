//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    logic [0:2][FLEN-1:0] array;

    enum logic [2:0]
    {
        S0 = 3'd0,
        S1 = 3'd1,
        S2 = 3'd2,
        S3 = 3'd3,
        S4 = 3'd4
    } state, next_state;

    always_comb 
    begin
        next_state = state;
        array      = sorted;

        err = f_le_err;

        f_le_a = '0;
        f_le_b = '0;

        valid_out = err;

        case (state)
            S0: 
            begin
                if (valid_in) 
                begin
                    next_state = S1;
                    array = unsorted;
                end
            end

            S1: 
            begin
                f_le_a = sorted[0];
                f_le_b = sorted[1];

                if (~f_le_res)
                    array = { sorted [1] , sorted [0], sorted [2] };
                
                next_state = S2;
            end

            S2:                                                                 // after state S2, the largest element will be in 3rd place.
            begin
                f_le_a = sorted[1];
                f_le_b = sorted[2];

                if (~f_le_res)
                    array = { sorted [0] , sorted [2], sorted [1] };

                next_state = S3;
            end

            S3:
            begin
                f_le_a = sorted[0];
                f_le_b = sorted[1];

                if (~f_le_res)
                    array = { sorted [1], sorted [0], sorted[2] };

                next_state = S4;
            end

            S4: 
            begin
                valid_out = '1;
                next_state = S0;
            end
        endcase
    end

    always_ff @ (posedge clk)
        if (rst | err)
        begin
            state  <= S0;
            sorted <= {'0, '0, '0};
        end
        else
        begin
            state  <= next_state;
            sorted <= array;
        end
            
endmodule

