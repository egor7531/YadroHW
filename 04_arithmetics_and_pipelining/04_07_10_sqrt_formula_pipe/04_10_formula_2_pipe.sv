//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    localparam n_pipe_stages = 4;

    // for isqrt in 
    logic [31:0] sqrt_2_in,     sqrt_3_in;
    logic        sqrt_vld_2_in, sqrt_vld_3_in; 
    // for isqrt out
    logic [15:0] sqrt_1_out,   sqrt_2_out;    
    logic        sqrt_vld_1_out, sqrt_vld_2_out;
    // for shift register
    logic [31:0] out_a,     out_b;
    logic        out_vld_a, out_vld_b;

    shift_register_with_valid
    # ( .width (32), .depth (n_pipe_stages) )
    i_shift_register_with_valid_b
    (
        .clk      ( clk      ),
        .rst      ( rst      ),

        .in_vld   ( arg_vld  ),
        .in_data  ( b        ),

        .out_vld  ( out_vld_b),
        .out_data ( out_b    )
    );

    shift_register_with_valid
    # ( .width (32), .depth (2 * n_pipe_stages + 1) )
    i_shift_register_with_valid_a
    (
        .clk      ( clk      ),
        .rst      ( rst      ),

        .in_vld   ( arg_vld  ),
        .in_data  ( a        ),

        .out_vld  ( out_vld_a),
        .out_data ( out_a    )
    );

    isqrt #(.n_pipe_stages(n_pipe_stages)) isqrt1
    (
        .clk(clk),
        .rst(rst),

        .x_vld(arg_vld),
        .x(c),

        .y_vld(sqrt_vld_1_out),
        .y(sqrt_1_out)
    );

    isqrt #(.n_pipe_stages(n_pipe_stages)) isqrt2
    (
        .clk(clk),
        .rst(rst),

        .x_vld(sqrt_vld_2_in),
        .x(sqrt_2_in),

        .y_vld(sqrt_vld_2_out),
        .y(sqrt_2_out)
    );

    isqrt #(.n_pipe_stages(n_pipe_stages)) isqrt3
    (
        .clk(clk),
        .rst(rst),

        .x_vld(sqrt_vld_3_in),
        .x(sqrt_3_in),

        .y_vld(res_vld),
        .y(res)
    );

    always_ff @(posedge clk)
    begin
        if(sqrt_vld_1_out & out_vld_b)
        begin
            sqrt_2_in      <= sqrt_1_out + out_b;
            sqrt_vld_2_in  <= '1;
        end
        else
            sqrt_vld_2_in  <= '0;

        if(sqrt_vld_2_out & out_vld_a)
        begin
            sqrt_3_in      <= sqrt_2_out + out_a;
            sqrt_vld_3_in  <= '1;
        end
        else
            sqrt_vld_3_in  <= '0;
    end

endmodule
