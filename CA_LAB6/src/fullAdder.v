// 1-bit full adder built from the basic gates
// sum  = a ^ b ^ cin
// cout = (a.b) + (a.cin) + (b.cin)

module fullAdder(
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    wire axb;
    wire ab, acin, bcin;
    wire or1;

    xorGate x1(.a(a),   .b(b),   .y(axb));
    xorGate x2(.a(axb), .b(cin), .y(sum));

    andGate a1(.a(a), .b(b),   .y(ab));
    andGate a2(.a(a), .b(cin), .y(acin));
    andGate a3(.a(b), .b(cin), .y(bcin));

    orGate  o1(.a(ab),  .b(acin), .y(or1));
    orGate  o2(.a(or1), .b(bcin), .y(cout));

endmodule
