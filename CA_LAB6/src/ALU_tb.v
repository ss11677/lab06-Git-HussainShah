`timescale 1ns / 1ps
// Testbench for the 32-bit ALU
// Applies every operation to A = 0x10101010, B = 0x01010101 and checks
// ALUResult and Zero against hand-computed values.
// B[4:0] = 1, so SLL and SRL shift by one position.

module ALU_tb;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire        Zero;

    integer errors;

    ALU dut(
        .A          (A),
        .B          (B),
        .ALUControl (ALUControl),
        .ALUResult  (ALUResult),
        .Zero       (Zero)
    );

    // names padded to 6 characters so they print aligned
    task check;
        input [8*6:1] name;
        input [31:0]  expResult;
        input         expZero;
        begin
            #10;
            if (ALUResult === expResult && Zero === expZero)
                $display("PASS  %0s  A=%h B=%h ctrl=%b -> %h Zero=%b",
                         name, A, B, ALUControl, ALUResult, Zero);
            else begin
                errors = errors + 1;
                $display("FAIL  %0s  A=%h B=%h ctrl=%b -> %h Zero=%b  expected %h Zero=%b",
                         name, A, B, ALUControl, ALUResult, Zero, expResult, expZero);
            end
        end
    endtask

    initial begin
        errors = 0;

        A = 32'h10101010;
        B = 32'h01010101;

        ALUControl = 4'b0000;  check("AND   ", 32'h00000000, 1'b1);
        ALUControl = 4'b0001;  check("OR    ", 32'h11111111, 1'b0);
        ALUControl = 4'b0010;  check("ADD   ", 32'h11111111, 1'b0);
        ALUControl = 4'b0011;  check("XOR   ", 32'h11111111, 1'b0);
        ALUControl = 4'b0100;  check("SLL   ", 32'h20202020, 1'b0);
        ALUControl = 4'b0101;  check("SRL   ", 32'h08080808, 1'b0);
        ALUControl = 4'b0110;  check("SUB   ", 32'h0F0F0F0F, 1'b0);
        ALUControl = 4'b1000;  check("BEQ   ", 32'h0F0F0F0F, 1'b0);

        // equal operands must raise Zero
        A = 32'h10101010;
        B = 32'h10101010;
        ALUControl = 4'b1000;  check("BEQ_EQ", 32'h00000000, 1'b1);

        // shift uses B[4:0] only
        A = 32'h00000001;
        B = 32'h0000001F;
        ALUControl = 4'b0100;  check("SLL_31", 32'h80000000, 1'b0);

        A = 32'h80000000;
        B = 32'hFFFFFFE1;
        ALUControl = 4'b0101;  check("SRL_1 ", 32'h40000000, 1'b0);

        // subtraction that borrows across all 32 slices
        A = 32'h00000000;
        B = 32'h00000001;
        ALUControl = 4'b0110;  check("SUB_NG", 32'hFFFFFFFF, 1'b0);

        ALUControl = 4'b1111;  check("UNUSED", 32'h00000000, 1'b1);

        if (errors == 0)
            $display("=== ALL ALU TESTS PASSED ===");
        else
            $display("=== %0d ALU TEST(S) FAILED ===", errors);

        $finish;
    end

endmodule
