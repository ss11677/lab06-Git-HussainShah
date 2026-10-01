// 1-bit ALU slice
// Operation: 00 AND, 01 OR, 10 ADD/SUB, 11 XOR
// Subtraction uses Binvert = 1 together with CarryIn = 1 at bit 0

module alu1bit(
    input        a,
    input        b,
    input        Binvert,
    input        CarryIn,
    input  [1:0] Operation,
    output       Result,
    output       CarryOut
);

    wire b_n, nBinvert, m0, m1, b_mux;
    wire and_out, or_out, xor_out, sum_out;

    // 2-to-1 mux selecting b or ~b
    notGate n0(.a(b),       .y(b_n));
    notGate n1(.a(Binvert), .y(nBinvert));
    andGate m_0(.a(b),   .b(nBinvert), .y(m0));
    andGate m_1(.a(b_n), .b(Binvert),  .y(m1));
    orGate  m_or(.a(m0), .b(m1),       .y(b_mux));

    andGate gAND(.a(a), .b(b_mux), .y(and_out));
    orGate  gOR (.a(a), .b(b_mux), .y(or_out));
    xorGate gXOR(.a(a), .b(b_mux), .y(xor_out));

    fullAdder u_fa(
        .a    (a),
        .b    (b_mux),
        .cin  (CarryIn),
        .sum  (sum_out),
        .cout (CarryOut)
    );

    mux4to1 u_mux(
        .d0  (and_out),
        .d1  (or_out),
        .d2  (sum_out),
        .d3  (xor_out),
        .sel (Operation),
        .y   (Result)
    );

endmodule
