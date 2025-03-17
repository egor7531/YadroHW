module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    logic [ width : 0 ]       data [n_inputs];                  // store vld in [0], and up_data in the other bits.

    logic                     down_vld_copy;
    logic [ width   - 1 : 0 ] down_data_copy;

    // put
    always_ff @(posedge clk) 
    begin
        if(rst)
        begin
            for(int i = 0; i < n_inputs; i++)
                data[i] <= '0;
        end

        else 
        begin
            for(int i = 0; i < n_inputs; i++)
                if(up_vlds[i])
                    data[i] <= { up_data[i], 1'b1};
        end
    end 

    // get
    int cnt = 0;
    always_ff @(posedge clk) 
    begin
        if(rst)
            down_vld_copy <= '0;
        else 
        begin
            if(data[cnt][0])
            begin
                down_vld_copy  <= '1;
                down_data_copy <= data[cnt][width : 1];

                data[cnt] <= '0;                            // reset 

                cnt++;
            end
            else
                down_vld_copy  <= '0;
            
            if(cnt == n_inputs)
                cnt <= 0;
        end
    end 

    assign down_vld  = down_vld_copy;
    assign down_data = down_data_copy;

endmodule
