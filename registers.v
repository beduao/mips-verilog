module registers(
	input clk,
	input write_en,
	input [4:0] read_address1, read_address2, write_reg,
	input [31:0] write_data,
	output [31:0] read_data1, read_data2
);
	reg [31:0] registers [31:0];

	integer i;
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

	always @(posedge clk) begin
		if (write_en) begin
		if (write_reg != 5'b0) begin
		registers[write_reg] <= write_data;
		end
	end
	end

	assign read_data1 = (read_address1==5'b0) ? 32'b0 : registers[read_address1];
	assign read_data2 = (read_address2==5'b0) ? 32'b0 : registers[read_address2];
endmodule