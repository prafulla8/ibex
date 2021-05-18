module cv32e40p_register_file (
	clk,
	rst_n,
	scan_cg_en_i,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	raddr_c_i,
	rdata_c_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i,
	waddr_b_i,
	wdata_b_i,
	we_b_i
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter FPU = 0;
	parameter PULP_ZFINX = 0;
	input wire clk;
	input wire rst_n;
	input wire scan_cg_en_i;
	input wire [ADDR_WIDTH - 1:0] raddr_a_i;
	output wire [DATA_WIDTH - 1:0] rdata_a_o;
	input wire [ADDR_WIDTH - 1:0] raddr_b_i;
	output wire [DATA_WIDTH - 1:0] rdata_b_o;
	input wire [ADDR_WIDTH - 1:0] raddr_c_i;
	output wire [DATA_WIDTH - 1:0] rdata_c_o;
	input wire [ADDR_WIDTH - 1:0] waddr_a_i;
	input wire [DATA_WIDTH - 1:0] wdata_a_i;
	input wire we_a_i;
	input wire [ADDR_WIDTH - 1:0] waddr_b_i;
	input wire [DATA_WIDTH - 1:0] wdata_b_i;
	input wire we_b_i;
	localparam NUM_WORDS = 2 ** (ADDR_WIDTH - 1);
	localparam NUM_FP_WORDS = 2 ** (ADDR_WIDTH - 1);
	localparam NUM_TOT_WORDS = (FPU ? (PULP_ZFINX ? NUM_WORDS : NUM_WORDS + NUM_FP_WORDS) : NUM_WORDS);
	reg [DATA_WIDTH - 1:0] mem [0:NUM_WORDS - 1];
	wire [NUM_TOT_WORDS - 1:1] waddr_onehot_a;
	wire [NUM_TOT_WORDS - 1:1] waddr_onehot_b;
	reg [NUM_TOT_WORDS - 1:1] waddr_onehot_b_q;
	wire [NUM_TOT_WORDS - 1:1] mem_clocks;
	reg [DATA_WIDTH - 1:0] wdata_a_q;
	reg [DATA_WIDTH - 1:0] wdata_b_q;
	wire [ADDR_WIDTH - 1:0] waddr_a;
	wire [ADDR_WIDTH - 1:0] waddr_b;
	wire clk_int;
	reg [DATA_WIDTH - 1:0] mem_fp [0:NUM_FP_WORDS - 1];
	reg [31:0] i;
	reg [31:0] j;
	reg [31:0] k;
	reg [31:0] l;
	genvar x;
	genvar y;
	generate
		if ((FPU == 1) && (PULP_ZFINX == 0)) begin
			assign rdata_a_o = (raddr_a_i[5] ? mem_fp[raddr_a_i[4:0]] : mem[raddr_a_i[4:0]]);
			assign rdata_b_o = (raddr_b_i[5] ? mem_fp[raddr_b_i[4:0]] : mem[raddr_b_i[4:0]]);
			assign rdata_c_o = (raddr_c_i[5] ? mem_fp[raddr_c_i[4:0]] : mem[raddr_c_i[4:0]]);
		end
		else begin
			assign rdata_a_o = mem[raddr_a_i[4:0]];
			assign rdata_b_o = mem[raddr_b_i[4:0]];
			assign rdata_c_o = mem[raddr_c_i[4:0]];
		end
	endgenerate
	cv32e40p_clock_gate CG_WE_GLOBAL(
		.clk_i(clk),
		.en_i(we_a_i | we_b_i),
		.scan_cg_en_i(scan_cg_en_i),
		.clk_o(clk_int)
	);
	always @(posedge clk_int or negedge rst_n) begin : sample_waddr
		if (~rst_n) begin
			wdata_a_q <= {DATA_WIDTH {1'sb0}};
			wdata_b_q <= {DATA_WIDTH {1'sb0}};
			waddr_onehot_b_q <= {((NUM_TOT_WORDS - 1) >= 1 ? NUM_TOT_WORDS - 1 : 3 - NUM_TOT_WORDS) {1'sb0}};
		end
		else begin
			if (we_a_i)
				wdata_a_q <= wdata_a_i;
			if (we_b_i)
				wdata_b_q <= wdata_b_i;
			waddr_onehot_b_q <= waddr_onehot_b;
		end
	end
	assign waddr_a = waddr_a_i;
	assign waddr_b = waddr_b_i;
	genvar gidx;
	generate
		for (gidx = 1; gidx < NUM_TOT_WORDS; gidx = gidx + 1) begin : gen_we_decoder
			assign waddr_onehot_a[gidx] = (we_a_i == 1'b1) && (waddr_a == gidx);
			assign waddr_onehot_b[gidx] = (we_b_i == 1'b1) && (waddr_b == gidx);
		end
	endgenerate
	generate
		for (x = 1; x < NUM_TOT_WORDS; x = x + 1) begin : gen_clock_gate
			cv32e40p_clock_gate clock_gate_i(
				.clk_i(clk_int),
				.en_i(waddr_onehot_a[x] | waddr_onehot_b[x]),
				.scan_cg_en_i(scan_cg_en_i),
				.clk_o(mem_clocks[x])
			);
		end
	endgenerate
	always @(*) begin : latch_wdata
		mem[0] = {DATA_WIDTH {1'sb0}};
		for (k = 1; k < NUM_WORDS; k = k + 1)
			begin : w_WordIter
				if (~rst_n)
					mem[k] = {DATA_WIDTH {1'sb0}};
				else if (mem_clocks[k] == 1'b1)
					mem[k] = (waddr_onehot_b_q[k] ? wdata_b_q : wdata_a_q);
			end
	end
	generate
		if ((FPU == 1) && (PULP_ZFINX == 0)) always @(*) begin : latch_wdata_fp
			if (FPU == 1)
				for (l = 0; l < NUM_FP_WORDS; l = l + 1)
					begin : w_WordIter
						if (~rst_n)
							mem_fp[l] = {DATA_WIDTH {1'sb0}};
						else if (mem_clocks[l + NUM_WORDS] == 1'b1)
							mem_fp[l] = (waddr_onehot_b_q[l + NUM_WORDS] ? wdata_b_q : wdata_a_q);
					end
		end
	endgenerate
endmodule
