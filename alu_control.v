module alu_control (
    input  wire [1:0] alu_op,      // Vem da Control Unit
    input  wire [5:0] funct,       // Vem da Instrução [5:0]
    output reg  [3:0] alu_ctrl     // Vai para a sua alu_32
);

    always @(*) begin
        // Valor padrão para evitar latches
        alu_ctrl = 4'b0000;

        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // LW/SW -> Soma (ADD)
            2'b01: alu_ctrl = 4'b0110; // BEQ   -> Subtração (SUB)
            2'b10: begin               // Tipo-R -> Olha o Funct
                case (funct)
                    6'b000000: alu_ctrl = 4'b0011; // SLL
                    6'b000010: alu_ctrl = 4'b0100; // SRL
                    6'b100000: alu_ctrl = 4'b0010; // ADD
                    6'b100010: alu_ctrl = 4'b0110; // SUB
                    6'b100100: alu_ctrl = 4'b0000; // AND
                    6'b100101: alu_ctrl = 4'b0001; // OR
                    6'b101010: alu_ctrl = 4'b0111; // SLT
                    6'b100111: alu_ctrl = 4'b1100; // NOR
                    default:   alu_ctrl = 4'b0000; 
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule