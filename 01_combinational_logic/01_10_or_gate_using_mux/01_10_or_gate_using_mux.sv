//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module or_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:

  // Implement or gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  wire gap;

  mux mux_or
  (
    .sel(a),
    .d1(1), .d0(b),
    .y(o)
  );

endmodule
