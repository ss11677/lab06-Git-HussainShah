// Lab 6 Task 3 top level
// One button press advances the FSM: IDLE -> EXEC -> SHOW -> IDLE
// LED view from sw[15:14]: 00 low half, 01 high half, 1x status word

module top_alu(
    input         clk,
    input         btnC,
    input         btnU,
    input  [15:0] sw,
    output [15:0] led
);

    localparam [31:0] OPERAND_A = 32'h10101010;
    localparam [31:0] OPERAND_B = 32'h01010101;

    localparam [1:0] S_IDLE = 2'b00,
                     S_EXEC = 2'b01,
                     S_SHOW = 2'b10;

    wire rst_db;
    wire step_db;

    debouncer u_db_rst (.clk(clk), .pbin(btnC), .pbout(rst_db));
    debouncer u_db_step(.clk(clk), .pbin(btnU), .pbout(step_db));

    // rising edge detect, so a held button steps the FSM only once
    reg step_q;
    always @(posedge clk)
        step_q <= step_db;

    wire step_pulse = step_db & ~step_q;

    reg  [3:0]  alu_ctrl_q;
    wire [31:0] alu_result;
    wire        alu_zero;

    ALU u_alu(
        .A          (OPERAND_A),
        .B          (OPERAND_B),
        .ALUControl (alu_ctrl_q),
        .ALUResult  (alu_result),
        .Zero       (alu_zero)
    );

    reg [1:0]  state;
    reg [31:0] result_q;
    reg        zero_q;

    always @(posedge clk) begin
        if (rst_db) begin
            state      <= S_IDLE;
            alu_ctrl_q <= 4'b0000;
            result_q   <= 32'b0;
            zero_q     <= 1'b0;
        end
        else if (step_pulse) begin
            case (state)
                S_IDLE: begin
                    alu_ctrl_q <= sw[3:0];
                    state      <= S_EXEC;
                end
                S_EXEC: begin
                    result_q <= alu_result;
                    zero_q   <= alu_zero;
                    state    <= S_SHOW;
                end
                S_SHOW: begin
                    state <= S_IDLE;
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

    reg [15:0] led_r;

    always @(*) begin
        if (state == S_SHOW) begin
            case (sw[15:14])
                2'b00:   led_r = result_q[15:0];
                2'b01:   led_r = result_q[31:16];
                default: led_r = {zero_q, 9'b0, state, alu_ctrl_q};
            endcase
        end
        else begin
            led_r = {zero_q, 9'b0, state, alu_ctrl_q};
        end
    end

    assign led = led_r;

endmodule
