// 1-bit 4-to-1 multiplexor built from the basic gates
// sel: 00 -> d0, 01 -> d1, 10 -> d2, 11 -> d3

module mux4to1(
    input        d0,
    input        d1,
    input        d2,
    input        d3,
    input  [1:0] sel,
    output       y
);

    wire ns0, ns1;
    wire e0, e1, e2, e3;
    wire p0, p1, p2, p3;
    wire or1, or2;

    notGate n0(.a(sel[0]), .y(ns0));
    notGate n1(.a(sel[1]), .y(ns1));

    // one-hot enables decoded from the two select bits
    andGate d_0(.a(ns1),    .b(ns0),    .y(e0));
    andGate d_1(.a(ns1),    .b(sel[0]), .y(e1));
    andGate d_2(.a(sel[1]), .b(ns0),    .y(e2));
    andGate d_3(.a(sel[1]), .b(sel[0]), .y(e3));

    andGate g0(.a(d0), .b(e0), .y(p0));
    andGate g1(.a(d1), .b(e1), .y(p1));
    andGate g2(.a(d2), .b(e2), .y(p2));
    andGate g3(.a(d3), .b(e3), .y(p3));

    orGate o1(.a(p0),  .b(p1),  .y(or1));
    orGate o2(.a(p2),  .b(p3),  .y(or2));
    orGate o3(.a(or1), .b(or2), .y(y));

endmodule
