module instruction_memory (
    input  wire [31:0] address, //endereco de PC
    output reg  [31:0] instruction
);

    reg [31:0] memory [0:255]; 

    initial begin
        $readmemb("program.bin", memory);
    end


    //LEITURA COMBINACIONAL
    always @(*) begin
        instruction = memory[address[9:2]]; 
    end

endmodule