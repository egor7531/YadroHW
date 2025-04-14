//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
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
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
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
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 04_10_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    localparam N_PIPE_STAGES = 3;

    logic [31:0]  out_a, out_b;
    // for isqrt in 
    logic [31:0] sqrt_2_in,     sqrt_3_in;
    logic        sqrt_vld_2_in, sqrt_vld_3_in; 
    // for isqrt out
    logic [15:0] sqrt_1_out,     sqrt_2_out;    
    logic        sqrt_vld_1_out, sqrt_vld_2_out;

    flip_flop_fifo_with_counter
    # ( .width (32), .depth (N_PIPE_STAGES) )
    i_flip_flop_fifo_with_counter_b
    (
        .clk        ( clk           ),
        .rst        ( rst           ),

        .push       ( arg_vld       ),
        .pop        ( sqrt_vld_1_out),

        .write_data ( b             ),
        .read_data  ( out_b         )
    );

    flip_flop_fifo_with_counter
    # ( .width (32), .depth (2 * N_PIPE_STAGES + 1) )
    i_flip_flop_fifo_with_counter_a
    (
        .clk        ( clk           ),
        .rst        ( rst           ),

        .push       ( arg_vld       ),
        .pop        ( sqrt_vld_2_out),

        .write_data ( a             ),
        .read_data  ( out_a         )
    );

    isqrt #(.n_pipe_stages(N_PIPE_STAGES)) isqrt1
    (
        .clk(clk),
        .rst(rst),

        .x_vld(arg_vld),
        .x(c),

        .y_vld(sqrt_vld_1_out),
        .y(sqrt_1_out)
    );

    isqrt #(.n_pipe_stages(N_PIPE_STAGES)) isqrt2
    (
        .clk(clk),
        .rst(rst),

        .x_vld(sqrt_vld_2_in),
        .x(sqrt_2_in),

        .y_vld(sqrt_vld_2_out),
        .y(sqrt_2_out)
        );

    isqrt #(.n_pipe_stages(N_PIPE_STAGES)) isqrt3
    (
        .clk(clk),
        .rst(rst),

        .x_vld(sqrt_vld_3_in),
        .x(sqrt_3_in),

        .y_vld(res_vld),
        .y(res)
    );

    // for valid
    always_ff @(posedge clk) begin   
        if(rst) begin
            sqrt_vld_2_in <= 1'b0;
            sqrt_vld_3_in <= 1'b0;      
        end
        else begin
            sqrt_vld_2_in <= sqrt_vld_1_out ? 1'b1 : 1'b0;
            sqrt_vld_3_in <= sqrt_vld_2_out ? 1'b1 : 1'b0;
        end
    end
    
    // for data
    always_ff @(posedge clk) begin   
        if(sqrt_vld_1_out)
            sqrt_2_in <= sqrt_1_out + out_b;

        if(sqrt_vld_2_out)
            sqrt_3_in <= sqrt_2_out + out_a;
    end

endmodule
