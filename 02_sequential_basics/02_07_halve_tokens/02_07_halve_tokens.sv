//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input clk,
    input rst,
    input a,
    output reg b
);

    reg [1:0] count;

    always_ff @ ( posedge clk or posedge rst) begin
        if(rst) begin
            count <= 0;
            b <= 0;
        end else begin
            if(a == 1)  begin
                count <= count + 1;
                if(count == 1) begin
                    b <= 1;
                    count <= 0;
                end else begin
                    b <= 0;
                end
            end else begin
                b <= 0;
            end
        end
    end
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101


endmodule
