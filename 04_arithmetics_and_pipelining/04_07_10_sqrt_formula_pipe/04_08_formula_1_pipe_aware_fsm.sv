//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [31:0] c_copy;

    // FSM
    enum logic [1:0]
    {
        ISQRT_A = 2'd0,
        ISQRT_B = 2'd1,
        ISQRT_C = 2'd2
    } state, next_state;

    always_comb 
    begin
        case (state)
            ISQRT_A: 
            begin   
                isqrt_x_vld = '0;
                if(arg_vld)
                begin
                    isqrt_x_vld = '1;
                    isqrt_x     = a;

                    next_state  = ISQRT_B; 
                end
            end

            ISQRT_B: 
            begin
                isqrt_x_vld = '1;
                isqrt_x     = b;

                next_state  = ISQRT_C; 
            end

            ISQRT_C: 
            begin
                isqrt_x_vld = '1;
                isqrt_x     = c_copy; 

                next_state  = ISQRT_A; 
            end
        endcase
    end

    always_ff @ (posedge clk)
    begin
        if (rst)
            state <= ISQRT_A;
        else
            state <= next_state;
    end

    always_ff @ (posedge clk)
    begin
        if(state == ISQRT_A)
            c_copy <= c;
    end

    logic [1:0] cnt;

    always_ff @(posedge clk)
    begin
        if(~isqrt_y_vld)
        begin
            res <= '0;
            cnt   <= '0;
        end
        else
        begin
            res <= res + isqrt_y;
            cnt++;
        end
    end

    assign res_vld = (cnt == 3) ? '1 : '0;

endmodule
