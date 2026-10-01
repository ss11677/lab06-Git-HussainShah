// 32-bit ALU for a single-cycle RISC-V processor (RV32I)
// 32 alu1bit slices chained by ripple carry; shifts handled at 32-bit level
//
// ALUControl
//   0000 AND   0001 OR    0010 ADD   0011 XOR
//   0100 SLL   0101 SRL   0110 SUB   1000 BEQ
//   0111 left free for SLT

module ALU(
    input      [31:0] A,
    input      [31:0] B,
    input      [3:0]  ALUControl,
    output     [31:0] ALUResult,
    output            Zero
);

    reg [1:0] Operation;
    reg       Bnegate;
    reg [1:0] outsel;      // 00 slices, 01 SLL, 10 SRL, 11 zero

    always @(*) begin
        case (ALUControl)
            4'b0000: begin Operation = 2'b00; Bnegate = 1'b0; outsel = 2'b00; end
            4'b0001: begin Operation = 2'b01; Bnegate = 1'b0; outsel = 2'b00; end
            4'b0010: begin Operation = 2'b10; Bnegate = 1'b0; outsel = 2'b00; end
            4'b0011: begin Operation = 2'b11; Bnegate = 1'b0; outsel = 2'b00; end
            4'b0100: begin Operation = 2'b00; Bnegate = 1'b0; outsel = 2'b01; end
            4'b0101: begin Operation = 2'b00; Bnegate = 1'b0; outsel = 2'b10; end
            4'b0110: begin Operation = 2'b10; Bnegate = 1'b1; outsel = 2'b00; end
            4'b1000: begin Operation = 2'b10; Bnegate = 1'b1; outsel = 2'b00; end
            default: begin Operation = 2'b00; Bnegate = 1'b0; outsel = 2'b11; end
        endcase
    end

    wire [31:0] slice_result;
    wire [32:0] carry;

    // Bnegate also supplies the +1 that completes two's complement subtraction
    assign carry[0] = Bnegate;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : alu_slice
            alu1bit u_slice(
                .a         (A[i]),
                .b         (B[i]),
                .Binvert   (Bnegate),
                .CarryIn   (carry[i]),
                .Operation (Operation),
                .Result    (slice_result[i]),
                .CarryOut  (carry[i+1])
            );
        end
    endgenerate

    // shift amount is B[4:0] only, per RV32I
    wire [31:0] sll_result = A << B[4:0];
    wire [31:0] srl_result = A >> B[4:0];

    reg [31:0] result_r;

    always @(*) begin
        case (outsel)
            2'b00:   result_r = slice_result;
            2'b01:   result_r = sll_result;
            2'b10:   result_r = srl_result;
            default: result_r = 32'b0;
        endcase
    end

    assign ALUResult = result_r;
    assign Zero      = (ALUResult == 32'b0);

endmodule
