//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);

    logic [7:0] mx = 8'd0;

    always_ff @(posedge clk) begin
        if(rst) begin
            mx = 8'd0;
            overflow = 1'd0;
        end
        else begin
            if(~overflow) begin
                if(a) mx = mx + 8'd1;
                else if (~a & (mx !== 8'd0)) begin
                    mx = mx - 8'd1;
                end
            end
            if(mx == 8'd200) begin
                overflow = 1'd1;
            end
        end
    end

    assign b = a | (mx > 8'd0);


    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110


endmodule
