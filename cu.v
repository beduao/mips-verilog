module cu (
    input  wire [5:0] opcode,
    output reg        reg_dst,
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg  [1:0] alu_op
);

    always @(*) begin
        // Valores padrão (Default) para evitar latches
        reg_dst    = 0; alu_src    = 0; mem_to_reg = 0;
        reg_write  = 0; mem_read   = 0; mem_write  = 0;
        branch     = 0; alu_op     = 2'b00;

        case (opcode)
            6'b000000: begin // TIPO R (add, sub, and, or, slt, nor)
                reg_dst    = 1;
                reg_write  = 1;
                alu_op     = 2'b10;
            end
            6'b100011: begin // LW
                alu_src    = 1;
                mem_to_reg = 1;
                reg_write  = 1;
                mem_read   = 1;
                alu_op     = 2'b00;
            end
            6'b101011: begin // SW
                alu_src    = 1;
                mem_write  = 1;
                alu_op     = 2'b00;
            end
            6'b000100: begin // BEQ
                branch     = 1;
                alu_op     = 2'b01;
            end
            default: begin
                // Opcode desconhecido
            end
        endcase
    end

endmodule