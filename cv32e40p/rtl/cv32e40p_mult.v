module cv32e40p_mult (
	clk,
	rst_n,
	enable_i,
	operator_i,
	short_subword_i,
	short_signed_i,
	op_a_i,
	op_b_i,
	op_c_i,
	imm_i,
	dot_signed_i,
	dot_op_a_i,
	dot_op_b_i,
	dot_op_c_i,
	is_clpx_i,
	clpx_shift_i,
	clpx_img_i,
	result_o,
	multicycle_o,
	ready_o,
	ex_ready_i
);
	input wire clk;
	input wire rst_n;
	input wire enable_i;
	localparam cv32e40p_pkg_MUL_OP_WIDTH = 3;
	input wire [2:0] operator_i;
	input wire short_subword_i;
	input wire [1:0] short_signed_i;
	input wire [31:0] op_a_i;
	input wire [31:0] op_b_i;
	input wire [31:0] op_c_i;
	input wire [4:0] imm_i;
	input wire [1:0] dot_signed_i;
	input wire [31:0] dot_op_a_i;
	input wire [31:0] dot_op_b_i;
	input wire [31:0] dot_op_c_i;
	input wire is_clpx_i;
	input wire [1:0] clpx_shift_i;
	input wire clpx_img_i;
	output reg [31:0] result_o;
	output reg multicycle_o;
	output wire ready_o;
	input wire ex_ready_i;
	wire [16:0] short_op_a;
	wire [16:0] short_op_b;
	wire [32:0] short_op_c;
	wire [33:0] short_mul;
	wire [33:0] short_mac;
	wire [31:0] short_round;
	wire [31:0] short_round_tmp;
	wire [33:0] short_result;
	wire short_mac_msb1;
	wire short_mac_msb0;
	wire [4:0] short_imm;
	wire [1:0] short_subword;
	wire [1:0] short_signed;
	wire short_shift_arith;
	reg [4:0] mulh_imm;
	reg [1:0] mulh_subword;
	reg [1:0] mulh_signed;
	reg mulh_shift_arith;
	reg mulh_carry_q;
	reg mulh_active;
	reg mulh_save;
	reg mulh_clearcarry;
	reg mulh_ready;
	reg [2:0] mulh_CS;
	reg [2:0] mulh_NS;
	assign short_round_tmp = 32'h00000001 << imm_i;
	localparam [2:0] cv32e40p_pkg_MUL_IR = 3'b011;
	assign short_round = (operator_i == cv32e40p_pkg_MUL_IR ? {1'b0, short_round_tmp[31:1]} : {32 {1'sb0}});
	assign short_op_a[15:0] = (short_subword[0] ? op_a_i[31:16] : op_a_i[15:0]);
	assign short_op_b[15:0] = (short_subword[1] ? op_b_i[31:16] : op_b_i[15:0]);
	assign short_op_a[16] = short_signed[0] & short_op_a[15];
	assign short_op_b[16] = short_signed[1] & short_op_b[15];
	assign short_op_c = (mulh_active ? $signed({mulh_carry_q, op_c_i}) : $signed(op_c_i));
	assign short_mul = $signed(short_op_a) * $signed(short_op_b);
	assign short_mac = ($signed(short_op_c) + $signed(short_mul)) + $signed(short_round);
	assign short_result = $signed({short_shift_arith & short_mac_msb1, short_shift_arith & short_mac_msb0, short_mac[31:0]}) >>> short_imm;
	assign short_imm = (mulh_active ? mulh_imm : imm_i);
	assign short_subword = (mulh_active ? mulh_subword : {2 {short_subword_i}});
	assign short_signed = (mulh_active ? mulh_signed : short_signed_i);
	assign short_shift_arith = (mulh_active ? mulh_shift_arith : short_signed_i[0]);
	assign short_mac_msb1 = (mulh_active ? short_mac[33] : short_mac[31]);
	assign short_mac_msb0 = (mulh_active ? short_mac[32] : short_mac[31]);
	localparam [2:0] cv32e40p_pkg_FINISH = 4;
	localparam [2:0] cv32e40p_pkg_IDLE_MULT = 0;
	localparam [2:0] cv32e40p_pkg_MUL_H = 3'b110;
	localparam [2:0] cv32e40p_pkg_STEP0 = 1;
	localparam [2:0] cv32e40p_pkg_STEP1 = 2;
	localparam [2:0] cv32e40p_pkg_STEP2 = 3;
	always @(*) begin
		mulh_NS = mulh_CS;
		mulh_imm = 5'd0;
		mulh_subword = 2'b00;
		mulh_signed = 2'b00;
		mulh_shift_arith = 1'b0;
		mulh_ready = 1'b0;
		mulh_active = 1'b1;
		mulh_save = 1'b0;
		mulh_clearcarry = 1'b0;
		multicycle_o = 1'b0;
		case (mulh_CS)
			cv32e40p_pkg_IDLE_MULT: begin
				mulh_active = 1'b0;
				mulh_ready = 1'b1;
				mulh_save = 1'b0;
				if ((operator_i == cv32e40p_pkg_MUL_H) && enable_i) begin
					mulh_ready = 1'b0;
					mulh_NS = cv32e40p_pkg_STEP0;
				end
			end
			cv32e40p_pkg_STEP0: begin
				multicycle_o = 1'b1;
				mulh_imm = 5'd16;
				mulh_active = 1'b1;
				mulh_save = 1'b0;
				mulh_NS = cv32e40p_pkg_STEP1;
			end
			cv32e40p_pkg_STEP1: begin
				multicycle_o = 1'b1;
				mulh_signed = {short_signed_i[1], 1'b0};
				mulh_subword = 2'b10;
				mulh_save = 1'b1;
				mulh_shift_arith = 1'b1;
				mulh_NS = cv32e40p_pkg_STEP2;
			end
			cv32e40p_pkg_STEP2: begin
				multicycle_o = 1'b1;
				mulh_signed = {1'b0, short_signed_i[0]};
				mulh_subword = 2'b01;
				mulh_imm = 5'd16;
				mulh_save = 1'b1;
				mulh_clearcarry = 1'b1;
				mulh_shift_arith = 1'b1;
				mulh_NS = cv32e40p_pkg_FINISH;
			end
			cv32e40p_pkg_FINISH: begin
				mulh_signed = short_signed_i;
				mulh_subword = 2'b11;
				mulh_ready = 1'b1;
				if (ex_ready_i)
					mulh_NS = cv32e40p_pkg_IDLE_MULT;
			end
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			mulh_CS <= cv32e40p_pkg_IDLE_MULT;
			mulh_carry_q <= 1'b0;
		end
		else begin
			mulh_CS <= mulh_NS;
			if (mulh_save)
				mulh_carry_q <= ~mulh_clearcarry & short_mac[32];
			else if (ex_ready_i)
				mulh_carry_q <= 1'b0;
		end
	wire [31:0] int_op_a_msu;
	wire [31:0] int_op_b_msu;
	wire [31:0] int_result;
	wire int_is_msu;
	localparam [2:0] cv32e40p_pkg_MUL_MSU32 = 3'b001;
	assign int_is_msu = operator_i == cv32e40p_pkg_MUL_MSU32;
	assign int_op_a_msu = op_a_i ^ {32 {int_is_msu}};
	assign int_op_b_msu = op_b_i & {32 {int_is_msu}};
	assign int_result = ($signed(op_c_i) + $signed(int_op_b_msu)) + ($signed(int_op_a_msu) * $signed(op_b_i));
	wire [31:0] dot_char_result;
	wire [32:0] dot_short_result;
	wire [31:0] accumulator;
	wire [15:0] clpx_shift_result;
	wire [35:0] dot_char_op_a;
	wire [35:0] dot_char_op_b;
	wire [71:0] dot_char_mul;
	wire [33:0] dot_short_op_a;
	wire [33:0] dot_short_op_b;
	wire [67:0] dot_short_mul;
	wire [16:0] dot_short_op_a_1_neg;
	wire [31:0] dot_short_op_b_ext;
	assign dot_char_op_a[0+:9] = {dot_signed_i[1] & dot_op_a_i[7], dot_op_a_i[7:0]};
	assign dot_char_op_a[9+:9] = {dot_signed_i[1] & dot_op_a_i[15], dot_op_a_i[15:8]};
	assign dot_char_op_a[18+:9] = {dot_signed_i[1] & dot_op_a_i[23], dot_op_a_i[23:16]};
	assign dot_char_op_a[27+:9] = {dot_signed_i[1] & dot_op_a_i[31], dot_op_a_i[31:24]};
	assign dot_char_op_b[0+:9] = {dot_signed_i[0] & dot_op_b_i[7], dot_op_b_i[7:0]};
	assign dot_char_op_b[9+:9] = {dot_signed_i[0] & dot_op_b_i[15], dot_op_b_i[15:8]};
	assign dot_char_op_b[18+:9] = {dot_signed_i[0] & dot_op_b_i[23], dot_op_b_i[23:16]};
	assign dot_char_op_b[27+:9] = {dot_signed_i[0] & dot_op_b_i[31], dot_op_b_i[31:24]};
	assign dot_char_mul[0+:18] = $signed(dot_char_op_a[0+:9]) * $signed(dot_char_op_b[0+:9]);
	assign dot_char_mul[18+:18] = $signed(dot_char_op_a[9+:9]) * $signed(dot_char_op_b[9+:9]);
	assign dot_char_mul[36+:18] = $signed(dot_char_op_a[18+:9]) * $signed(dot_char_op_b[18+:9]);
	assign dot_char_mul[54+:18] = $signed(dot_char_op_a[27+:9]) * $signed(dot_char_op_b[27+:9]);
	assign dot_char_result = ((($signed(dot_char_mul[0+:18]) + $signed(dot_char_mul[18+:18])) + $signed(dot_char_mul[36+:18])) + $signed(dot_char_mul[54+:18])) + $signed(dot_op_c_i);
	assign dot_short_op_a[0+:17] = {dot_signed_i[1] & dot_op_a_i[15], dot_op_a_i[15:0]};
	assign dot_short_op_a[17+:17] = {dot_signed_i[1] & dot_op_a_i[31], dot_op_a_i[31:16]};
	assign dot_short_op_a_1_neg = dot_short_op_a[17+:17] ^ {17 {is_clpx_i & ~clpx_img_i}};
	assign dot_short_op_b[0+:17] = (is_clpx_i & clpx_img_i ? {dot_signed_i[0] & dot_op_b_i[31], dot_op_b_i[31:16]} : {dot_signed_i[0] & dot_op_b_i[15], dot_op_b_i[15:0]});
	assign dot_short_op_b[17+:17] = (is_clpx_i & clpx_img_i ? {dot_signed_i[0] & dot_op_b_i[15], dot_op_b_i[15:0]} : {dot_signed_i[0] & dot_op_b_i[31], dot_op_b_i[31:16]});
	assign dot_short_mul[0+:34] = $signed(dot_short_op_a[0+:17]) * $signed(dot_short_op_b[0+:17]);
	assign dot_short_mul[34+:34] = $signed(dot_short_op_a_1_neg) * $signed(dot_short_op_b[17+:17]);
	assign dot_short_op_b_ext = $signed(dot_short_op_b[17+:17]);
	assign accumulator = (is_clpx_i ? dot_short_op_b_ext & {32 {~clpx_img_i}} : $signed(dot_op_c_i));
	assign dot_short_result = ($signed(dot_short_mul[31-:32]) + $signed(dot_short_mul[65-:32])) + $signed(accumulator);
	assign clpx_shift_result = $signed(dot_short_result[31:15]) >>> clpx_shift_i;
	localparam [2:0] cv32e40p_pkg_MUL_DOT16 = 3'b101;
	localparam [2:0] cv32e40p_pkg_MUL_DOT8 = 3'b100;
	localparam [2:0] cv32e40p_pkg_MUL_I = 3'b010;
	localparam [2:0] cv32e40p_pkg_MUL_MAC32 = 3'b000;
	always @(*) begin
		result_o = {32 {1'sb0}};
		case (operator_i)
			cv32e40p_pkg_MUL_MAC32, cv32e40p_pkg_MUL_MSU32: result_o = int_result[31:0];
			cv32e40p_pkg_MUL_I, cv32e40p_pkg_MUL_IR, cv32e40p_pkg_MUL_H: result_o = short_result[31:0];
			cv32e40p_pkg_MUL_DOT8: result_o = dot_char_result[31:0];
			cv32e40p_pkg_MUL_DOT16:
				if (is_clpx_i) begin
					if (clpx_img_i) begin
						result_o[31:16] = clpx_shift_result;
						result_o[15:0] = dot_op_c_i[15:0];
					end
					else begin
						result_o[15:0] = clpx_shift_result;
						result_o[31:16] = dot_op_c_i[31:16];
					end
				end
				else
					result_o = dot_short_result[31:0];
			default:
				;
		endcase
	end
	assign ready_o = mulh_ready;
endmodule
