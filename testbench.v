`timescale 1ns / 1ps

module testbench;

    // Sinais para conectar no TOP
    reg clk;
    reg reset;

    // Instância do seu processador (Device Under Test)
    top dut (
        .clk(clk),
        .reset(reset)
    );

    // Fios espiões para ver a memória no GTKWave (VCD padrão)
    // Índice do Verilog = Endereço / 4
    // Endereço 4 -> Índice 1
    wire [31:0] check_size = dut.dmem.memory[0]; // Tamanho
    wire [31:0] check_val1 = dut.dmem.memory[1]; // 10 (vira 1)
    wire [31:0] check_val2 = dut.dmem.memory[2]; // 3  (vira 2)
    wire [31:0] check_val3 = dut.dmem.memory[3]; // 50 (vira 3)
    wire [31:0] check_val4 = dut.dmem.memory[4]; // 2  (vira 10)
    wire [31:0] check_val5 = dut.dmem.memory[5]; // 1  (vira 50)

    // 1. Geração de Clock (Período de 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 2. Sequência de Teste
    initial begin
        // Arquivo de ondas para visualizar no GTKWave
        $dumpfile("mips_waves.vcd");
        $dumpvars(0, testbench);

        // Inicialização
        reset = 1;
        #20;         // Segura o reset por 20ns
        reset = 0;   // Solta o reset (O processador começa aqui!)

        // Tempo de simulação
        // Heap Sort demora um pouco. Vamos dar 100.000ns.
        // Se não terminar, aumente este número.
        #100000;
        
        $display("Simulacao finalizada.");
        $finish;
    end

    // Monitor simples no terminal (opcional)
    // Mostra o PC e a instrução a cada ciclo positivo
    /*
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time: %d, PC: %h, Instr: %h", $time, dut.pc, dut.instruction);
        end
    end
    */

endmodule