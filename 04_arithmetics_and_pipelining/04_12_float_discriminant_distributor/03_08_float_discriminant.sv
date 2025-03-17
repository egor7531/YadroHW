//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;

    logic [FLEN-1:0]        a_in;
    logic [FLEN-1:0]        b_in;
    logic [FLEN-1:0]        b_2;

    logic               mult_vld_in;
    logic               mult_vld_out;
    logic               mult_err;
    logic [FLEN-1:0]    mult_out;

    logic               sub_vld_in;
    logic               sub_vld_out;
    logic               sub_err;
    logic [FLEN-1:0]    sub_out;


    f_mult i_mult(
        .clk        (clk),
        .rst        (rst),
        .a          (a_in),
        .b          (b_in),
        .up_valid   (mult_vld_in),
        .res        (mult_out),
        .down_valid (mult_vld_out),
        .busy       (),
        .error      (mult_err)
    );

    f_sub i_sub(
        .clk        (clk),
        .rst        (rst),
        .a          (a_in),
        .b          (b_in),
        .up_valid   (sub_vld_in),
        .res        (sub_out),
        .down_valid (sub_vld_out),
        .busy       (),
        .error      (sub_err)
    );

    enum logic [2:0]
    {
        S0      = 3'd0,
        S1_mult = 3'd1,
        S2_mult = 3'd2,
        S3_mult = 3'd3,
        S4_sub  = 3'd4
    } state, next_state;


    always_comb 
    begin
        next_state  = state;
        err         = mult_err | sub_err;

        res         = '0;
        res_vld     = '0;

        a_in        = '0;
        b_in        = '0;
        mult_vld_in = '0;
        sub_vld_in  = '0;

        case (state)
            S0: 
            begin
                if (arg_vld) 
                begin
                    a_in = b;
                    b_in = b;
                    mult_vld_in = '1;

                    next_state = S1_mult;
                end
            end

            S1_mult: 
            begin
                if (mult_vld_out) 
                begin
                    a_in = four;
                    b_in = a;
                    mult_vld_in = '1;

                    next_state = S2_mult;
                end
            end

            S2_mult: 
            begin
                if (mult_vld_out) 
                begin
                    a_in = mult_out;
                    b_in = c;
                    mult_vld_in = '1;

                    next_state = S3_mult;
                end
            end

            S3_mult: 
            begin
                if (mult_vld_out) 
                begin
                    a_in = b_2;
                    b_in = mult_out;
                    sub_vld_in = '1;

                    next_state = S4_sub;
                end
            end

            S4_sub: 
            begin
                if (sub_vld_out) 
                begin
                    res = sub_out;
                    res_vld = '1;

                    next_state = S0;
                end
            end
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
            state <= S0;
        else
            state <= next_state;

    always_ff @ (posedge clk)
        if (rst)
            b_2 <= '0;
        else if ( (state == S1_mult) & mult_vld_out )
            b_2 <= mult_out;

endmodule
