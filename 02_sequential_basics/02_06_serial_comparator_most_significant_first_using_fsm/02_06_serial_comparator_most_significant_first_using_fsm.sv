//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_comparator_least_significant_first_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // States
  enum logic[1:0]
  {
     st_equal       = 2'b00,
     st_a_less_b    = 2'b01,
     st_a_greater_b = 2'b10
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    case (state)
      st_equal       : if (~ a &   b) new_state = st_a_less_b;
                  else if (  a & ~ b) new_state = st_a_greater_b;
      st_a_less_b    : if (  a & ~ b) new_state = st_a_greater_b;
      st_a_greater_b : if (~ a &   b) new_state = st_a_less_b;
    endcase
  end

  // Output logic
  assign a_eq_b      = (a == b) & (state == st_equal);
  assign a_less_b    = (~ a &   b) | (a == b & state == st_a_less_b);
  assign a_greater_b = (  a & ~ b) | (a == b & state == st_a_greater_b);

  always_ff @ (posedge clk)
    if (rst)
      state <= st_equal;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_comparator_most_significant_first_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

parameter [1:0] s0_eq = 2'b00, s1_less = 2'b01, s2_great = 2'b10;
reg[1:0] state, next_state;

always_comb
begin
  next_state = state;

  case (state)
	  s0_eq         : if (~ a &   b)  next_state = s1_less;
				      else	if (  a & ~ b)  next_state = s2_great;
	  s1_less       : if (  a & ~ b)  next_state = s1_less;
	  s2_great      : if (~ a &   b)  next_state = s2_great;
  endcase
end

assign a_eq_b      = (a == b) & state == s0_eq;
assign a_less_b    = (state == s1_less)  | (state == s0_eq & (~ a & b));
assign a_greater_b = (state == s2_great) | (state == s0_eq & (a & ~ b));

always @ (posedge clk)
  if(rst)
    state <= s0_eq;
  else
    state <= next_state;

endmodule