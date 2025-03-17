//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  logic a_r, a_r1;
  logic sm1;
  
  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;
  
  always_ff @ (posedge clk)
    if(rst)
      a_r1 <= '0;
    else if (sm1)
      a_r1 <= a;
    else
      a_r1 <= '0;

  assign sm1 = ~a_r & a;
  assign detected = a_r1 & ~a;

endmodule
