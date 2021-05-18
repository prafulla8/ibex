module cv32e40p_obi_interface (
	clk,
	rst_n,
	trans_valid_i,
	trans_ready_o,
	trans_addr_i,
	trans_we_i,
	trans_be_i,
	trans_wdata_i,
	trans_atop_i,
	resp_valid_o,
	resp_rdata_o,
	resp_err_o,
	obi_req_o,
	obi_gnt_i,
	obi_addr_o,
	obi_we_o,
	obi_be_o,
	obi_wdata_o,
	obi_atop_o,
	obi_rdata_i,
	obi_rvalid_i,
	obi_err_i
);
	parameter TRANS_STABLE = 0;
	input wire clk;
	input wire rst_n;
	input wire trans_valid_i;
	output wire trans_ready_o;
	input wire [31:0] trans_addr_i;
	input wire trans_we_i;
	input wire [3:0] trans_be_i;
	input wire [31:0] trans_wdata_i;
	input wire [5:0] trans_atop_i;
	output wire resp_valid_o;
	output wire [31:0] resp_rdata_o;
	output wire resp_err_o;
	output reg obi_req_o;
	input wire obi_gnt_i;
	output reg [31:0] obi_addr_o;
	output reg obi_we_o;
	output reg [3:0] obi_be_o;
	output reg [31:0] obi_wdata_o;
	output reg [5:0] obi_atop_o;
	input wire [31:0] obi_rdata_i;
	input wire obi_rvalid_i;
	input wire obi_err_i;
	reg state_q;
	reg next_state;
	assign resp_valid_o = obi_rvalid_i;
	assign resp_rdata_o = obi_rdata_i;
	assign resp_err_o = obi_err_i;
	localparam [0:0] REGISTERED = 1;
	localparam [0:0] TRANSPARENT = 0;
	generate
		if (TRANS_STABLE) begin : gen_trans_stable
			wire [1:1] sv2v_tmp_85DC6;
			assign sv2v_tmp_85DC6 = trans_valid_i;
			always @(*) obi_req_o = sv2v_tmp_85DC6;
			wire [32:1] sv2v_tmp_6313E;
			assign sv2v_tmp_6313E = trans_addr_i;
			always @(*) obi_addr_o = sv2v_tmp_6313E;
			wire [1:1] sv2v_tmp_593FF;
			assign sv2v_tmp_593FF = trans_we_i;
			always @(*) obi_we_o = sv2v_tmp_593FF;
			wire [4:1] sv2v_tmp_79F43;
			assign sv2v_tmp_79F43 = trans_be_i;
			always @(*) obi_be_o = sv2v_tmp_79F43;
			wire [32:1] sv2v_tmp_618E7;
			assign sv2v_tmp_618E7 = trans_wdata_i;
			always @(*) obi_wdata_o = sv2v_tmp_618E7;
			wire [6:1] sv2v_tmp_26163;
			assign sv2v_tmp_26163 = trans_atop_i;
			always @(*) obi_atop_o = sv2v_tmp_26163;
			assign trans_ready_o = obi_gnt_i;
			wire [1:1] sv2v_tmp_84D26;
			assign sv2v_tmp_84D26 = TRANSPARENT;
			always @(*) state_q = sv2v_tmp_84D26;
			wire [1:1] sv2v_tmp_5B029;
			assign sv2v_tmp_5B029 = TRANSPARENT;
			always @(*) next_state = sv2v_tmp_5B029;
		end
		else begin : gen_no_trans_stable
			reg [31:0] obi_addr_q;
			reg obi_we_q;
			reg [3:0] obi_be_q;
			reg [31:0] obi_wdata_q;
			reg [5:0] obi_atop_q;
			always @(*) begin
				next_state = state_q;
				case (state_q)
					TRANSPARENT:
						if (obi_req_o && !obi_gnt_i)
							next_state = REGISTERED;
					REGISTERED:
						if (obi_gnt_i)
							next_state = TRANSPARENT;
				endcase
			end
			always @(*)
				if (state_q == TRANSPARENT) begin
					obi_req_o = trans_valid_i;
					obi_addr_o = trans_addr_i;
					obi_we_o = trans_we_i;
					obi_be_o = trans_be_i;
					obi_wdata_o = trans_wdata_i;
					obi_atop_o = trans_atop_i;
				end
				else begin
					obi_req_o = 1'b1;
					obi_addr_o = obi_addr_q;
					obi_we_o = obi_we_q;
					obi_be_o = obi_be_q;
					obi_wdata_o = obi_wdata_q;
					obi_atop_o = obi_atop_q;
				end
			always @(posedge clk or negedge rst_n)
				if (rst_n == 1'b0) begin
					state_q <= TRANSPARENT;
					obi_addr_q <= 32'b00000000000000000000000000000000;
					obi_we_q <= 1'b0;
					obi_be_q <= 4'b0000;
					obi_wdata_q <= 32'b00000000000000000000000000000000;
					obi_atop_q <= 6'b000000;
				end
				else begin
					state_q <= next_state;
					if ((state_q == TRANSPARENT) && (next_state == REGISTERED)) begin
						obi_addr_q <= obi_addr_o;
						obi_we_q <= obi_we_o;
						obi_be_q <= obi_be_o;
						obi_wdata_q <= obi_wdata_o;
						obi_atop_q <= obi_atop_o;
					end
				end
			assign trans_ready_o = state_q == TRANSPARENT;
		end
	endgenerate
endmodule
