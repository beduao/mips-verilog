module data_memory (
    input  wire        clk,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [31:0] address,    // Endereço calculado pela ALU
    input  wire [31:0] write_data, // Dado a ser escrito (vem de rt)
    output wire [31:0] read_data   // Dado lido (vai para o mux de writeback)
);

    // Memória de 256 palavras
    reg [31:0] memory [0:255];
    
    integer i;
    initial begin
        for (i=0; i<256; i=i+1) memory[i] = 32'b0; // Limpa a memória
    end

    // Leitura Combinacional
    // Se MemRead estiver ativo, lê da memória. Caso contrário, retorna 0.
    assign read_data = (mem_read) ? memory[address[9:2]] : 32'b0;

    // Escrita Síncrona
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[9:2]] <= write_data;
        end
    end

endmodule