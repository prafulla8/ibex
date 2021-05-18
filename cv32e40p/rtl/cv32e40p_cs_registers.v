module cv32e40p_cs_registers (
	clk,
	rst_n,
	hart_id_i,
	mtvec_o,
	utvec_o,
	mtvec_mode_o,
	utvec_mode_o,
	mtvec_addr_i,
	csr_mtvec_init_i,
	csr_addr_i,
	csr_wdata_i,
	csr_op_i,
	csr_rdata_o,
	frm_o,
	fflags_i,
	fflags_we_i,
	mie_bypass_o,
	mip_i,
	m_irq_enable_o,
	u_irq_enable_o,
	csr_irq_sec_i,
	sec_lvl_o,
	mepc_o,
	uepc_o,
	mcounteren_o,
	debug_mode_i,
	debug_cause_i,
	debug_csr_save_i,
	depc_o,
	debug_single_step_o,
	debug_ebreakm_o,
	debug_ebreaku_o,
	trigger_match_o,
	pmp_addr_o,
	pmp_cfg_o,
	priv_lvl_o,
	pc_if_i,
	pc_id_i,
	pc_ex_i,
	csr_save_if_i,
	csr_save_id_i,
	csr_save_ex_i,
	csr_restore_mret_i,
	csr_restore_uret_i,
	csr_restore_dret_i,
	csr_cause_i,
	csr_save_cause_i,
	hwlp_start_i,
	hwlp_end_i,
	hwlp_cnt_i,
	hwlp_data_o,
	hwlp_regid_o,
	hwlp_we_o,
	mhpmevent_minstret_i,
	mhpmevent_load_i,
	mhpmevent_store_i,
	mhpmevent_jump_i,
	mhpmevent_branch_i,
	mhpmevent_branch_taken_i,
	mhpmevent_compressed_i,
	mhpmevent_jr_stall_i,
	mhpmevent_imiss_i,
	mhpmevent_ld_stall_i,
	mhpmevent_pipe_stall_i,
	apu_typeconflict_i,
	apu_contention_i,
	apu_dep_i,
	apu_wb_i
);
	parameter N_HWLP = 2;
	parameter N_HWLP_BITS = $clog2(N_HWLP);
	parameter APU = 0;
	parameter A_EXTENSION = 0;
	parameter FPU = 0;
	parameter PULP_SECURE = 0;
	parameter USE_PMP = 0;
	parameter N_PMP_ENTRIES = 16;
	parameter NUM_MHPMCOUNTERS = 1;
	parameter PULP_XPULP = 0;
	parameter PULP_CLUSTER = 0;
	parameter DEBUG_TRIGGER_EN = 1;
	input wire clk;
	input wire rst_n;
	input wire [31:0] hart_id_i;
	output wire [23:0] mtvec_o;
	output wire [23:0] utvec_o;
	output wire [1:0] mtvec_mode_o;
	output wire [1:0] utvec_mode_o;
	input wire [31:0] mtvec_addr_i;
	input wire csr_mtvec_init_i;
	input wire [11:0] csr_addr_i;
	input wire [31:0] csr_wdata_i;
	localparam cv32e40p_pkg_CSR_OP_WIDTH = 2;
	input wire [1:0] csr_op_i;
	output wire [31:0] csr_rdata_o;
	output wire [2:0] frm_o;
	localparam cv32e40p_pkg_C_FFLAG = 5;
	input wire [4:0] fflags_i;
	input wire fflags_we_i;
	output wire [31:0] mie_bypass_o;
	input wire [31:0] mip_i;
	output wire m_irq_enable_o;
	output wire u_irq_enable_o;
	input wire csr_irq_sec_i;
	output wire sec_lvl_o;
	output wire [31:0] mepc_o;
	output wire [31:0] uepc_o;
	output wire [31:0] mcounteren_o;
	input wire debug_mode_i;
	input wire [2:0] debug_cause_i;
	input wire debug_csr_save_i;
	output wire [31:0] depc_o;
	output wire debug_single_step_o;
	output wire debug_ebreakm_o;
	output wire debug_ebreaku_o;
	output wire trigger_match_o;
	output wire [(N_PMP_ENTRIES * 32) - 1:0] pmp_addr_o;
	output wire [(N_PMP_ENTRIES * 8) - 1:0] pmp_cfg_o;
	output wire [1:0] priv_lvl_o;
	input wire [31:0] pc_if_i;
	input wire [31:0] pc_id_i;
	input wire [31:0] pc_ex_i;
	input wire csr_save_if_i;
	input wire csr_save_id_i;
	input wire csr_save_ex_i;
	input wire csr_restore_mret_i;
	input wire csr_restore_uret_i;
	input wire csr_restore_dret_i;
	input wire [5:0] csr_cause_i;
	input wire csr_save_cause_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_start_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_end_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_cnt_i;
	output wire [31:0] hwlp_data_o;
	output reg [N_HWLP_BITS - 1:0] hwlp_regid_o;
	output reg [2:0] hwlp_we_o;
	input wire mhpmevent_minstret_i;
	input wire mhpmevent_load_i;
	input wire mhpmevent_store_i;
	input wire mhpmevent_jump_i;
	input wire mhpmevent_branch_i;
	input wire mhpmevent_branch_taken_i;
	input wire mhpmevent_compressed_i;
	input wire mhpmevent_jr_stall_i;
	input wire mhpmevent_imiss_i;
	input wire mhpmevent_ld_stall_i;
	input wire mhpmevent_pipe_stall_i;
	input wire apu_typeconflict_i;
	input wire apu_contention_i;
	input wire apu_dep_i;
	input wire apu_wb_i;
	localparam NUM_HPM_EVENTS = 16;
	localparam MTVEC_MODE = 2'b01;
	localparam MAX_N_PMP_ENTRIES = 16;
	localparam MAX_N_PMP_CFG = 4;
	localparam N_PMP_CFG = ((N_PMP_ENTRIES % 4) == 0 ? N_PMP_ENTRIES / 4 : (N_PMP_ENTRIES / 4) + 1);
	localparam MSTATUS_UIE_BIT = 0;
	localparam MSTATUS_SIE_BIT = 1;
	localparam MSTATUS_MIE_BIT = 3;
	localparam MSTATUS_UPIE_BIT = 4;
	localparam MSTATUS_SPIE_BIT = 5;
	localparam MSTATUS_MPIE_BIT = 7;
	localparam MSTATUS_SPP_BIT = 8;
	localparam MSTATUS_MPP_BIT_HIGH = 12;
	localparam MSTATUS_MPP_BIT_LOW = 11;
	localparam MSTATUS_MPRV_BIT = 17;
	localparam [1:0] MXL = 2'd1;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	localparam [31:0] MISA_VALUE = (((((((((((A_EXTENSION << 0) | 4) | 0) | 0) | (FPU << 5)) | 256) | 4096) | 0) | 0) | (PULP_SECURE << 20)) | (sv2v_cast_32(PULP_XPULP || PULP_CLUSTER) << 23)) | (sv2v_cast_32(MXL) << 30);
	localparam MHPMCOUNTER_WIDTH = 64;
	localparam PULP_PERF_COUNTERS = 0;
	reg [31:0] csr_wdata_int;
	reg [31:0] csr_rdata_int;
	reg csr_we_int;
	localparam cv32e40p_pkg_C_RM = 3;
	reg [2:0] frm_q;
	reg [2:0] frm_n;
	reg [4:0] fflags_q;
	reg [4:0] fflags_n;
	reg [31:0] mepc_q;
	reg [31:0] mepc_n;
	reg [31:0] uepc_q;
	reg [31:0] uepc_n;
	wire [31:0] tmatch_control_rdata;
	wire [31:0] tmatch_value_rdata;
	wire [15:0] tinfo_types;
	reg [31:0] dcsr_q;
	reg [31:0] dcsr_n;
	reg [31:0] depc_q;
	reg [31:0] depc_n;
	reg [31:0] dscratch0_q;
	reg [31:0] dscratch0_n;
	reg [31:0] dscratch1_q;
	reg [31:0] dscratch1_n;
	reg [31:0] mscratch_q;
	reg [31:0] mscratch_n;
	reg [31:0] exception_pc;
	reg [6:0] mstatus_q;
	reg [6:0] mstatus_n;
	reg [5:0] mcause_q;
	reg [5:0] mcause_n;
	reg [5:0] ucause_q;
	reg [5:0] ucause_n;
	reg [23:0] mtvec_n;
	reg [23:0] mtvec_q;
	reg [23:0] utvec_n;
	reg [23:0] utvec_q;
	reg [1:0] mtvec_mode_n;
	reg [1:0] mtvec_mode_q;
	reg [1:0] utvec_mode_n;
	reg [1:0] utvec_mode_q;
	wire [31:0] mip;
	reg [31:0] mie_q;
	reg [31:0] mie_n;
	reg [31:0] csr_mie_wdata;
	reg csr_mie_we;
	wire is_irq;
	reg [1:0] priv_lvl_n;
	reg [1:0] priv_lvl_q;
	reg [767:0] pmp_reg_q;
	reg [767:0] pmp_reg_n;
	reg [15:0] pmpaddr_we;
	reg [15:0] pmpcfg_we;
	reg [2047:0] mhpmcounter_q;
	reg [1023:0] mhpmevent_q;
	reg [1023:0] mhpmevent_n;
	reg [31:0] mcounteren_q;
	reg [31:0] mcounteren_n;
	reg [31:0] mcountinhibit_q;
	reg [31:0] mcountinhibit_n;
	wire [15:0] hpm_events;
	wire [2047:0] mhpmcounter_increment;
	wire [31:0] mhpmcounter_write_lower;
	wire [31:0] mhpmcounter_write_upper;
	wire [31:0] mhpmcounter_write_increment;
	assign is_irq = csr_cause_i[5];
	assign mip = mip_i;
	localparam [1:0] cv32e40p_pkg_CSR_OP_CLEAR = 2'b11;
	localparam [1:0] cv32e40p_pkg_CSR_OP_READ = 2'b00;
	localparam [1:0] cv32e40p_pkg_CSR_OP_SET = 2'b10;
	localparam [1:0] cv32e40p_pkg_CSR_OP_WRITE = 2'b01;
	always @(*) begin
		csr_mie_wdata = csr_wdata_i;
		csr_mie_we = 1'b1;
		case (csr_op_i)
			cv32e40p_pkg_CSR_OP_WRITE: csr_mie_wdata = csr_wdata_i;
			cv32e40p_pkg_CSR_OP_SET: csr_mie_wdata = csr_wdata_i | mie_q;
			cv32e40p_pkg_CSR_OP_CLEAR: csr_mie_wdata = ~csr_wdata_i & mie_q;
			cv32e40p_pkg_CSR_OP_READ: begin
				csr_mie_wdata = csr_wdata_i;
				csr_mie_we = 1'b0;
			end
		endcase
	end
	localparam cv32e40p_pkg_IRQ_MASK = 32'hffff0888;
	localparam [11:0] cv32e40p_pkg_CSR_MIE = 12'h304;
	assign mie_bypass_o = ((csr_addr_i == cv32e40p_pkg_CSR_MIE) && csr_mie_we ? csr_mie_wdata & cv32e40p_pkg_IRQ_MASK : mie_q);
	genvar j;
	localparam cv32e40p_pkg_MARCHID = 32'h00000004;
	localparam cv32e40p_pkg_MVENDORID_BANK = 25'h000000c;
	localparam cv32e40p_pkg_MVENDORID_OFFSET = 7'h02;
	localparam [11:0] cv32e40p_pkg_CSR_CYCLE = 12'hc00;
	localparam [11:0] cv32e40p_pkg_CSR_CYCLEH = 12'hc80;
	localparam [11:0] cv32e40p_pkg_CSR_DCSR = 12'h7b0;
	localparam [11:0] cv32e40p_pkg_CSR_DPC = 12'h7b1;
	localparam [11:0] cv32e40p_pkg_CSR_DSCRATCH0 = 12'h7b2;
	localparam [11:0] cv32e40p_pkg_CSR_DSCRATCH1 = 12'h7b3;
	localparam [11:0] cv32e40p_pkg_CSR_FCSR = 12'h003;
	localparam [11:0] cv32e40p_pkg_CSR_FFLAGS = 12'h001;
	localparam [11:0] cv32e40p_pkg_CSR_FRM = 12'h002;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER10 = 12'hc0a;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER10H = 12'hc8a;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER11 = 12'hc0b;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER11H = 12'hc8b;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER12 = 12'hc0c;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER12H = 12'hc8c;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER13 = 12'hc0d;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER13H = 12'hc8d;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER14 = 12'hc0e;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER14H = 12'hc8e;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER15 = 12'hc0f;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER15H = 12'hc8f;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER16 = 12'hc10;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER16H = 12'hc90;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER17 = 12'hc11;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER17H = 12'hc91;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER18 = 12'hc12;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER18H = 12'hc92;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER19 = 12'hc13;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER19H = 12'hc93;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER20 = 12'hc14;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER20H = 12'hc94;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER21 = 12'hc15;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER21H = 12'hc95;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER22 = 12'hc16;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER22H = 12'hc96;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER23 = 12'hc17;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER23H = 12'hc97;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER24 = 12'hc18;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER24H = 12'hc98;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER25 = 12'hc19;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER25H = 12'hc99;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER26 = 12'hc1a;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER26H = 12'hc9a;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER27 = 12'hc1b;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER27H = 12'hc9b;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER28 = 12'hc1c;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER28H = 12'hc9c;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER29 = 12'hc1d;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER29H = 12'hc9d;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER3 = 12'hc03;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER30 = 12'hc1e;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER30H = 12'hc9e;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER31 = 12'hc1f;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER31H = 12'hc9f;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER3H = 12'hc83;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER4 = 12'hc04;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER4H = 12'hc84;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER5 = 12'hc05;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER5H = 12'hc85;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER6 = 12'hc06;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER6H = 12'hc86;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER7 = 12'hc07;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER7H = 12'hc87;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER8 = 12'hc08;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER8H = 12'hc88;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER9 = 12'hc09;
	localparam [11:0] cv32e40p_pkg_CSR_HPMCOUNTER9H = 12'hc89;
	localparam [11:0] cv32e40p_pkg_CSR_INSTRET = 12'hc02;
	localparam [11:0] cv32e40p_pkg_CSR_INSTRETH = 12'hc82;
	localparam [11:0] cv32e40p_pkg_CSR_LPCOUNT0 = 12'h802;
	localparam [11:0] cv32e40p_pkg_CSR_LPCOUNT1 = 12'h806;
	localparam [11:0] cv32e40p_pkg_CSR_LPEND0 = 12'h801;
	localparam [11:0] cv32e40p_pkg_CSR_LPEND1 = 12'h805;
	localparam [11:0] cv32e40p_pkg_CSR_LPSTART0 = 12'h800;
	localparam [11:0] cv32e40p_pkg_CSR_LPSTART1 = 12'h804;
	localparam [11:0] cv32e40p_pkg_CSR_MARCHID = 12'hf12;
	localparam [11:0] cv32e40p_pkg_CSR_MCAUSE = 12'h342;
	localparam [11:0] cv32e40p_pkg_CSR_MCONTEXT = 12'h7a8;
	localparam [11:0] cv32e40p_pkg_CSR_MCOUNTEREN = 12'h306;
	localparam [11:0] cv32e40p_pkg_CSR_MCOUNTINHIBIT = 12'h320;
	localparam [11:0] cv32e40p_pkg_CSR_MCYCLE = 12'hb00;
	localparam [11:0] cv32e40p_pkg_CSR_MCYCLEH = 12'hb80;
	localparam [11:0] cv32e40p_pkg_CSR_MEPC = 12'h341;
	localparam [11:0] cv32e40p_pkg_CSR_MHARTID = 12'hf14;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER10 = 12'hb0a;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER10H = 12'hb8a;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER11 = 12'hb0b;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER11H = 12'hb8b;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER12 = 12'hb0c;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER12H = 12'hb8c;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER13 = 12'hb0d;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER13H = 12'hb8d;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER14 = 12'hb0e;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER14H = 12'hb8e;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER15 = 12'hb0f;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER15H = 12'hb8f;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER16 = 12'hb10;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER16H = 12'hb90;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER17 = 12'hb11;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER17H = 12'hb91;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER18 = 12'hb12;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER18H = 12'hb92;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER19 = 12'hb13;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER19H = 12'hb93;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER20 = 12'hb14;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER20H = 12'hb94;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER21 = 12'hb15;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER21H = 12'hb95;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER22 = 12'hb16;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER22H = 12'hb96;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER23 = 12'hb17;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER23H = 12'hb97;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER24 = 12'hb18;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER24H = 12'hb98;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER25 = 12'hb19;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER25H = 12'hb99;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER26 = 12'hb1a;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER26H = 12'hb9a;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER27 = 12'hb1b;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER27H = 12'hb9b;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER28 = 12'hb1c;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER28H = 12'hb9c;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER29 = 12'hb1d;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER29H = 12'hb9d;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER3 = 12'hb03;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER30 = 12'hb1e;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER30H = 12'hb9e;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER31 = 12'hb1f;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER31H = 12'hb9f;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER3H = 12'hb83;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER4 = 12'hb04;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER4H = 12'hb84;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER5 = 12'hb05;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER5H = 12'hb85;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER6 = 12'hb06;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER6H = 12'hb86;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER7 = 12'hb07;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER7H = 12'hb87;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER8 = 12'hb08;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER8H = 12'hb88;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER9 = 12'hb09;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMCOUNTER9H = 12'hb89;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT10 = 12'h32a;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT11 = 12'h32b;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT12 = 12'h32c;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT13 = 12'h32d;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT14 = 12'h32e;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT15 = 12'h32f;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT16 = 12'h330;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT17 = 12'h331;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT18 = 12'h332;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT19 = 12'h333;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT20 = 12'h334;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT21 = 12'h335;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT22 = 12'h336;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT23 = 12'h337;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT24 = 12'h338;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT25 = 12'h339;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT26 = 12'h33a;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT27 = 12'h33b;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT28 = 12'h33c;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT29 = 12'h33d;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT3 = 12'h323;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT30 = 12'h33e;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT31 = 12'h33f;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT4 = 12'h324;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT5 = 12'h325;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT6 = 12'h326;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT7 = 12'h327;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT8 = 12'h328;
	localparam [11:0] cv32e40p_pkg_CSR_MHPMEVENT9 = 12'h329;
	localparam [11:0] cv32e40p_pkg_CSR_MIMPID = 12'hf13;
	localparam [11:0] cv32e40p_pkg_CSR_MINSTRET = 12'hb02;
	localparam [11:0] cv32e40p_pkg_CSR_MINSTRETH = 12'hb82;
	localparam [11:0] cv32e40p_pkg_CSR_MIP = 12'h344;
	localparam [11:0] cv32e40p_pkg_CSR_MISA = 12'h301;
	localparam [11:0] cv32e40p_pkg_CSR_MSCRATCH = 12'h340;
	localparam [11:0] cv32e40p_pkg_CSR_MSTATUS = 12'h300;
	localparam [11:0] cv32e40p_pkg_CSR_MTVAL = 12'h343;
	localparam [11:0] cv32e40p_pkg_CSR_MTVEC = 12'h305;
	localparam [11:0] cv32e40p_pkg_CSR_MVENDORID = 12'hf11;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR0 = 12'h3b0;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR1 = 12'h3b1;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR10 = 12'h3ba;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR11 = 12'h3bb;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR12 = 12'h3bc;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR13 = 12'h3bd;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR14 = 12'h3be;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR15 = 12'h3bf;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR2 = 12'h3b2;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR3 = 12'h3b3;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR4 = 12'h3b4;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR5 = 12'h3b5;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR6 = 12'h3b6;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR7 = 12'h3b7;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR8 = 12'h3b8;
	localparam [11:0] cv32e40p_pkg_CSR_PMPADDR9 = 12'h3b9;
	localparam [11:0] cv32e40p_pkg_CSR_PMPCFG0 = 12'h3a0;
	localparam [11:0] cv32e40p_pkg_CSR_PMPCFG1 = 12'h3a1;
	localparam [11:0] cv32e40p_pkg_CSR_PMPCFG2 = 12'h3a2;
	localparam [11:0] cv32e40p_pkg_CSR_PMPCFG3 = 12'h3a3;
	localparam [11:0] cv32e40p_pkg_CSR_PRIVLV = 12'hcc1;
	localparam [11:0] cv32e40p_pkg_CSR_SCONTEXT = 12'h7aa;
	localparam [11:0] cv32e40p_pkg_CSR_TDATA1 = 12'h7a1;
	localparam [11:0] cv32e40p_pkg_CSR_TDATA2 = 12'h7a2;
	localparam [11:0] cv32e40p_pkg_CSR_TDATA3 = 12'h7a3;
	localparam [11:0] cv32e40p_pkg_CSR_TINFO = 12'h7a4;
	localparam [11:0] cv32e40p_pkg_CSR_TSELECT = 12'h7a0;
	localparam [11:0] cv32e40p_pkg_CSR_UCAUSE = 12'h042;
	localparam [11:0] cv32e40p_pkg_CSR_UEPC = 12'h041;
	localparam [11:0] cv32e40p_pkg_CSR_UHARTID = 12'hcc0;
	localparam [11:0] cv32e40p_pkg_CSR_USTATUS = 12'h000;
	localparam [11:0] cv32e40p_pkg_CSR_UTVEC = 12'h005;
	generate
		if (PULP_SECURE == 1) begin : gen_pulp_secure_read_logic
			always @(*)
				case (csr_addr_i)
					cv32e40p_pkg_CSR_FFLAGS: csr_rdata_int = (FPU == 1 ? {27'b000000000000000000000000000, fflags_q} : {32 {1'sb0}});
					cv32e40p_pkg_CSR_FRM: csr_rdata_int = (FPU == 1 ? {29'b00000000000000000000000000000, frm_q} : {32 {1'sb0}});
					cv32e40p_pkg_CSR_FCSR: csr_rdata_int = (FPU == 1 ? {24'b000000000000000000000000, frm_q, fflags_q} : {32 {1'sb0}});
					cv32e40p_pkg_CSR_MSTATUS: csr_rdata_int = {14'b00000000000000, mstatus_q[0], 4'b0000, mstatus_q[2-:2], 3'b000, mstatus_q[3], 2'h0, mstatus_q[4], mstatus_q[5], 2'h0, mstatus_q[6]};
					cv32e40p_pkg_CSR_MISA: csr_rdata_int = MISA_VALUE;
					cv32e40p_pkg_CSR_MIE: csr_rdata_int = mie_q;
					cv32e40p_pkg_CSR_MTVEC: csr_rdata_int = {mtvec_q, 6'h00, mtvec_mode_q};
					cv32e40p_pkg_CSR_MSCRATCH: csr_rdata_int = mscratch_q;
					cv32e40p_pkg_CSR_MEPC: csr_rdata_int = mepc_q;
					cv32e40p_pkg_CSR_MCAUSE: csr_rdata_int = {mcause_q[5], 26'b00000000000000000000000000, mcause_q[4:0]};
					cv32e40p_pkg_CSR_MIP: csr_rdata_int = mip;
					cv32e40p_pkg_CSR_MHARTID: csr_rdata_int = hart_id_i;
					cv32e40p_pkg_CSR_MVENDORID: csr_rdata_int = {cv32e40p_pkg_MVENDORID_BANK, cv32e40p_pkg_MVENDORID_OFFSET};
					cv32e40p_pkg_CSR_MARCHID: csr_rdata_int = cv32e40p_pkg_MARCHID;
					cv32e40p_pkg_CSR_MIMPID, cv32e40p_pkg_CSR_MTVAL: csr_rdata_int = 'b0;
					cv32e40p_pkg_CSR_MCOUNTEREN: csr_rdata_int = mcounteren_q;
					cv32e40p_pkg_CSR_TSELECT, cv32e40p_pkg_CSR_TDATA3, cv32e40p_pkg_CSR_MCONTEXT, cv32e40p_pkg_CSR_SCONTEXT: csr_rdata_int = 'b0;
					cv32e40p_pkg_CSR_TDATA1: csr_rdata_int = tmatch_control_rdata;
					cv32e40p_pkg_CSR_TDATA2: csr_rdata_int = tmatch_value_rdata;
					cv32e40p_pkg_CSR_TINFO: csr_rdata_int = tinfo_types;
					cv32e40p_pkg_CSR_DCSR: csr_rdata_int = dcsr_q;
					cv32e40p_pkg_CSR_DPC: csr_rdata_int = depc_q;
					cv32e40p_pkg_CSR_DSCRATCH0: csr_rdata_int = dscratch0_q;
					cv32e40p_pkg_CSR_DSCRATCH1: csr_rdata_int = dscratch1_q;
					cv32e40p_pkg_CSR_MCYCLE, cv32e40p_pkg_CSR_MINSTRET, cv32e40p_pkg_CSR_MHPMCOUNTER3, cv32e40p_pkg_CSR_MHPMCOUNTER4, cv32e40p_pkg_CSR_MHPMCOUNTER5, cv32e40p_pkg_CSR_MHPMCOUNTER6, cv32e40p_pkg_CSR_MHPMCOUNTER7, cv32e40p_pkg_CSR_MHPMCOUNTER8, cv32e40p_pkg_CSR_MHPMCOUNTER9, cv32e40p_pkg_CSR_MHPMCOUNTER10, cv32e40p_pkg_CSR_MHPMCOUNTER11, cv32e40p_pkg_CSR_MHPMCOUNTER12, cv32e40p_pkg_CSR_MHPMCOUNTER13, cv32e40p_pkg_CSR_MHPMCOUNTER14, cv32e40p_pkg_CSR_MHPMCOUNTER15, cv32e40p_pkg_CSR_MHPMCOUNTER16, cv32e40p_pkg_CSR_MHPMCOUNTER17, cv32e40p_pkg_CSR_MHPMCOUNTER18, cv32e40p_pkg_CSR_MHPMCOUNTER19, cv32e40p_pkg_CSR_MHPMCOUNTER20, cv32e40p_pkg_CSR_MHPMCOUNTER21, cv32e40p_pkg_CSR_MHPMCOUNTER22, cv32e40p_pkg_CSR_MHPMCOUNTER23, cv32e40p_pkg_CSR_MHPMCOUNTER24, cv32e40p_pkg_CSR_MHPMCOUNTER25, cv32e40p_pkg_CSR_MHPMCOUNTER26, cv32e40p_pkg_CSR_MHPMCOUNTER27, cv32e40p_pkg_CSR_MHPMCOUNTER28, cv32e40p_pkg_CSR_MHPMCOUNTER29, cv32e40p_pkg_CSR_MHPMCOUNTER30, cv32e40p_pkg_CSR_MHPMCOUNTER31, cv32e40p_pkg_CSR_CYCLE, cv32e40p_pkg_CSR_INSTRET, cv32e40p_pkg_CSR_HPMCOUNTER3, cv32e40p_pkg_CSR_HPMCOUNTER4, cv32e40p_pkg_CSR_HPMCOUNTER5, cv32e40p_pkg_CSR_HPMCOUNTER6, cv32e40p_pkg_CSR_HPMCOUNTER7, cv32e40p_pkg_CSR_HPMCOUNTER8, cv32e40p_pkg_CSR_HPMCOUNTER9, cv32e40p_pkg_CSR_HPMCOUNTER10, cv32e40p_pkg_CSR_HPMCOUNTER11, cv32e40p_pkg_CSR_HPMCOUNTER12, cv32e40p_pkg_CSR_HPMCOUNTER13, cv32e40p_pkg_CSR_HPMCOUNTER14, cv32e40p_pkg_CSR_HPMCOUNTER15, cv32e40p_pkg_CSR_HPMCOUNTER16, cv32e40p_pkg_CSR_HPMCOUNTER17, cv32e40p_pkg_CSR_HPMCOUNTER18, cv32e40p_pkg_CSR_HPMCOUNTER19, cv32e40p_pkg_CSR_HPMCOUNTER20, cv32e40p_pkg_CSR_HPMCOUNTER21, cv32e40p_pkg_CSR_HPMCOUNTER22, cv32e40p_pkg_CSR_HPMCOUNTER23, cv32e40p_pkg_CSR_HPMCOUNTER24, cv32e40p_pkg_CSR_HPMCOUNTER25, cv32e40p_pkg_CSR_HPMCOUNTER26, cv32e40p_pkg_CSR_HPMCOUNTER27, cv32e40p_pkg_CSR_HPMCOUNTER28, cv32e40p_pkg_CSR_HPMCOUNTER29, cv32e40p_pkg_CSR_HPMCOUNTER30, cv32e40p_pkg_CSR_HPMCOUNTER31: csr_rdata_int = mhpmcounter_q[(csr_addr_i[4:0] * 64) + 31-:32];
					cv32e40p_pkg_CSR_MCYCLEH, cv32e40p_pkg_CSR_MINSTRETH, cv32e40p_pkg_CSR_MHPMCOUNTER3H, cv32e40p_pkg_CSR_MHPMCOUNTER4H, cv32e40p_pkg_CSR_MHPMCOUNTER5H, cv32e40p_pkg_CSR_MHPMCOUNTER6H, cv32e40p_pkg_CSR_MHPMCOUNTER7H, cv32e40p_pkg_CSR_MHPMCOUNTER8H, cv32e40p_pkg_CSR_MHPMCOUNTER9H, cv32e40p_pkg_CSR_MHPMCOUNTER10H, cv32e40p_pkg_CSR_MHPMCOUNTER11H, cv32e40p_pkg_CSR_MHPMCOUNTER12H, cv32e40p_pkg_CSR_MHPMCOUNTER13H, cv32e40p_pkg_CSR_MHPMCOUNTER14H, cv32e40p_pkg_CSR_MHPMCOUNTER15H, cv32e40p_pkg_CSR_MHPMCOUNTER16H, cv32e40p_pkg_CSR_MHPMCOUNTER17H, cv32e40p_pkg_CSR_MHPMCOUNTER18H, cv32e40p_pkg_CSR_MHPMCOUNTER19H, cv32e40p_pkg_CSR_MHPMCOUNTER20H, cv32e40p_pkg_CSR_MHPMCOUNTER21H, cv32e40p_pkg_CSR_MHPMCOUNTER22H, cv32e40p_pkg_CSR_MHPMCOUNTER23H, cv32e40p_pkg_CSR_MHPMCOUNTER24H, cv32e40p_pkg_CSR_MHPMCOUNTER25H, cv32e40p_pkg_CSR_MHPMCOUNTER26H, cv32e40p_pkg_CSR_MHPMCOUNTER27H, cv32e40p_pkg_CSR_MHPMCOUNTER28H, cv32e40p_pkg_CSR_MHPMCOUNTER29H, cv32e40p_pkg_CSR_MHPMCOUNTER30H, cv32e40p_pkg_CSR_MHPMCOUNTER31H, cv32e40p_pkg_CSR_CYCLEH, cv32e40p_pkg_CSR_INSTRETH, cv32e40p_pkg_CSR_HPMCOUNTER3H, cv32e40p_pkg_CSR_HPMCOUNTER4H, cv32e40p_pkg_CSR_HPMCOUNTER5H, cv32e40p_pkg_CSR_HPMCOUNTER6H, cv32e40p_pkg_CSR_HPMCOUNTER7H, cv32e40p_pkg_CSR_HPMCOUNTER8H, cv32e40p_pkg_CSR_HPMCOUNTER9H, cv32e40p_pkg_CSR_HPMCOUNTER10H, cv32e40p_pkg_CSR_HPMCOUNTER11H, cv32e40p_pkg_CSR_HPMCOUNTER12H, cv32e40p_pkg_CSR_HPMCOUNTER13H, cv32e40p_pkg_CSR_HPMCOUNTER14H, cv32e40p_pkg_CSR_HPMCOUNTER15H, cv32e40p_pkg_CSR_HPMCOUNTER16H, cv32e40p_pkg_CSR_HPMCOUNTER17H, cv32e40p_pkg_CSR_HPMCOUNTER18H, cv32e40p_pkg_CSR_HPMCOUNTER19H, cv32e40p_pkg_CSR_HPMCOUNTER20H, cv32e40p_pkg_CSR_HPMCOUNTER21H, cv32e40p_pkg_CSR_HPMCOUNTER22H, cv32e40p_pkg_CSR_HPMCOUNTER23H, cv32e40p_pkg_CSR_HPMCOUNTER24H, cv32e40p_pkg_CSR_HPMCOUNTER25H, cv32e40p_pkg_CSR_HPMCOUNTER26H, cv32e40p_pkg_CSR_HPMCOUNTER27H, cv32e40p_pkg_CSR_HPMCOUNTER28H, cv32e40p_pkg_CSR_HPMCOUNTER29H, cv32e40p_pkg_CSR_HPMCOUNTER30H, cv32e40p_pkg_CSR_HPMCOUNTER31H: csr_rdata_int = mhpmcounter_q[(csr_addr_i[4:0] * 64) + 63-:32];
					cv32e40p_pkg_CSR_MCOUNTINHIBIT: csr_rdata_int = mcountinhibit_q;
					cv32e40p_pkg_CSR_MHPMEVENT3, cv32e40p_pkg_CSR_MHPMEVENT4, cv32e40p_pkg_CSR_MHPMEVENT5, cv32e40p_pkg_CSR_MHPMEVENT6, cv32e40p_pkg_CSR_MHPMEVENT7, cv32e40p_pkg_CSR_MHPMEVENT8, cv32e40p_pkg_CSR_MHPMEVENT9, cv32e40p_pkg_CSR_MHPMEVENT10, cv32e40p_pkg_CSR_MHPMEVENT11, cv32e40p_pkg_CSR_MHPMEVENT12, cv32e40p_pkg_CSR_MHPMEVENT13, cv32e40p_pkg_CSR_MHPMEVENT14, cv32e40p_pkg_CSR_MHPMEVENT15, cv32e40p_pkg_CSR_MHPMEVENT16, cv32e40p_pkg_CSR_MHPMEVENT17, cv32e40p_pkg_CSR_MHPMEVENT18, cv32e40p_pkg_CSR_MHPMEVENT19, cv32e40p_pkg_CSR_MHPMEVENT20, cv32e40p_pkg_CSR_MHPMEVENT21, cv32e40p_pkg_CSR_MHPMEVENT22, cv32e40p_pkg_CSR_MHPMEVENT23, cv32e40p_pkg_CSR_MHPMEVENT24, cv32e40p_pkg_CSR_MHPMEVENT25, cv32e40p_pkg_CSR_MHPMEVENT26, cv32e40p_pkg_CSR_MHPMEVENT27, cv32e40p_pkg_CSR_MHPMEVENT28, cv32e40p_pkg_CSR_MHPMEVENT29, cv32e40p_pkg_CSR_MHPMEVENT30, cv32e40p_pkg_CSR_MHPMEVENT31: csr_rdata_int = mhpmevent_q[csr_addr_i[4:0] * 32+:32];
					cv32e40p_pkg_CSR_LPSTART0: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_start_i[0+:32]);
					cv32e40p_pkg_CSR_LPEND0: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_end_i[0+:32]);
					cv32e40p_pkg_CSR_LPCOUNT0: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_cnt_i[0+:32]);
					cv32e40p_pkg_CSR_LPSTART1: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_start_i[32+:32]);
					cv32e40p_pkg_CSR_LPEND1: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_end_i[32+:32]);
					cv32e40p_pkg_CSR_LPCOUNT1: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_cnt_i[32+:32]);
					cv32e40p_pkg_CSR_PMPCFG0: csr_rdata_int = (USE_PMP ? pmp_reg_q[128+:32] : {32 {1'sb0}});
					cv32e40p_pkg_CSR_PMPCFG1: csr_rdata_int = (USE_PMP ? pmp_reg_q[160+:32] : {32 {1'sb0}});
					cv32e40p_pkg_CSR_PMPCFG2: csr_rdata_int = (USE_PMP ? pmp_reg_q[192+:32] : {32 {1'sb0}});
					cv32e40p_pkg_CSR_PMPCFG3: csr_rdata_int = (USE_PMP ? pmp_reg_q[224+:32] : {32 {1'sb0}});
					cv32e40p_pkg_CSR_PMPADDR0, cv32e40p_pkg_CSR_PMPADDR1, cv32e40p_pkg_CSR_PMPADDR2, cv32e40p_pkg_CSR_PMPADDR3, cv32e40p_pkg_CSR_PMPADDR4, cv32e40p_pkg_CSR_PMPADDR5, cv32e40p_pkg_CSR_PMPADDR6, cv32e40p_pkg_CSR_PMPADDR7, cv32e40p_pkg_CSR_PMPADDR8, cv32e40p_pkg_CSR_PMPADDR9, cv32e40p_pkg_CSR_PMPADDR10, cv32e40p_pkg_CSR_PMPADDR11, cv32e40p_pkg_CSR_PMPADDR12, cv32e40p_pkg_CSR_PMPADDR13, cv32e40p_pkg_CSR_PMPADDR14, cv32e40p_pkg_CSR_PMPADDR15: csr_rdata_int = (USE_PMP ? pmp_reg_q[256 + (csr_addr_i[3:0] * 32)+:32] : {32 {1'sb0}});
					cv32e40p_pkg_CSR_USTATUS: csr_rdata_int = {27'b000000000000000000000000000, mstatus_q[4], 3'h0, mstatus_q[6]};
					cv32e40p_pkg_CSR_UTVEC: csr_rdata_int = {utvec_q, 6'h00, utvec_mode_q};
					cv32e40p_pkg_CSR_UHARTID: csr_rdata_int = (!PULP_XPULP ? 'b0 : hart_id_i);
					cv32e40p_pkg_CSR_UEPC: csr_rdata_int = uepc_q;
					cv32e40p_pkg_CSR_UCAUSE: csr_rdata_int = {ucause_q[5], 26'h0000000, ucause_q[4:0]};
					cv32e40p_pkg_CSR_PRIVLV: csr_rdata_int = (!PULP_XPULP ? 'b0 : {30'h00000000, priv_lvl_q});
					default: csr_rdata_int = {32 {1'sb0}};
				endcase
		end
		else begin : gen_no_pulp_secure_read_logic
			always @(*)
				case (csr_addr_i)
					cv32e40p_pkg_CSR_FFLAGS: csr_rdata_int = (FPU == 1 ? {27'b000000000000000000000000000, fflags_q} : {32 {1'sb0}});
					cv32e40p_pkg_CSR_FRM: csr_rdata_int = (FPU == 1 ? {29'b00000000000000000000000000000, frm_q} : {32 {1'sb0}});
					cv32e40p_pkg_CSR_FCSR: csr_rdata_int = (FPU == 1 ? {24'b000000000000000000000000, frm_q, fflags_q} : {32 {1'sb0}});
					cv32e40p_pkg_CSR_MSTATUS: csr_rdata_int = {14'b00000000000000, mstatus_q[0], 4'b0000, mstatus_q[2-:2], 3'b000, mstatus_q[3], 2'h0, mstatus_q[4], mstatus_q[5], 2'h0, mstatus_q[6]};
					cv32e40p_pkg_CSR_MISA: csr_rdata_int = MISA_VALUE;
					cv32e40p_pkg_CSR_MIE: csr_rdata_int = mie_q;
					cv32e40p_pkg_CSR_MTVEC: csr_rdata_int = {mtvec_q, 6'h00, mtvec_mode_q};
					cv32e40p_pkg_CSR_MSCRATCH: csr_rdata_int = mscratch_q;
					cv32e40p_pkg_CSR_MEPC: csr_rdata_int = mepc_q;
					cv32e40p_pkg_CSR_MCAUSE: csr_rdata_int = {mcause_q[5], 26'b00000000000000000000000000, mcause_q[4:0]};
					cv32e40p_pkg_CSR_MIP: csr_rdata_int = mip;
					cv32e40p_pkg_CSR_MHARTID: csr_rdata_int = hart_id_i;
					cv32e40p_pkg_CSR_MVENDORID: csr_rdata_int = {cv32e40p_pkg_MVENDORID_BANK, cv32e40p_pkg_MVENDORID_OFFSET};
					cv32e40p_pkg_CSR_MARCHID: csr_rdata_int = cv32e40p_pkg_MARCHID;
					cv32e40p_pkg_CSR_MIMPID, cv32e40p_pkg_CSR_MTVAL: csr_rdata_int = 'b0;
					cv32e40p_pkg_CSR_TSELECT, cv32e40p_pkg_CSR_TDATA3, cv32e40p_pkg_CSR_MCONTEXT, cv32e40p_pkg_CSR_SCONTEXT: csr_rdata_int = 'b0;
					cv32e40p_pkg_CSR_TDATA1: csr_rdata_int = tmatch_control_rdata;
					cv32e40p_pkg_CSR_TDATA2: csr_rdata_int = tmatch_value_rdata;
					cv32e40p_pkg_CSR_TINFO: csr_rdata_int = tinfo_types;
					cv32e40p_pkg_CSR_DCSR: csr_rdata_int = dcsr_q;
					cv32e40p_pkg_CSR_DPC: csr_rdata_int = depc_q;
					cv32e40p_pkg_CSR_DSCRATCH0: csr_rdata_int = dscratch0_q;
					cv32e40p_pkg_CSR_DSCRATCH1: csr_rdata_int = dscratch1_q;
					cv32e40p_pkg_CSR_MCYCLE, cv32e40p_pkg_CSR_MINSTRET, cv32e40p_pkg_CSR_MHPMCOUNTER3, cv32e40p_pkg_CSR_MHPMCOUNTER4, cv32e40p_pkg_CSR_MHPMCOUNTER5, cv32e40p_pkg_CSR_MHPMCOUNTER6, cv32e40p_pkg_CSR_MHPMCOUNTER7, cv32e40p_pkg_CSR_MHPMCOUNTER8, cv32e40p_pkg_CSR_MHPMCOUNTER9, cv32e40p_pkg_CSR_MHPMCOUNTER10, cv32e40p_pkg_CSR_MHPMCOUNTER11, cv32e40p_pkg_CSR_MHPMCOUNTER12, cv32e40p_pkg_CSR_MHPMCOUNTER13, cv32e40p_pkg_CSR_MHPMCOUNTER14, cv32e40p_pkg_CSR_MHPMCOUNTER15, cv32e40p_pkg_CSR_MHPMCOUNTER16, cv32e40p_pkg_CSR_MHPMCOUNTER17, cv32e40p_pkg_CSR_MHPMCOUNTER18, cv32e40p_pkg_CSR_MHPMCOUNTER19, cv32e40p_pkg_CSR_MHPMCOUNTER20, cv32e40p_pkg_CSR_MHPMCOUNTER21, cv32e40p_pkg_CSR_MHPMCOUNTER22, cv32e40p_pkg_CSR_MHPMCOUNTER23, cv32e40p_pkg_CSR_MHPMCOUNTER24, cv32e40p_pkg_CSR_MHPMCOUNTER25, cv32e40p_pkg_CSR_MHPMCOUNTER26, cv32e40p_pkg_CSR_MHPMCOUNTER27, cv32e40p_pkg_CSR_MHPMCOUNTER28, cv32e40p_pkg_CSR_MHPMCOUNTER29, cv32e40p_pkg_CSR_MHPMCOUNTER30, cv32e40p_pkg_CSR_MHPMCOUNTER31, cv32e40p_pkg_CSR_CYCLE, cv32e40p_pkg_CSR_INSTRET, cv32e40p_pkg_CSR_HPMCOUNTER3, cv32e40p_pkg_CSR_HPMCOUNTER4, cv32e40p_pkg_CSR_HPMCOUNTER5, cv32e40p_pkg_CSR_HPMCOUNTER6, cv32e40p_pkg_CSR_HPMCOUNTER7, cv32e40p_pkg_CSR_HPMCOUNTER8, cv32e40p_pkg_CSR_HPMCOUNTER9, cv32e40p_pkg_CSR_HPMCOUNTER10, cv32e40p_pkg_CSR_HPMCOUNTER11, cv32e40p_pkg_CSR_HPMCOUNTER12, cv32e40p_pkg_CSR_HPMCOUNTER13, cv32e40p_pkg_CSR_HPMCOUNTER14, cv32e40p_pkg_CSR_HPMCOUNTER15, cv32e40p_pkg_CSR_HPMCOUNTER16, cv32e40p_pkg_CSR_HPMCOUNTER17, cv32e40p_pkg_CSR_HPMCOUNTER18, cv32e40p_pkg_CSR_HPMCOUNTER19, cv32e40p_pkg_CSR_HPMCOUNTER20, cv32e40p_pkg_CSR_HPMCOUNTER21, cv32e40p_pkg_CSR_HPMCOUNTER22, cv32e40p_pkg_CSR_HPMCOUNTER23, cv32e40p_pkg_CSR_HPMCOUNTER24, cv32e40p_pkg_CSR_HPMCOUNTER25, cv32e40p_pkg_CSR_HPMCOUNTER26, cv32e40p_pkg_CSR_HPMCOUNTER27, cv32e40p_pkg_CSR_HPMCOUNTER28, cv32e40p_pkg_CSR_HPMCOUNTER29, cv32e40p_pkg_CSR_HPMCOUNTER30, cv32e40p_pkg_CSR_HPMCOUNTER31: csr_rdata_int = mhpmcounter_q[(csr_addr_i[4:0] * 64) + 31-:32];
					cv32e40p_pkg_CSR_MCYCLEH, cv32e40p_pkg_CSR_MINSTRETH, cv32e40p_pkg_CSR_MHPMCOUNTER3H, cv32e40p_pkg_CSR_MHPMCOUNTER4H, cv32e40p_pkg_CSR_MHPMCOUNTER5H, cv32e40p_pkg_CSR_MHPMCOUNTER6H, cv32e40p_pkg_CSR_MHPMCOUNTER7H, cv32e40p_pkg_CSR_MHPMCOUNTER8H, cv32e40p_pkg_CSR_MHPMCOUNTER9H, cv32e40p_pkg_CSR_MHPMCOUNTER10H, cv32e40p_pkg_CSR_MHPMCOUNTER11H, cv32e40p_pkg_CSR_MHPMCOUNTER12H, cv32e40p_pkg_CSR_MHPMCOUNTER13H, cv32e40p_pkg_CSR_MHPMCOUNTER14H, cv32e40p_pkg_CSR_MHPMCOUNTER15H, cv32e40p_pkg_CSR_MHPMCOUNTER16H, cv32e40p_pkg_CSR_MHPMCOUNTER17H, cv32e40p_pkg_CSR_MHPMCOUNTER18H, cv32e40p_pkg_CSR_MHPMCOUNTER19H, cv32e40p_pkg_CSR_MHPMCOUNTER20H, cv32e40p_pkg_CSR_MHPMCOUNTER21H, cv32e40p_pkg_CSR_MHPMCOUNTER22H, cv32e40p_pkg_CSR_MHPMCOUNTER23H, cv32e40p_pkg_CSR_MHPMCOUNTER24H, cv32e40p_pkg_CSR_MHPMCOUNTER25H, cv32e40p_pkg_CSR_MHPMCOUNTER26H, cv32e40p_pkg_CSR_MHPMCOUNTER27H, cv32e40p_pkg_CSR_MHPMCOUNTER28H, cv32e40p_pkg_CSR_MHPMCOUNTER29H, cv32e40p_pkg_CSR_MHPMCOUNTER30H, cv32e40p_pkg_CSR_MHPMCOUNTER31H, cv32e40p_pkg_CSR_CYCLEH, cv32e40p_pkg_CSR_INSTRETH, cv32e40p_pkg_CSR_HPMCOUNTER3H, cv32e40p_pkg_CSR_HPMCOUNTER4H, cv32e40p_pkg_CSR_HPMCOUNTER5H, cv32e40p_pkg_CSR_HPMCOUNTER6H, cv32e40p_pkg_CSR_HPMCOUNTER7H, cv32e40p_pkg_CSR_HPMCOUNTER8H, cv32e40p_pkg_CSR_HPMCOUNTER9H, cv32e40p_pkg_CSR_HPMCOUNTER10H, cv32e40p_pkg_CSR_HPMCOUNTER11H, cv32e40p_pkg_CSR_HPMCOUNTER12H, cv32e40p_pkg_CSR_HPMCOUNTER13H, cv32e40p_pkg_CSR_HPMCOUNTER14H, cv32e40p_pkg_CSR_HPMCOUNTER15H, cv32e40p_pkg_CSR_HPMCOUNTER16H, cv32e40p_pkg_CSR_HPMCOUNTER17H, cv32e40p_pkg_CSR_HPMCOUNTER18H, cv32e40p_pkg_CSR_HPMCOUNTER19H, cv32e40p_pkg_CSR_HPMCOUNTER20H, cv32e40p_pkg_CSR_HPMCOUNTER21H, cv32e40p_pkg_CSR_HPMCOUNTER22H, cv32e40p_pkg_CSR_HPMCOUNTER23H, cv32e40p_pkg_CSR_HPMCOUNTER24H, cv32e40p_pkg_CSR_HPMCOUNTER25H, cv32e40p_pkg_CSR_HPMCOUNTER26H, cv32e40p_pkg_CSR_HPMCOUNTER27H, cv32e40p_pkg_CSR_HPMCOUNTER28H, cv32e40p_pkg_CSR_HPMCOUNTER29H, cv32e40p_pkg_CSR_HPMCOUNTER30H, cv32e40p_pkg_CSR_HPMCOUNTER31H: csr_rdata_int = mhpmcounter_q[(csr_addr_i[4:0] * 64) + 63-:32];
					cv32e40p_pkg_CSR_MCOUNTINHIBIT: csr_rdata_int = mcountinhibit_q;
					cv32e40p_pkg_CSR_MHPMEVENT3, cv32e40p_pkg_CSR_MHPMEVENT4, cv32e40p_pkg_CSR_MHPMEVENT5, cv32e40p_pkg_CSR_MHPMEVENT6, cv32e40p_pkg_CSR_MHPMEVENT7, cv32e40p_pkg_CSR_MHPMEVENT8, cv32e40p_pkg_CSR_MHPMEVENT9, cv32e40p_pkg_CSR_MHPMEVENT10, cv32e40p_pkg_CSR_MHPMEVENT11, cv32e40p_pkg_CSR_MHPMEVENT12, cv32e40p_pkg_CSR_MHPMEVENT13, cv32e40p_pkg_CSR_MHPMEVENT14, cv32e40p_pkg_CSR_MHPMEVENT15, cv32e40p_pkg_CSR_MHPMEVENT16, cv32e40p_pkg_CSR_MHPMEVENT17, cv32e40p_pkg_CSR_MHPMEVENT18, cv32e40p_pkg_CSR_MHPMEVENT19, cv32e40p_pkg_CSR_MHPMEVENT20, cv32e40p_pkg_CSR_MHPMEVENT21, cv32e40p_pkg_CSR_MHPMEVENT22, cv32e40p_pkg_CSR_MHPMEVENT23, cv32e40p_pkg_CSR_MHPMEVENT24, cv32e40p_pkg_CSR_MHPMEVENT25, cv32e40p_pkg_CSR_MHPMEVENT26, cv32e40p_pkg_CSR_MHPMEVENT27, cv32e40p_pkg_CSR_MHPMEVENT28, cv32e40p_pkg_CSR_MHPMEVENT29, cv32e40p_pkg_CSR_MHPMEVENT30, cv32e40p_pkg_CSR_MHPMEVENT31: csr_rdata_int = mhpmevent_q[csr_addr_i[4:0] * 32+:32];
					cv32e40p_pkg_CSR_LPSTART0: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_start_i[0+:32]);
					cv32e40p_pkg_CSR_LPEND0: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_end_i[0+:32]);
					cv32e40p_pkg_CSR_LPCOUNT0: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_cnt_i[0+:32]);
					cv32e40p_pkg_CSR_LPSTART1: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_start_i[32+:32]);
					cv32e40p_pkg_CSR_LPEND1: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_end_i[32+:32]);
					cv32e40p_pkg_CSR_LPCOUNT1: csr_rdata_int = (!PULP_XPULP ? 'b0 : hwlp_cnt_i[32+:32]);
					cv32e40p_pkg_CSR_UHARTID: csr_rdata_int = (!PULP_XPULP ? 'b0 : hart_id_i);
					cv32e40p_pkg_CSR_PRIVLV: csr_rdata_int = (!PULP_XPULP ? 'b0 : {30'h00000000, priv_lvl_q});
					default: csr_rdata_int = {32 {1'sb0}};
				endcase
		end
	endgenerate
	localparam [1:0] cv32e40p_pkg_PRIV_LVL_M = 2'b11;
	localparam [1:0] cv32e40p_pkg_PRIV_LVL_U = 2'b00;
	generate
		if (PULP_SECURE == 1) begin : gen_pulp_secure_write_logic
			function automatic [1:0] sv2v_cast_2;
				input reg [1:0] inp;
				sv2v_cast_2 = inp;
			endfunction
			always @(*) begin
				fflags_n = fflags_q;
				frm_n = frm_q;
				mscratch_n = mscratch_q;
				mepc_n = mepc_q;
				uepc_n = uepc_q;
				depc_n = depc_q;
				dcsr_n = dcsr_q;
				dscratch0_n = dscratch0_q;
				dscratch1_n = dscratch1_q;
				mstatus_n = mstatus_q;
				mcause_n = mcause_q;
				ucause_n = ucause_q;
				hwlp_we_o = {3 {1'sb0}};
				hwlp_regid_o = {N_HWLP_BITS {1'sb0}};
				exception_pc = pc_id_i;
				priv_lvl_n = priv_lvl_q;
				mtvec_n = (csr_mtvec_init_i ? mtvec_addr_i[31:8] : mtvec_q);
				utvec_n = utvec_q;
				mtvec_mode_n = mtvec_mode_q;
				utvec_mode_n = utvec_mode_q;
				pmp_reg_n[767-:512] = pmp_reg_q[767-:512];
				pmp_reg_n[255-:128] = pmp_reg_q[255-:128];
				pmpaddr_we = {16 {1'sb0}};
				pmpcfg_we = {16 {1'sb0}};
				mie_n = mie_q;
				if (FPU == 1)
					if (fflags_we_i)
						fflags_n = fflags_i | fflags_q;
				case (csr_addr_i)
					cv32e40p_pkg_CSR_FFLAGS:
						if (csr_we_int)
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
					cv32e40p_pkg_CSR_FRM:
						if (csr_we_int)
							frm_n = (FPU == 1 ? csr_wdata_int[2:0] : {3 {1'sb0}});
					cv32e40p_pkg_CSR_FCSR:
						if (csr_we_int) begin
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
							frm_n = (FPU == 1 ? csr_wdata_int[7:cv32e40p_pkg_C_FFLAG] : {3 {1'sb0}});
						end
					cv32e40p_pkg_CSR_MSTATUS:
						if (csr_we_int)
							mstatus_n = {csr_wdata_int[MSTATUS_UIE_BIT], csr_wdata_int[MSTATUS_MIE_BIT], csr_wdata_int[MSTATUS_UPIE_BIT], csr_wdata_int[MSTATUS_MPIE_BIT], sv2v_cast_2(csr_wdata_int[MSTATUS_MPP_BIT_HIGH:MSTATUS_MPP_BIT_LOW]), csr_wdata_int[MSTATUS_MPRV_BIT]};
					cv32e40p_pkg_CSR_MIE:
						if (csr_we_int)
							mie_n = csr_wdata_int & cv32e40p_pkg_IRQ_MASK;
					cv32e40p_pkg_CSR_MTVEC:
						if (csr_we_int) begin
							mtvec_n = csr_wdata_int[31:8];
							mtvec_mode_n = {1'b0, csr_wdata_int[0]};
						end
					cv32e40p_pkg_CSR_MSCRATCH:
						if (csr_we_int)
							mscratch_n = csr_wdata_int;
					cv32e40p_pkg_CSR_MEPC:
						if (csr_we_int)
							mepc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					cv32e40p_pkg_CSR_MCAUSE:
						if (csr_we_int)
							mcause_n = {csr_wdata_int[31], csr_wdata_int[4:0]};
					cv32e40p_pkg_CSR_DCSR:
						if (csr_we_int) begin
							dcsr_n[15] = csr_wdata_int[15];
							dcsr_n[13] = 1'b0;
							dcsr_n[12] = csr_wdata_int[12];
							dcsr_n[11] = csr_wdata_int[11];
							dcsr_n[10] = 1'b0;
							dcsr_n[9] = 1'b0;
							dcsr_n[4] = 1'b0;
							dcsr_n[2] = csr_wdata_int[2];
							dcsr_n[1-:2] = (csr_wdata_int[1:0] == cv32e40p_pkg_PRIV_LVL_M ? cv32e40p_pkg_PRIV_LVL_M : cv32e40p_pkg_PRIV_LVL_U);
						end
					cv32e40p_pkg_CSR_DPC:
						if (csr_we_int)
							depc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					cv32e40p_pkg_CSR_DSCRATCH0:
						if (csr_we_int)
							dscratch0_n = csr_wdata_int;
					cv32e40p_pkg_CSR_DSCRATCH1:
						if (csr_we_int)
							dscratch1_n = csr_wdata_int;
					cv32e40p_pkg_CSR_LPSTART0:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b0;
						end
					cv32e40p_pkg_CSR_LPEND0:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b0;
						end
					cv32e40p_pkg_CSR_LPCOUNT0:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b0;
						end
					cv32e40p_pkg_CSR_LPSTART1:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b1;
						end
					cv32e40p_pkg_CSR_LPEND1:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b1;
						end
					cv32e40p_pkg_CSR_LPCOUNT1:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b1;
						end
					cv32e40p_pkg_CSR_PMPCFG0:
						if (csr_we_int) begin
							pmp_reg_n[128+:32] = csr_wdata_int;
							pmpcfg_we[3:0] = 4'b1111;
						end
					cv32e40p_pkg_CSR_PMPCFG1:
						if (csr_we_int) begin
							pmp_reg_n[160+:32] = csr_wdata_int;
							pmpcfg_we[7:4] = 4'b1111;
						end
					cv32e40p_pkg_CSR_PMPCFG2:
						if (csr_we_int) begin
							pmp_reg_n[192+:32] = csr_wdata_int;
							pmpcfg_we[11:8] = 4'b1111;
						end
					cv32e40p_pkg_CSR_PMPCFG3:
						if (csr_we_int) begin
							pmp_reg_n[224+:32] = csr_wdata_int;
							pmpcfg_we[15:12] = 4'b1111;
						end
					cv32e40p_pkg_CSR_PMPADDR0, cv32e40p_pkg_CSR_PMPADDR1, cv32e40p_pkg_CSR_PMPADDR2, cv32e40p_pkg_CSR_PMPADDR3, cv32e40p_pkg_CSR_PMPADDR4, cv32e40p_pkg_CSR_PMPADDR5, cv32e40p_pkg_CSR_PMPADDR6, cv32e40p_pkg_CSR_PMPADDR7, cv32e40p_pkg_CSR_PMPADDR8, cv32e40p_pkg_CSR_PMPADDR9, cv32e40p_pkg_CSR_PMPADDR10, cv32e40p_pkg_CSR_PMPADDR11, cv32e40p_pkg_CSR_PMPADDR12, cv32e40p_pkg_CSR_PMPADDR13, cv32e40p_pkg_CSR_PMPADDR14, cv32e40p_pkg_CSR_PMPADDR15:
						if (csr_we_int) begin
							pmp_reg_n[256 + (csr_addr_i[3:0] * 32)+:32] = csr_wdata_int;
							pmpaddr_we[csr_addr_i[3:0]] = 1'b1;
						end
					cv32e40p_pkg_CSR_USTATUS:
						if (csr_we_int)
							mstatus_n = {csr_wdata_int[MSTATUS_UIE_BIT], mstatus_q[5], csr_wdata_int[MSTATUS_UPIE_BIT], mstatus_q[3], sv2v_cast_2(mstatus_q[2-:2]), mstatus_q[0]};
					cv32e40p_pkg_CSR_UTVEC:
						if (csr_we_int) begin
							utvec_n = csr_wdata_int[31:8];
							utvec_mode_n = {1'b0, csr_wdata_int[0]};
						end
					cv32e40p_pkg_CSR_UEPC:
						if (csr_we_int)
							uepc_n = csr_wdata_int;
					cv32e40p_pkg_CSR_UCAUSE:
						if (csr_we_int)
							ucause_n = {csr_wdata_int[31], csr_wdata_int[4:0]};
				endcase
				case (1'b1)
					csr_save_cause_i: begin
						case (1'b1)
							csr_save_if_i: exception_pc = pc_if_i;
							csr_save_id_i: exception_pc = pc_id_i;
							csr_save_ex_i: exception_pc = pc_ex_i;
							default:
								;
						endcase
						case (priv_lvl_q)
							cv32e40p_pkg_PRIV_LVL_U:
								if (~is_irq) begin
									priv_lvl_n = cv32e40p_pkg_PRIV_LVL_M;
									mstatus_n[3] = mstatus_q[6];
									mstatus_n[5] = 1'b0;
									mstatus_n[2-:2] = cv32e40p_pkg_PRIV_LVL_U;
									if (debug_csr_save_i)
										depc_n = exception_pc;
									else
										mepc_n = exception_pc;
									mcause_n = csr_cause_i;
								end
								else if (~csr_irq_sec_i) begin
									priv_lvl_n = cv32e40p_pkg_PRIV_LVL_U;
									mstatus_n[4] = mstatus_q[6];
									mstatus_n[6] = 1'b0;
									if (debug_csr_save_i)
										depc_n = exception_pc;
									else
										uepc_n = exception_pc;
									ucause_n = csr_cause_i;
								end
								else begin
									priv_lvl_n = cv32e40p_pkg_PRIV_LVL_M;
									mstatus_n[3] = mstatus_q[6];
									mstatus_n[5] = 1'b0;
									mstatus_n[2-:2] = cv32e40p_pkg_PRIV_LVL_U;
									if (debug_csr_save_i)
										depc_n = exception_pc;
									else
										mepc_n = exception_pc;
									mcause_n = csr_cause_i;
								end
							cv32e40p_pkg_PRIV_LVL_M:
								if (debug_csr_save_i) begin
									dcsr_n[1-:2] = cv32e40p_pkg_PRIV_LVL_M;
									dcsr_n[8-:3] = debug_cause_i;
									depc_n = exception_pc;
								end
								else begin
									priv_lvl_n = cv32e40p_pkg_PRIV_LVL_M;
									mstatus_n[3] = mstatus_q[5];
									mstatus_n[5] = 1'b0;
									mstatus_n[2-:2] = cv32e40p_pkg_PRIV_LVL_M;
									mepc_n = exception_pc;
									mcause_n = csr_cause_i;
								end
							default:
								;
						endcase
					end
					csr_restore_uret_i: begin
						mstatus_n[6] = mstatus_q[4];
						priv_lvl_n = cv32e40p_pkg_PRIV_LVL_U;
						mstatus_n[4] = 1'b1;
					end
					csr_restore_mret_i:
						case (mstatus_q[2-:2])
							cv32e40p_pkg_PRIV_LVL_U: begin
								mstatus_n[6] = mstatus_q[3];
								priv_lvl_n = cv32e40p_pkg_PRIV_LVL_U;
								mstatus_n[3] = 1'b1;
								mstatus_n[2-:2] = cv32e40p_pkg_PRIV_LVL_U;
							end
							cv32e40p_pkg_PRIV_LVL_M: begin
								mstatus_n[5] = mstatus_q[3];
								priv_lvl_n = cv32e40p_pkg_PRIV_LVL_M;
								mstatus_n[3] = 1'b1;
								mstatus_n[2-:2] = cv32e40p_pkg_PRIV_LVL_U;
							end
							default:
								;
						endcase
					csr_restore_dret_i: priv_lvl_n = dcsr_q[1-:2];
					default:
						;
				endcase
			end
		end
		else begin : gen_no_pulp_secure_write_logic
			function automatic [1:0] sv2v_cast_2;
				input reg [1:0] inp;
				sv2v_cast_2 = inp;
			endfunction
			always @(*) begin
				fflags_n = fflags_q;
				frm_n = frm_q;
				mscratch_n = mscratch_q;
				mepc_n = mepc_q;
				uepc_n = 'b0;
				depc_n = depc_q;
				dcsr_n = dcsr_q;
				dscratch0_n = dscratch0_q;
				dscratch1_n = dscratch1_q;
				mstatus_n = mstatus_q;
				mcause_n = mcause_q;
				ucause_n = {6 {1'sb0}};
				hwlp_we_o = {3 {1'sb0}};
				hwlp_regid_o = {N_HWLP_BITS {1'sb0}};
				exception_pc = pc_id_i;
				priv_lvl_n = priv_lvl_q;
				mtvec_n = (csr_mtvec_init_i ? mtvec_addr_i[31:8] : mtvec_q);
				utvec_n = {24 {1'sb0}};
				pmp_reg_n[767-:512] = {512 {1'sb0}};
				pmp_reg_n[255-:128] = {128 {1'sb0}};
				pmp_reg_n[127-:128] = {128 {1'sb0}};
				pmpaddr_we = {16 {1'sb0}};
				pmpcfg_we = {16 {1'sb0}};
				mie_n = mie_q;
				mtvec_mode_n = mtvec_mode_q;
				utvec_mode_n = {2 {1'sb0}};
				if (FPU == 1)
					if (fflags_we_i)
						fflags_n = fflags_i | fflags_q;
				case (csr_addr_i)
					cv32e40p_pkg_CSR_FFLAGS:
						if (csr_we_int)
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
					cv32e40p_pkg_CSR_FRM:
						if (csr_we_int)
							frm_n = (FPU == 1 ? csr_wdata_int[2:0] : {3 {1'sb0}});
					cv32e40p_pkg_CSR_FCSR:
						if (csr_we_int) begin
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
							frm_n = (FPU == 1 ? csr_wdata_int[7:cv32e40p_pkg_C_FFLAG] : {3 {1'sb0}});
						end
					cv32e40p_pkg_CSR_MSTATUS:
						if (csr_we_int)
							mstatus_n = {csr_wdata_int[MSTATUS_UIE_BIT], csr_wdata_int[MSTATUS_MIE_BIT], csr_wdata_int[MSTATUS_UPIE_BIT], csr_wdata_int[MSTATUS_MPIE_BIT], sv2v_cast_2(csr_wdata_int[MSTATUS_MPP_BIT_HIGH:MSTATUS_MPP_BIT_LOW]), csr_wdata_int[MSTATUS_MPRV_BIT]};
					cv32e40p_pkg_CSR_MIE:
						if (csr_we_int)
							mie_n = csr_wdata_int & cv32e40p_pkg_IRQ_MASK;
					cv32e40p_pkg_CSR_MTVEC:
						if (csr_we_int) begin
							mtvec_n = csr_wdata_int[31:8];
							mtvec_mode_n = {1'b0, csr_wdata_int[0]};
						end
					cv32e40p_pkg_CSR_MSCRATCH:
						if (csr_we_int)
							mscratch_n = csr_wdata_int;
					cv32e40p_pkg_CSR_MEPC:
						if (csr_we_int)
							mepc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					cv32e40p_pkg_CSR_MCAUSE:
						if (csr_we_int)
							mcause_n = {csr_wdata_int[31], csr_wdata_int[4:0]};
					cv32e40p_pkg_CSR_DCSR:
						if (csr_we_int) begin
							dcsr_n[15] = csr_wdata_int[15];
							dcsr_n[13] = 1'b0;
							dcsr_n[12] = 1'b0;
							dcsr_n[11] = csr_wdata_int[11];
							dcsr_n[10] = 1'b0;
							dcsr_n[9] = 1'b0;
							dcsr_n[4] = 1'b0;
							dcsr_n[2] = csr_wdata_int[2];
							dcsr_n[1-:2] = cv32e40p_pkg_PRIV_LVL_M;
						end
					cv32e40p_pkg_CSR_DPC:
						if (csr_we_int)
							depc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					cv32e40p_pkg_CSR_DSCRATCH0:
						if (csr_we_int)
							dscratch0_n = csr_wdata_int;
					cv32e40p_pkg_CSR_DSCRATCH1:
						if (csr_we_int)
							dscratch1_n = csr_wdata_int;
					cv32e40p_pkg_CSR_LPSTART0:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b0;
						end
					cv32e40p_pkg_CSR_LPEND0:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b0;
						end
					cv32e40p_pkg_CSR_LPCOUNT0:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b0;
						end
					cv32e40p_pkg_CSR_LPSTART1:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b1;
						end
					cv32e40p_pkg_CSR_LPEND1:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b1;
						end
					cv32e40p_pkg_CSR_LPCOUNT1:
						if (PULP_XPULP && csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b1;
						end
				endcase
				case (1'b1)
					csr_save_cause_i: begin
						case (1'b1)
							csr_save_if_i: exception_pc = pc_if_i;
							csr_save_id_i: exception_pc = pc_id_i;
							csr_save_ex_i: exception_pc = pc_ex_i;
							default:
								;
						endcase
						if (debug_csr_save_i) begin
							dcsr_n[1-:2] = cv32e40p_pkg_PRIV_LVL_M;
							dcsr_n[8-:3] = debug_cause_i;
							depc_n = exception_pc;
						end
						else begin
							priv_lvl_n = cv32e40p_pkg_PRIV_LVL_M;
							mstatus_n[3] = mstatus_q[5];
							mstatus_n[5] = 1'b0;
							mstatus_n[2-:2] = cv32e40p_pkg_PRIV_LVL_M;
							mepc_n = exception_pc;
							mcause_n = csr_cause_i;
						end
					end
					csr_restore_mret_i: begin
						mstatus_n[5] = mstatus_q[3];
						priv_lvl_n = cv32e40p_pkg_PRIV_LVL_M;
						mstatus_n[3] = 1'b1;
						mstatus_n[2-:2] = cv32e40p_pkg_PRIV_LVL_M;
					end
					csr_restore_dret_i: priv_lvl_n = dcsr_q[1-:2];
					default:
						;
				endcase
			end
		end
	endgenerate
	assign hwlp_data_o = (PULP_XPULP ? csr_wdata_int : {32 {1'sb0}});
	always @(*) begin
		csr_wdata_int = csr_wdata_i;
		csr_we_int = 1'b1;
		case (csr_op_i)
			cv32e40p_pkg_CSR_OP_WRITE: csr_wdata_int = csr_wdata_i;
			cv32e40p_pkg_CSR_OP_SET: csr_wdata_int = csr_wdata_i | csr_rdata_o;
			cv32e40p_pkg_CSR_OP_CLEAR: csr_wdata_int = ~csr_wdata_i & csr_rdata_o;
			cv32e40p_pkg_CSR_OP_READ: begin
				csr_wdata_int = csr_wdata_i;
				csr_we_int = 1'b0;
			end
		endcase
	end
	assign csr_rdata_o = csr_rdata_int;
	assign m_irq_enable_o = mstatus_q[5] && !(dcsr_q[2] && !dcsr_q[11]);
	assign u_irq_enable_o = mstatus_q[6] && !(dcsr_q[2] && !dcsr_q[11]);
	assign priv_lvl_o = priv_lvl_q;
	assign sec_lvl_o = priv_lvl_q[0];
	assign frm_o = (FPU == 1 ? frm_q : {3 {1'sb0}});
	assign mtvec_o = mtvec_q;
	assign utvec_o = utvec_q;
	assign mtvec_mode_o = mtvec_mode_q;
	assign utvec_mode_o = utvec_mode_q;
	assign mepc_o = mepc_q;
	assign uepc_o = uepc_q;
	assign mcounteren_o = (PULP_SECURE ? mcounteren_q : {32 {1'sb0}});
	assign depc_o = depc_q;
	assign pmp_addr_o = pmp_reg_q[767-:512];
	assign pmp_cfg_o = pmp_reg_q[127-:128];
	assign debug_single_step_o = dcsr_q[2];
	assign debug_ebreakm_o = dcsr_q[15];
	assign debug_ebreaku_o = dcsr_q[12];
	generate
		if (PULP_SECURE == 1) begin : gen_pmp_user
			for (j = 0; j < N_PMP_ENTRIES; j = j + 1) begin : CS_PMP_CFG
				wire [8:1] sv2v_tmp_EF2A1;
				assign sv2v_tmp_EF2A1 = pmp_reg_n[128 + (((j / 4) * 32) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (8 * ((j % 4) + 1)) - 1 : (((8 * ((j % 4) + 1)) - 1) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)) - 1))-:(((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)];
				always @(*) pmp_reg_n[j * 8+:8] = sv2v_tmp_EF2A1;
				wire [(((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1):1] sv2v_tmp_D16C1;
				assign sv2v_tmp_D16C1 = pmp_reg_q[j * 8+:8];
				always @(*) pmp_reg_q[128 + (((j / 4) * 32) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (8 * ((j % 4) + 1)) - 1 : (((8 * ((j % 4) + 1)) - 1) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)) - 1))-:(((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)] = sv2v_tmp_D16C1;
			end
			for (j = 0; j < N_PMP_ENTRIES; j = j + 1) begin : CS_PMP_REGS_FF
				always @(posedge clk or negedge rst_n)
					if (rst_n == 1'b0) begin
						pmp_reg_q[j * 8+:8] <= {8 {1'sb0}};
						pmp_reg_q[256 + (j * 32)+:32] <= {32 {1'sb0}};
					end
					else begin
						if (pmpcfg_we[j])
							pmp_reg_q[j * 8+:8] <= (USE_PMP ? pmp_reg_n[j * 8+:8] : {8 {1'sb0}});
						if (pmpaddr_we[j])
							pmp_reg_q[256 + (j * 32)+:32] <= (USE_PMP ? pmp_reg_n[256 + (j * 32)+:32] : {32 {1'sb0}});
					end
			end
			always @(posedge clk or negedge rst_n)
				if (rst_n == 1'b0) begin
					uepc_q <= {32 {1'sb0}};
					ucause_q <= {6 {1'sb0}};
					utvec_q <= {24 {1'sb0}};
					utvec_mode_q <= MTVEC_MODE;
					priv_lvl_q <= cv32e40p_pkg_PRIV_LVL_M;
				end
				else begin
					uepc_q <= uepc_n;
					ucause_q <= ucause_n;
					utvec_q <= utvec_n;
					utvec_mode_q <= utvec_mode_n;
					priv_lvl_q <= priv_lvl_n;
				end
		end
		else begin : gen_no_pmp_user
			wire [768:1] sv2v_tmp_FCD12;
			assign sv2v_tmp_FCD12 = {768 {1'sb0}};
			always @(*) pmp_reg_q = sv2v_tmp_FCD12;
			wire [32:1] sv2v_tmp_64DF4;
			assign sv2v_tmp_64DF4 = {32 {1'sb0}};
			always @(*) uepc_q = sv2v_tmp_64DF4;
			wire [6:1] sv2v_tmp_11281;
			assign sv2v_tmp_11281 = {6 {1'sb0}};
			always @(*) ucause_q = sv2v_tmp_11281;
			wire [24:1] sv2v_tmp_69B9C;
			assign sv2v_tmp_69B9C = {24 {1'sb0}};
			always @(*) utvec_q = sv2v_tmp_69B9C;
			wire [2:1] sv2v_tmp_3F1AD;
			assign sv2v_tmp_3F1AD = {2 {1'sb0}};
			always @(*) utvec_mode_q = sv2v_tmp_3F1AD;
			wire [2:1] sv2v_tmp_F7656;
			assign sv2v_tmp_F7656 = cv32e40p_pkg_PRIV_LVL_M;
			always @(*) priv_lvl_q = sv2v_tmp_F7656;
		end
	endgenerate
	localparam cv32e40p_pkg_DBG_CAUSE_NONE = 3'h0;
	localparam [3:0] cv32e40p_pkg_XDEBUGVER_STD = 4'd4;
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			frm_q <= {3 {1'sb0}};
			fflags_q <= {5 {1'sb0}};
			mstatus_q <= {4'b0000, cv32e40p_pkg_PRIV_LVL_M, 1'b0};
			mepc_q <= {32 {1'sb0}};
			mcause_q <= {6 {1'sb0}};
			depc_q <= {32 {1'sb0}};
			dcsr_q <= {cv32e40p_pkg_XDEBUGVER_STD, 12'b000000000000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, cv32e40p_pkg_DBG_CAUSE_NONE, 1'b0, 1'b0, 1'b0, 1'b0, cv32e40p_pkg_PRIV_LVL_M};
			dscratch0_q <= {32 {1'sb0}};
			dscratch1_q <= {32 {1'sb0}};
			mscratch_q <= {32 {1'sb0}};
			mie_q <= {32 {1'sb0}};
			mtvec_q <= {24 {1'sb0}};
			mtvec_mode_q <= MTVEC_MODE;
		end
		else begin
			if (FPU == 1) begin
				frm_q <= frm_n;
				fflags_q <= fflags_n;
			end
			else begin
				frm_q <= 'b0;
				fflags_q <= 'b0;
			end
			if (PULP_SECURE == 1)
				mstatus_q <= mstatus_n;
			else
				mstatus_q <= {1'b0, mstatus_n[5], 1'b0, mstatus_n[3], cv32e40p_pkg_PRIV_LVL_M, 1'b0};
			mepc_q <= mepc_n;
			mcause_q <= mcause_n;
			depc_q <= depc_n;
			dcsr_q <= dcsr_n;
			dscratch0_q <= dscratch0_n;
			dscratch1_q <= dscratch1_n;
			mscratch_q <= mscratch_n;
			mie_q <= mie_n;
			mtvec_q <= mtvec_n;
			mtvec_mode_q <= mtvec_mode_n;
		end
	localparam [3:0] cv32e40p_pkg_TTYPE_MCONTROL = 4'h2;
	generate
		if (DEBUG_TRIGGER_EN) begin : gen_trigger_regs
			reg tmatch_control_exec_q;
			reg [31:0] tmatch_value_q;
			wire tmatch_control_we;
			wire tmatch_value_we;
			assign tmatch_control_we = (csr_we_int & debug_mode_i) & (csr_addr_i == cv32e40p_pkg_CSR_TDATA1);
			assign tmatch_value_we = (csr_we_int & debug_mode_i) & (csr_addr_i == cv32e40p_pkg_CSR_TDATA2);
			always @(posedge clk or negedge rst_n)
				if (!rst_n) begin
					tmatch_control_exec_q <= 'b0;
					tmatch_value_q <= 'b0;
				end
				else begin
					if (tmatch_control_we)
						tmatch_control_exec_q <= csr_wdata_int[2];
					if (tmatch_value_we)
						tmatch_value_q <= csr_wdata_int[31:0];
				end
			assign tinfo_types = 1 << cv32e40p_pkg_TTYPE_MCONTROL;
			assign tmatch_control_rdata = {cv32e40p_pkg_TTYPE_MCONTROL, 1'b1, 6'h00, 1'b0, 1'b0, 1'b0, 2'b00, 4'h1, 1'b0, 4'h0, 1'b1, 1'b0, 1'b0, PULP_SECURE == 1, tmatch_control_exec_q, 1'b0, 1'b0};
			assign tmatch_value_rdata = tmatch_value_q;
			assign trigger_match_o = tmatch_control_exec_q & (pc_id_i[31:0] == tmatch_value_q[31:0]);
		end
		else begin : gen_no_trigger_regs
			assign tinfo_types = 'b0;
			assign tmatch_control_rdata = 'b0;
			assign tmatch_value_rdata = 'b0;
			assign trigger_match_o = 'b0;
		end
	endgenerate
	assign hpm_events[0] = 1'b1;
	assign hpm_events[1] = mhpmevent_minstret_i;
	assign hpm_events[2] = mhpmevent_ld_stall_i;
	assign hpm_events[3] = mhpmevent_jr_stall_i;
	assign hpm_events[4] = mhpmevent_imiss_i;
	assign hpm_events[5] = mhpmevent_load_i;
	assign hpm_events[6] = mhpmevent_store_i;
	assign hpm_events[7] = mhpmevent_jump_i;
	assign hpm_events[8] = mhpmevent_branch_i;
	assign hpm_events[9] = mhpmevent_branch_taken_i;
	assign hpm_events[10] = mhpmevent_compressed_i;
	assign hpm_events[11] = (PULP_CLUSTER ? mhpmevent_pipe_stall_i : 1'b0);
	assign hpm_events[12] = (!APU ? 1'b0 : apu_typeconflict_i && !apu_dep_i);
	assign hpm_events[13] = (!APU ? 1'b0 : apu_contention_i);
	assign hpm_events[14] = (!APU ? 1'b0 : apu_dep_i && !apu_contention_i);
	assign hpm_events[15] = (!APU ? 1'b0 : apu_wb_i);
	wire mcounteren_we;
	wire mcountinhibit_we;
	wire mhpmevent_we;
	assign mcounteren_we = csr_we_int & (csr_addr_i == cv32e40p_pkg_CSR_MCOUNTEREN);
	assign mcountinhibit_we = csr_we_int & (csr_addr_i == cv32e40p_pkg_CSR_MCOUNTINHIBIT);
	assign mhpmevent_we = csr_we_int & (((((((((((((((((((((((((((((csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT3) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT4)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT5)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT6)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT7)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT8)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT9)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT10)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT11)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT12)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT13)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT14)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT15)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT16)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT17)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT18)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT19)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT20)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT21)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT22)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT23)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT24)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT25)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT26)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT27)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT28)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT29)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT30)) || (csr_addr_i == cv32e40p_pkg_CSR_MHPMEVENT31));
	genvar incr_gidx;
	generate
		for (incr_gidx = 0; incr_gidx < 32; incr_gidx = incr_gidx + 1) begin : gen_mhpmcounter_increment
			assign mhpmcounter_increment[incr_gidx * 64+:64] = mhpmcounter_q[incr_gidx * 64+:64] + 1;
		end
	endgenerate
	always @(*) begin
		mcounteren_n = mcounteren_q;
		mcountinhibit_n = mcountinhibit_q;
		mhpmevent_n = mhpmevent_q;
		if (PULP_SECURE && mcounteren_we)
			mcounteren_n = csr_wdata_int;
		if (mcountinhibit_we)
			mcountinhibit_n = csr_wdata_int;
		if (mhpmevent_we)
			mhpmevent_n[csr_addr_i[4:0] * 32+:32] = csr_wdata_int;
	end
	genvar wcnt_gidx;
	generate
		for (wcnt_gidx = 0; wcnt_gidx < 32; wcnt_gidx = wcnt_gidx + 1) begin : gen_mhpmcounter_write
			assign mhpmcounter_write_lower[wcnt_gidx] = csr_we_int && (csr_addr_i == (cv32e40p_pkg_CSR_MCYCLE + wcnt_gidx));
			assign mhpmcounter_write_upper[wcnt_gidx] = ((!mhpmcounter_write_lower[wcnt_gidx] && csr_we_int) && (csr_addr_i == (cv32e40p_pkg_CSR_MCYCLEH + wcnt_gidx))) && 1'd1;
			if (!PULP_PERF_COUNTERS) begin : gen_no_pulp_perf_counters
				if (wcnt_gidx == 0) begin : gen_mhpmcounter_mcycle
					assign mhpmcounter_write_increment[wcnt_gidx] = (!mhpmcounter_write_lower[wcnt_gidx] && !mhpmcounter_write_upper[wcnt_gidx]) && !mcountinhibit_q[wcnt_gidx];
				end
				else if (wcnt_gidx == 2) begin : gen_mhpmcounter_minstret
					assign mhpmcounter_write_increment[wcnt_gidx] = ((!mhpmcounter_write_lower[wcnt_gidx] && !mhpmcounter_write_upper[wcnt_gidx]) && !mcountinhibit_q[wcnt_gidx]) && hpm_events[1];
				end
				else if ((wcnt_gidx > 2) && (wcnt_gidx < (NUM_MHPMCOUNTERS + 3))) begin : gen_mhpmcounter
					assign mhpmcounter_write_increment[wcnt_gidx] = ((!mhpmcounter_write_lower[wcnt_gidx] && !mhpmcounter_write_upper[wcnt_gidx]) && !mcountinhibit_q[wcnt_gidx]) && |(hpm_events & mhpmevent_q[(wcnt_gidx * 32) + 15-:16]);
				end
				else begin : gen_mhpmcounter_not_implemented
					assign mhpmcounter_write_increment[wcnt_gidx] = 1'b0;
				end
			end
			else begin : gen_pulp_perf_counters
				assign mhpmcounter_write_increment[wcnt_gidx] = ((!mhpmcounter_write_lower[wcnt_gidx] && !mhpmcounter_write_upper[wcnt_gidx]) && !mcountinhibit_q[wcnt_gidx]) && |(hpm_events & mhpmevent_q[(wcnt_gidx * 32) + 15-:16]);
			end
		end
	endgenerate
	genvar cnt_gidx;
	generate
		for (cnt_gidx = 0; cnt_gidx < 32; cnt_gidx = cnt_gidx + 1) begin : gen_mhpmcounter
			if ((cnt_gidx == 1) || (cnt_gidx >= (NUM_MHPMCOUNTERS + 3))) begin : gen_non_implemented
				wire [64:1] sv2v_tmp_AEE72;
				assign sv2v_tmp_AEE72 = 'b0;
				always @(*) mhpmcounter_q[cnt_gidx * 64+:64] = sv2v_tmp_AEE72;
			end
			else begin : gen_implemented
				always @(posedge clk or negedge rst_n)
					if (!rst_n)
						mhpmcounter_q[cnt_gidx * 64+:64] <= 'b0;
					else if (PULP_PERF_COUNTERS && ((cnt_gidx == 2) || (cnt_gidx == 0)))
						mhpmcounter_q[cnt_gidx * 64+:64] <= 'b0;
					else if (mhpmcounter_write_lower[cnt_gidx])
						mhpmcounter_q[(cnt_gidx * 64) + 31-:32] <= csr_wdata_int;
					else if (mhpmcounter_write_upper[cnt_gidx])
						mhpmcounter_q[(cnt_gidx * 64) + 63-:32] <= csr_wdata_int;
					else if (mhpmcounter_write_increment[cnt_gidx])
						mhpmcounter_q[cnt_gidx * 64+:64] <= mhpmcounter_increment[cnt_gidx * 64+:64];
			end
		end
	endgenerate
	genvar evt_gidx;
	generate
		for (evt_gidx = 0; evt_gidx < 32; evt_gidx = evt_gidx + 1) begin : gen_mhpmevent
			if ((evt_gidx < 3) || (evt_gidx >= (NUM_MHPMCOUNTERS + 3))) begin : gen_non_implemented
				wire [32:1] sv2v_tmp_8146C;
				assign sv2v_tmp_8146C = 'b0;
				always @(*) mhpmevent_q[evt_gidx * 32+:32] = sv2v_tmp_8146C;
			end
			else begin : gen_implemented
				begin : gen_tie_off
					wire [16:1] sv2v_tmp_97C0D;
					assign sv2v_tmp_97C0D = 'b0;
					always @(*) mhpmevent_q[(evt_gidx * 32) + 31-:16] = sv2v_tmp_97C0D;
				end
				always @(posedge clk or negedge rst_n)
					if (!rst_n)
						mhpmevent_q[(evt_gidx * 32) + 15-:16] <= 'b0;
					else
						mhpmevent_q[(evt_gidx * 32) + 15-:16] <= mhpmevent_n[(evt_gidx * 32) + 15-:16];
			end
		end
	endgenerate
	genvar en_gidx;
	generate
		for (en_gidx = 0; en_gidx < 32; en_gidx = en_gidx + 1) begin : gen_mcounteren
			if (((PULP_SECURE == 0) || (en_gidx == 1)) || (en_gidx >= (NUM_MHPMCOUNTERS + 3))) begin : gen_non_implemented
				wire [1:1] sv2v_tmp_E5963;
				assign sv2v_tmp_E5963 = 'b0;
				always @(*) mcounteren_q[en_gidx] = sv2v_tmp_E5963;
			end
			else begin : gen_implemented
				always @(posedge clk or negedge rst_n)
					if (!rst_n)
						mcounteren_q[en_gidx] <= 'b0;
					else
						mcounteren_q[en_gidx] <= mcounteren_n[en_gidx];
			end
		end
	endgenerate
	genvar inh_gidx;
	generate
		for (inh_gidx = 0; inh_gidx < 32; inh_gidx = inh_gidx + 1) begin : gen_mcountinhibit
			if ((inh_gidx == 1) || (inh_gidx >= (NUM_MHPMCOUNTERS + 3))) begin : gen_non_implemented
				wire [1:1] sv2v_tmp_2C3ED;
				assign sv2v_tmp_2C3ED = 'b0;
				always @(*) mcountinhibit_q[inh_gidx] = sv2v_tmp_2C3ED;
			end
			else begin : gen_implemented
				always @(posedge clk or negedge rst_n)
					if (!rst_n)
						mcountinhibit_q[inh_gidx] <= 'b1;
					else
						mcountinhibit_q[inh_gidx] <= mcountinhibit_n[inh_gidx];
			end
		end
	endgenerate
endmodule
