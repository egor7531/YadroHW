module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    localparam N = (formula == 1) ? ( (impl == 1) ? 13 : 33 ) : 48;

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

    logic [31:0] a_copy [0:N - 1]; 
    logic [31:0] b_copy [0:N - 1];
    logic [31:0] c_copy [0:N - 1];

    logic [31:0]    isqrt_y [0:N - 1];
    logic [N - 1:0] isqrt_y_vld;

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
            if(formula == 1 && impl == 1)             
            formula_1_impl_1_top i_formula_1_impl_1_top
            (
                .clk(clk),
                .rst(rst),

                .arg_vld(arg_vld_copy[i]),
                .a(a_copy[i]),
                .b(b_copy[i]),
                .c(c_copy[i]),

                .res_vld(isqrt_y_vld[i]),
                .res(isqrt_y[i])
            );

            else if(formula == 1 && impl == 2)             
            formula_1_impl_2_top i_formula_1_impl_2_top
            (
                .clk(clk),
                .rst(rst),

                .arg_vld(arg_vld_copy[i]),
                .a(a_copy[i]),
                .b(b_copy[i]),
                .c(c_copy[i]),

                .res_vld(isqrt_y_vld[i]),
                .res(isqrt_y[i])
            );

            else             
            formula_2_top i_formula_2_top
            (
                .clk(clk),
                .rst(rst),

                .arg_vld(arg_vld_copy[i]),
                .a(a_copy[i]),
                .b(b_copy[i]),
                .c(c_copy[i]),

                .res_vld(isqrt_y_vld[i]),
                .res(isqrt_y[i])
            );
        end
    endgenerate

    logic [31:0] res_copy;

    // get results
    always_comb 
    begin
        for (int i = 0; i < N; i++)
            if(isqrt_y_vld[i])
                res_copy = isqrt_y[i];
    end

    assign res     = res_copy;
    assign res_vld = | isqrt_y_vld;

endmodule
