module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    localparam N = 12;

    // circular shift register
    logic [N - 1:0] index;

    always_ff @ (posedge clk)
    begin
        if (rst)
            index <= 1'b1;
        else if(arg_vld)
            index <= {  index[N - 2:0], index[N-1] };
    end
  
    // generating N calculators
    logic arg_vld_copy  [0:N - 1];

    logic [FLEN - 1:0] a_copy [0:N - 1]; 
    logic [FLEN - 1:0] b_copy [0:N - 1];
    logic [FLEN - 1:0] c_copy [0:N - 1];

    logic [N - 1:0]    isqrt_y_vld;
    logic [N - 1:0]    isqrt_y_err;
    logic [FLEN - 1:0] isqrt_y [0:N - 1];

    genvar i;

    generate
        for (i = 0; i < N; i++)
        begin

            // register for arg_vld 
            always_ff @ (posedge clk)
            begin
                if (rst)
                    arg_vld_copy[i] <= 1'b0;
                else if(index[i])
                    arg_vld_copy[i] <= arg_vld;
                else
                    arg_vld_copy[i] <= 1'b0;
            end

            // register for values a,b,c
            always_ff @ (posedge clk)
            begin
                if (rst)
                begin
                    a_copy[i] <= '0;
                    b_copy[i] <= '0;
                    c_copy[i] <= '0;
                end
                else if( arg_vld & index[i] )
                begin
                    a_copy[i] <= a;
                    b_copy[i] <= b;
                    c_copy[i] <= c;
                end
            end

            // instantiating the modules
            float_discriminant i_float_discriminant
            (
                .clk(clk),
                .rst(rst),

                .arg_vld(arg_vld_copy[i]),
                .a(a_copy[i]),
                .b(b_copy[i]),
                .c(c_copy[i]),

                .res_vld(isqrt_y_vld[i]),
                .res(isqrt_y[i]),
                .err(isqrt_y_err[i])
            );
        end
    endgenerate

    // get results
    logic [FLEN - 1:0] res_copy;

    always_comb 
    begin
        for (int i = 0; i < N; i++)
            if(isqrt_y_vld[i])
                res_copy = isqrt_y[i];
    end

    assign res     = res_copy;
    assign res_vld = | isqrt_y_vld;
    assign err     = | isqrt_y_err;

endmodule
