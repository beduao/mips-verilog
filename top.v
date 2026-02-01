module top (
    input wire clk,
    input wire reset
);

    // ==========================================
    // 1. DECLARAÇÃO DOS FIOS (INTERCONEXÕES)
    // ==========================================
    
    // PC e Instrução
    reg  [31:0] pc;
    wire [31:0] pc_next, pc_plus4, pc_branch;
    wire [31:0] instruction;

    wire [4:0] shamt;

    // Sinais de Controle (Saídas da Unidade de Controle)
    wire reg_dst, branch, mem_read, mem_to_reg;
    wire [1:0] alu_op;
    wire mem_write, alu_src, reg_write;

    // Banco de Registradores
    wire [31:0] read_data1, read_data2;
    wire [31:0] write_data;      // Dado que volta para ser escrito
    wire [4:0]  write_reg_addr;  // Endereço de escrita escolhido (rd ou rt)

    // ALU e Extensão de Sinal
    wire [31:0] sign_ext_imm;
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [3:0]  alu_control_sig;
    wire zero_flag;

    // Memória de Dados
    wire [31:0] mem_read_data;

    //jal
    wire op_jal  = (instruction[31:26] == 6'b000011);
    wire op_j    = (instruction[31:26] == 6'b000010);
    wire is_jump = op_jal | op_j;

    // Lógica de Branch
    wire pc_src; // Decide se pula ou não (Branch & Zero)

    // ==========================================
    // 2. ESTÁGIO DE BUSCA (FETCH)
    // ==========================================

    wire is_jr = (instruction[31:26] == 6'b000000) && (instruction[5:0] == 6'b001000);

    
    // Lógica do PC 
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

    // Somador simples (PC + 4)
    assign pc_plus4 = pc + 4;

    // Memória de Instruções 
    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );

    // ==========================================
    // 3. ESTÁGIO DE DECODIFICAÇÃO E CONTROLE
    // ==========================================

    wire [31:0] jump_addr = {pc_plus4[31:28], instruction[25:0], 2'b00};
    assign shamt = instruction[10:6];

    // Unidade de Controle Principal
    cu control_unit (
        .opcode(instruction[31:26]),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op)
    );

    // Multiplexador para definir onde escrever (rt ou rd?) e com suporte pro JAL, escreve no reg 31
    // Se RegDst=0 -> rt (bits 20-16), Se RegDst=1 -> rd (bits 15-11)
    assign write_reg_addr = (op_jal) ? 5'd31 : 
                            ((reg_dst) ? instruction[15:11] : instruction[20:16]);
    // Banco de Registradores
    registers reg_file (
        .clk(clk),
        .write_en((reg_write & ~is_jr) | op_jal),
        .read_address1(instruction[25:21]), // rs
        .read_address2(instruction[20:16]), // rt
        .write_reg(write_reg_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Extensão de Sinal (16 bits -> 32 bits)
    // Pega o bit 15 (sinal) e repete 16 vezes, concatenando com o imediato original
    assign sign_ext_imm = {{16{instruction[15]}}, instruction[15:0]};

    // ==========================================
    // 4. ESTÁGIO DE EXECUÇÃO
    // ==========================================

    // Unidade de Controle da ALU (Gera os 4 bits de controle)
    alu_control alu_ctrl_unit (
        .alu_op(alu_op),
        .funct(instruction[5:0]),
        .alu_ctrl(alu_control_sig)
    );

    // Multiplexador da ALU (ALUSrc)
    // O segundo operando é o registrador (0) ou o imediato estendido (1)?
    assign alu_input_b = (alu_src) ? sign_ext_imm : read_data2;

    // A Própria ALU
    alu main_alu (
        .a(read_data1),
        .b(alu_input_b),
        .shamt(shamt),
        .alu_ctrl(alu_control_sig),
        .result(alu_result),
        .zero(zero_flag),
        .carry_out(),
        .overflow()
    );

    // ==========================================
    // 5. ESTÁGIO DE MEMÓRIA
    // ==========================================

    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(alu_result),
        .write_data(read_data2), // Dado a ser salvo na memória (vem de rt)
        .read_data(mem_read_data)
    );

    // ==========================================
    // 6. ESTÁGIO DE WRITE-BACK E LÓGICA DE PROX PC
    // ==========================================

    // Multiplexador de MemToReg com suporte pro JAL, escreve pc+4
    // O que volta pro registrador? Resultado da ALU (0) ou Dado da Memória (1)?
    assign write_data = (op_jal)     ? pc_plus4 :
                        ((mem_to_reg) ? mem_read_data : alu_result);

    // Lógica de Branch
    // Endereço de salto = PC+4 + (offset deslocado de 2 bits)
    assign pc_branch = pc_plus4 + (sign_ext_imm << 2);

    // Decisão do Branch: Só pula se instrução for Branch E ALU deu Zero (iguais)
    assign pc_src = branch & zero_flag;

    // Mux do PC com prioridades para JR e JAL
    assign pc_next = (is_jr)   ? read_data1 :
                 (is_jump) ? jump_addr  :
                 (pc_src)  ? pc_branch  : pc_plus4;

endmodule