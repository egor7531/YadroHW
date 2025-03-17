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

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  wire gap;

  mux not_b
  (
    .sel(b),
    .d1(0), .d0(1),
    .y(gap)
  );

  mux mux_xor
  (
    .sel(a),
    .d1(gap), .d0(b),
    .y(o)
  );

endmodule
