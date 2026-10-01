`timescale 1ns / 1ps
// Exhaustive testbench for the 1-bit ALU slice.
// The slice has six input bits, so all 64 combinations are applied.
// Expected values are recomputed here rather than taken from the design.

module alu1bit_tb;

    reg        a, b, Binvert, CarryIn;
    reg  [1:0] Operation;
    wire       Result, CarryOut;

    integer    i;
    integer    errors;

    reg        b_mux;
    reg  [1:0] exp_add;
    reg        exp_result;

    alu1bit dut(
        .a         (a),
        .b         (b),
        .Binvert   (Binvert),
        .CarryIn   (CarryIn),
        .Operation (Operation),
        .Result    (Result),
        .CarryOut  (CarryOut)
    );

    initial begin
        errors = 0;

        $display("Op  Binv Cin  a b | Result CarryOut");

        for (i = 0; i < 64; i = i + 1) begin
            {Operation, CarryIn, Binvert, b, a} = i[5:0];
            #5;

            b_mux   = Binvert ? ~b : b;
            exp_add = a + b_mux + CarryIn;

            case (Operation)
                2'b00: exp_result = a & b_mux;
                2'b01: exp_result = a | b_mux;
                2'b10: exp_result = exp_add[0];
                2'b11: exp_result = a ^ b_mux;
            endcase

            if (Result === exp_result && CarryOut === exp_add[1])
                $display("%b   %b    %b    %b %b |   %b      %b        PASS",
                         Operation, Binvert, CarryIn, a, b, Result, CarryOut);
            else begin
                errors = errors + 1;
                $display("%b   %b    %b    %b %b |   %b      %b        FAIL (exp %b %b)",
                         Operation, Binvert, CarryIn, a, b,
                         Result, CarryOut, exp_result, exp_add[1]);
            end
        end

        if (errors == 0)
            $display("=== ALL 64 1-BIT ALU CASES PASSED ===");
        else
            $display("=== %0d OF 64 CASES FAILED ===", errors);

        $finish;
    end

endmodule
