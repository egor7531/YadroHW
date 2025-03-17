//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  localparam logic signed [3:0] MAX_POS_VALUE = 4'sb0111;
  localparam logic signed [3:0] MAX_NEG_VALUE = 4'sb1000;

  logic overflow;
  logic signed [3:0] sum_copy;

  assign sum_copy = a + b;
  assign overflow = (a[3] == b[3]) && (a[3] != sum_copy[3]);

  assign sum = overflow ? (sum_copy[3] ? MAX_POS_VALUE : MAX_NEG_VALUE) : sum_copy;

endmodule
