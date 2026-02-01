module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    input  wire [4:0]  shamt,
    output reg  [31:0] result,
    output wire        zero,
    output reg         carry_out,
    output reg         overflow
);

    // Fio auxiliar para capturar o carry (33 bits para pegar o bit extra)
    wire [32:0] sum_extended;
    wire [32:0] sub_extended;

    // Cálculos auxiliares para carry e overflow
    assign sum_extended = {1'b0, a} + {1'b0, b};
    assign sub_extended = {1'b0, a} - {1'b0, b};

    always @(*) begin
        // Valores padrão para evitar latches
        result    = 32'd0;
        carry_out = 1'b0;
        overflow  = 1'b0;

        case (alu_ctrl)
            4'b0000: result = a & b;           // AND
            4'b0001: result = a | b;           // OR

            4'b0010: begin                    // ADD
                result    = a + b;
                carry_out = sum_extended[32];
                // Overflow: sinais iguais somados resultam em sinal diferente
                overflow  = (~(a[31] ^ b[31])) & (a[31] ^ result[31]);
            end

            4'b0011: result = b << shamt; // SLL (shift left logical)
            4'b0100: result = b >> shamt; // SRL
            
            4'b0110: begin                    // SUB
                result    = a - b;
                carry_out = sub_extended[32];
                // Overflow: sinais diferentes subtraídos, resultado difere do minuendo
                overflow  = (a[31] ^ b[31]) & (a[31] ^ result[31]);
            end

            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b1100: result = ~(a | b);        // NOR
            
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);

endmodule