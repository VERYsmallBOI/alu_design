`timescale 1ns/1ps

module alu_testbench;
parameter width=8;
parameter cwidth=4;
    // DUT signals
    reg [width-1:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN ;
    reg [1:0]inp_valid;
    reg [cwidth-1:0] CMD;
    wire [(width*2)-1:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;
integer COUT_dut1, OFLOW_dut1, G_dut1, E_dut1, L_dut1, ERR_dut1, RES_dut1;
    // Reference model signals
    wire [(width*2)-1:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;
//clk, rst,opa, opb, cin,ce, mode, inp_valid, cmd , res, oflow, cout,g,l,e,err 
    // DUT instantiation
    alu_dut dut (
        .opa(OPA), .opb(OPB), .cin(CIN),
        .clk(CLK), .rst(RST), .cmd(CMD),
        .ce(CE), .mode(MODE),
        .cout(COUT_dut), .oflow(OFLOW_dut),
        .res(RES_dut),
        .g(G_dut), .e(E_dut), .l(L_dut),
        .err(ERR_dut),.inp_valid(inp_valid)
    );
//clk, rst, inp_valid, mode, cmd, ce, opa, opb, cin, err, res, oflow, cout, g, l, e
    // Reference model instantiation
    alu ref1 (
        .opa(OPA), .opb(OPB), .cin(CIN),
        .clk(CLK), .rst(RST), .cmd(CMD),
        .res(RES_ref),.mode(MODE),.ce(CE),
        .cout(COUT_ref), .oflow(OFLOW_ref),
        .g(G_ref), .e(E_ref), .l(L_ref),
        .err(ERR_ref),.inp_valid(inp_valid)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // Test stimulus
    initial begin
        // Initialize
        RST = 1; CE = 1; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0;
        inp_valid=2;
        @(posedge CLK);
        RST = 0;  // Release reset

        @(posedge CLK);




        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();
       test_mul();
       
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        resetandce();

        // Summary
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end

task resetandce();
        begin
            test_count=test_count+1;
            RST=1;
            @(posedge CLK);
            if((RES_dut == 0) && (COUT_dut == 0) && (OFLOW_dut == 0) && (G_dut == 0) && (E_dut == 0) && (L_dut == 0) && (ERR_dut == 0))
            begin
                $display("[PASS] %s", 
                         "reset checck");
                         //display_mismatch();
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", 
                         "reset checck");
                
                fail_count = fail_count + 1;
            end
RST=0;
@(posedge CLK);
// doing random drive 
apply_test(8'h0A, 8'h05, 4'b0000, 2'b11, "CMD_ADD_normal");
  test_count=test_count+1;
    COUT_dut1  = COUT_dut;
    OFLOW_dut1 = OFLOW_dut;
    G_dut1     = G_dut;
    E_dut1     = E_dut;
    L_dut1     = L_dut;
    ERR_dut1   = ERR_dut;
    RES_dut1   = RES_dut;
            CE=0;
            @(posedge CLK);
            if((RES_dut1 == RES_dut) && (OFLOW_dut1 == OFLOW_dut) && (G_dut1 == G_dut) && (E_dut1 == E_dut) && (L_dut1 == L_dut) && (ERR_dut1 == ERR_dut) && (COUT_dut1 == COUT_dut))
            begin
                $display("[PASS] %s", 
                         "CE checck");
                         //display_mismatch();
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", 
                         "CE checck");
                
                fail_count = fail_count + 1;
            end



        end
endtask

task test_mul();
        begin
        
// Initial reset to put DUT in known state
    RST = 1;
    @(posedge CLK);
    RST = 0;
    @(posedge CLK);

    // Default MODE = 1 at the beginning
    MODE = 1;

    // ------------------------------------------------------------------
    // 24.6a – MODE 1→0, CMD=9 → result = operation of (MODE=0, CMD=9)
    // ------------------------------------------------------------------
    applytestm(8'h03, 8'h04, 9, 2'b11, "md9chg_expM0_CMD9", 0);
    MODE = 0;
    applytestm(8'h03, 8'h04, 9, 2'b11, "md9chg_expM0_CMD9", 0);
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "md9chg_expM0_CMD9", 1);
    RST = 1; @(posedge CLK); RST = 0;  

    // ------------------------------------------------------------------
    // NORMAL
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "md10chg_expM0_CMD10", 0);
    applytestm(8'h03, 8'h04, 10, 2'b11, "md10chg_expM0_CMD10", 0);
    applytestm(8'h03, 8'h04, 10, 2'b11, "md10chg_expM0_CMD10", 1);
    RST = 1; @(posedge CLK); RST = 0; 


    // ------------------------------------------------------------------
    // 24.6b – MODE 1→0, CMD=10 → result = operation of (MODE=0, CMD=10)
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "md10chg_expM0_CMD10", 0);
    MODE = 0;
    applytestm(8'h03, 8'h04, 10, 2'b11, "md10chg_expM0_CMD10", 0);
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "md10chg_expM0_CMD10", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7a – OPA changed mid‑sequence, CMD=9 → (3+1)*(4+1)=20
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "opa9chg_exp20", 0);
    applytestm(8'h0A, 8'h04, 9, 2'b11, "opa9chg_exp20", 0);
    applytestm(8'h0A, 8'h04, 9, 2'b11, "opa9chg_exp20", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7b – OPB changed mid‑sequence, CMD=9 → 20
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "opb9chg_exp20", 0);
    applytestm(8'h03, 8'h0A, 9, 2'b11, "opb9chg_exp20", 0);
    applytestm(8'h03, 8'h0A, 9, 2'b11, "opb9chg_exp20", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7c – OPA changed, CMD=10 → ((3<<1)=6)*4=24
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "opa10chg_exp24", 0);
    applytestm(8'h0A, 8'h04, 10, 2'b11, "opa10chg_exp24", 0);
    applytestm(8'h0A, 8'h04, 10, 2'b11, "opa10chg_exp24", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7d – OPB changed, CMD=10 → 24
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "opb10chg_exp24", 0);
    applytestm(8'h03, 8'h0A, 10, 2'b11, "opb10chg_exp24", 0);
    applytestm(8'h03, 8'h0A, 10, 2'b11, "opb10chg_exp24", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7e – Both OPA & OPB changed, CMD=9 → 20
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "both9chg_exp20", 0);
    applytestm(8'h0A, 8'h0B, 9, 2'b11, "both9chg_exp20", 0);
    applytestm(8'h0A, 8'h0B, 9, 2'b11, "both9chg_exp20", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7f – Both changed, CMD=10 → 24
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "both10chg_exp24", 0);
    applytestm(8'h0A, 8'h0B, 10, 2'b11, "both10chg_exp24", 0);
    applytestm(8'h0A, 8'h0B, 10, 2'b11, "both10chg_exp24", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7g – MODE 1→0 & OPA change, CMD=9 → MODE dominates: (MODE=0, CMD=9)
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "mdopa9_expM0_CMD9", 0);
    MODE = 0;
    applytestm(8'h0A, 8'h04, 9, 2'b11, "mdopa9_expM0_CMD9", 0);
    MODE = 1;
    applytestm(8'h0A, 8'h04, 9, 2'b11, "mdopa9_expM0_CMD9", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7h – MODE 1→0 & OPB change, CMD=10 → MODE dominates: (MODE=0, CMD=10)
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "mdopb10_expM0_CMD10", 0);
    MODE = 0;
    applytestm(8'h03, 8'h0A, 10, 2'b11, "mdopb10_expM0_CMD10", 0);
    MODE = 1;
    applytestm(8'h03, 8'h0A, 10, 2'b11, "mdopb10_expM0_CMD10", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7i – Sequential operand changes, CMD=9 → result = 20 (sample time)
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "seq9_exp20", 0);
    applytestm(8'h0A, 8'h04, 9, 2'b11, "seq9_exp20", 0);
    applytestm(8'h0A, 8'h0B, 9, 2'b11, "seq9_exp20", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.7j – Sequential operand changes, CMD=10 → result = 24 (sample time)
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "seq10_exp24", 0);
    applytestm(8'h0A, 8'h04, 10, 2'b11, "seq10_exp24", 0);
    applytestm(8'h0A, 8'h0B, 10, 2'b11, "seq10_exp24", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.8a – CMD 9→10 mid‑sequence → use first‑cycle operands with CMD=9 → 20
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "cmd9to10_exp20", 0);
    applytestm(8'hAA, 8'hBB, 10, 2'b11, "cmd9to10_exp20", 0);
    applytestm(8'hAA, 8'hBB, 10, 2'b11, "cmd9to10_exp20", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.8b – CMD 10→9 mid‑sequence → use first‑cycle operands with CMD=10 → 24
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 10, 2'b11, "cmd10to9_exp24", 0);
    applytestm(8'hAA, 8'hBB, 9, 2'b11, "cmd10to9_exp24", 0);
    applytestm(8'hAA, 8'hBB, 9, 2'b11, "cmd10to9_exp24", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.9a – CMD changes 9→5 (non‑MUL) → result = operation of CMD=5
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "cmd9to5_expCMD5", 0);
    applytestm(8'h03, 8'h04, 5, 2'b11, "cmd9to5_expCMD5", 0);
    applytestm(8'h03, 8'h04, 5, 2'b11, "cmd9to5_expCMD5", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.9b – MODE 1→0 and CMD 9→5 → MODE wins: (MODE=0, CMD=5)
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h03, 8'h04, 9, 2'b11, "mdcmd9to5_expM0_CMD5", 0);
    MODE = 0;
    applytestm(8'h03, 8'h04, 5, 2'b11, "mdcmd9to5_expM0_CMD5", 0);
    MODE = 1;
    applytestm(8'h03, 8'h04, 5, 2'b11, "mdcmd9to5_expM0_CMD5", 1);
    RST = 1; @(posedge CLK); RST = 0; 

    // ------------------------------------------------------------------
    // 24.10 – Only one input valid (inp_valid=2'b10) → ERR=1
    // ------------------------------------------------------------------
    MODE = 1;
    applytestm(8'h12, 8'h34, 9, 2'b10, "inval10_expERR1", 0);
    applytestm(8'h12, 8'h34, 9, 2'b10, "inval10_expERR1", 0);
    applytestm(8'h12, 8'h34, 9, 2'b10, "inval10_expERR1", 1);
    RST = 1; @(posedge CLK); RST = 0; 


        end
endtask

    // Test arithmetic operations
    task test_arithmetic();
        begin
            apply_test(8'h0A, 8'h05, 4'b0000, 2'b11, "CMD_ADD_normal");
apply_test(8'h00, 8'h00, 4'b0000, 2'b11, "CMD_ADD_zero_plus_zero");
apply_test(8'hFF, 8'hFF, 4'b0000, 2'b11, "CMD_ADD_max_plus_max");
apply_test(8'h00, 8'hFF, 4'b0000, 2'b11, "CMD_ADD_zero_plus_max");
apply_test(8'h0A, 8'h05, 4'b0001, 2'b11, "CMD_SUB_normal");
apply_test(8'h00, 8'h00, 4'b0001, 2'b11, "CMD_SUB_zero_minus_zero");
apply_test(8'h00, 8'h01, 4'b0001, 2'b11, "CMD_SUB_borrow");
apply_test(8'h55, 8'hAA, 4'b0001, 2'b11, "CMD_SUB_random");  // random replaced with 0x55,0xAA
apply_test(8'h05, 8'h00, 4'b0100, 2'b11, "CMD_INC_A_normal");  // CMD=4, MODE=1
apply_test(8'h00, 8'h00, 4'b0100, 2'b11, "CMD_INC_A_min");
apply_test(8'hFF, 8'h00, 4'b0100, 2'b11, "CMD_INC_A_max");
apply_test(8'h05, 8'h00, 4'b0101, 2'b11, "CMD_DEC_A_normal");  // CMD=5
apply_test(8'h00, 8'h00, 4'b0101, 2'b11, "CMD_DEC_A_min");
apply_test(8'hFF, 8'h00, 4'b0101, 2'b11, "CMD_DEC_A_max");
apply_test(8'h00, 8'h05, 4'b0110, 2'b11, "CMD_INC_B_normal");  // CMD=6
apply_test(8'h00, 8'h00, 4'b0110, 2'b11, "CMD_INC_B_min");
apply_test(8'h00, 8'hFF, 4'b0110, 2'b11, "CMD_INC_B_max");
apply_test(8'h00, 8'h05, 4'b0111, 2'b11, "CMD_DEC_B_normal");  // CMD=7
apply_test(8'h00, 8'h00, 4'b0111, 2'b11, "CMD_DEC_B_min");
apply_test(8'h00, 8'hFF, 4'b0111, 2'b11, "CMD_DEC_B_max");
apply_test(8'h55, 8'h55, 4'b1000, 2'b11, "check_equality");  // CMD=8 (CMP)
apply_test(8'hAA, 8'h55, 4'b1000, 2'b11, "check_OPA_greater");
apply_test(8'h55, 8'hAA, 4'b1000, 2'b11, "check_OPA_smaller");
apply_test(8'h55, 8'hAA, 4'b1000, 2'b01, "cmp_only_one_inp_valid");  // only A valid
apply_test(8'h05, 8'h00, 4'b0100, 2'b01, "inc_dec_only_one_inp_valid_A");  // INC_A with only A valid
apply_test(8'h00, 8'h05, 4'b0110, 2'b10, "inc_dec_only_one_inp_valid_B");  // INC_B with only B valid
apply_test(8'h0A, 8'h05, 4'b0010, 2'b11, "CMD_ADD_normal_cin0");
apply_test(8'h00, 8'h00, 4'b0010, 2'b11, "CMD_ADD_zero_plus_zero_cin0");
apply_test(8'hFF, 8'hFF, 4'b0010, 2'b11, "CMD_ADD_max_plus_max_cin0");
apply_test(8'h00, 8'hFF, 4'b0010, 2'b11, "CMD_ADD_zero_plus_max_cin0");
apply_test(8'h0A, 8'h05, 4'b0001, 2'b11, "CMD_SUB_normal_cin0");
apply_test(8'h00, 8'h00, 4'b0001, 2'b11, "CMD_SUB_zero_minus_zero_cin0");
apply_test(8'hFF, 8'hFF, 4'b0001, 2'b11, "CMD_SUB_max_minus_max_cin0");
apply_test(8'h00, 8'hFF, 4'b0001, 2'b11, "CMD_SUB_zero_minus_max_cin0");
apply_test(8'h1F, 8'h2F, 4'b1011, 2'b11, "signed_add_both_positive_no_oflow");
apply_test(8'hC0, 8'hC0, 4'b1011, 2'b11, "signed_add_both_negative_no_oflow");
apply_test(8'h20, 8'hE0, 4'b1011, 2'b11, "signed_add_diff_sign");
apply_test(8'h00, 8'h00, 4'b1011, 2'b11, "signed_add_zero_plus_zero");
apply_test(8'h7F, 8'h7F, 4'b1011, 2'b11, "signed_add_max_plus_max");
apply_test(8'h80, 8'h80, 4'b1011, 2'b11, "signed_add_min_plus_min");
apply_test(8'h7F, 8'h00, 4'b1011, 2'b11, "signed_add_max_pos_plus_zero");
apply_test(8'h50, 8'h30, 4'b1100, 2'b11, "signed_sub_same_sign_no_oflow");
apply_test(8'h7F, 8'h80, 4'b1100, 2'b11, "signed_sub_diff_sign_oflow");
apply_test(8'h00, 8'h20, 4'b1100, 2'b11, "signed_sub_zero_minus_positive");
apply_test(8'h50, 8'h30, 4'b1100, 2'b11, "signed_sub_positive_minus_positive");
apply_test(8'hF0, 8'h80, 4'b1100, 2'b11, "signed_sub_neg_minus_neg_larger");
apply_test(8'h80, 8'hF0, 4'b1100, 2'b11, "signed_sub_neg_minus_neg_smaller");
apply_test(8'h7F, 8'h80, 4'b1100, 2'b11, "signed_sub_positive_minus_negative");
apply_test(8'h80, 8'h01, 4'b1100, 2'b11, "signed_sub_negative_minus_positive");
apply_test(8'h3C, 8'hD0, 4'b1100, 2'b11, "signed_sub_random");
CIN=1;
apply_test(8'h0A, 8'h05, 4'b0010, 2'b11, "CMD_ADD_CIN_basic");
apply_test(8'hFF, 8'hFF, 4'b0010, 2'b11, "CMD_ADD_CIN_max_carry");
apply_test(8'h0A, 8'h05, 4'b0010, 2'b11, "CMD_ADD_normal_cin1");
apply_test(8'h00, 8'h00, 4'b0010, 2'b11, "CMD_ADD_zero_plus_zero_cin1");
apply_test(8'hFF, 8'hFF, 4'b0010, 2'b11, "CMD_ADD_max_plus_max_cin1");
apply_test(8'h00, 8'hFF, 4'b0010, 2'b11, "CMD_ADD_zero_plus_max_cin1");
apply_test(8'h0A, 8'h05, 4'b0001, 2'b11, "CMD_SUB_BIN_basic");
apply_test(8'h00, 8'hFF, 4'b0001, 2'b11, "CMD_SUB_BIN_borrow_underflow");
apply_test(8'h0A, 8'h05, 4'b0001, 2'b11, "CMD_SUB_normal_cin1");
apply_test(8'h00, 8'h00, 4'b0001, 2'b11, "CMD_SUB_zero_minus_zero_cin1");
apply_test(8'hFF, 8'hFF, 4'b0001, 2'b11, "CMD_SUB_max_minus_max_cin1");
apply_test(8'h00, 8'hFF, 4'b0001, 2'b11, "CMD_SUB_zero_minus_max_cin1");

        end
    endtask

    // Test logical operations
    task test_logical();
        begin
apply_test(8'hF0, 8'hA5, 4'b0000, 2'b11, "logical_AND");
apply_test(8'hF0, 8'hA5, 4'b0001, 2'b11, "logical_NAND");
apply_test(8'hF0, 8'hA5, 4'b0010, 2'b11, "logical_OR");
apply_test(8'hF0, 8'hA5, 4'b0011, 2'b11, "logical_NOR");
apply_test(8'hF0, 8'hA5, 4'b0100, 2'b11, "logical_XOR");
apply_test(8'hF0, 8'hA5, 4'b0101, 2'b11, "logical_XNOR");
apply_test(8'hF0, 8'h00, 4'b0110, 2'b00, "logical_NOT_A_inv0");
apply_test(8'hF0, 8'h00, 4'b0110, 2'b11, "logical_NOT_A_inv11");
apply_test(8'hF0, 8'h00, 4'b0110, 2'b01, "logical_NOT_A_inv01");
apply_test(8'h00, 8'hA5, 4'b0111, 2'b00, "logical_NOT_B_inv0");
apply_test(8'h00, 8'hA5, 4'b0111, 2'b11, "logical_NOT_B_inv11");
apply_test(8'h00, 8'hA5, 4'b0111, 2'b10, "logical_NOT_B_inv10");
apply_test(8'h00, 8'h00, 4'b1000, 2'b00, "SHR1_A_inv00_0");
apply_test(8'h00, 8'h00, 4'b1000, 2'b01, "SHR1_A_inv01_0");
apply_test(8'h00, 8'h00, 4'b1000, 2'b11, "SHR1_A_inv11_0");
apply_test(8'hFF, 8'h00, 4'b1000, 2'b11, "SHR1_A_inv11_255");
apply_test(8'h80, 8'h00, 4'b1000, 2'b11, "SHR1_A_inv11_128");
apply_test(8'h01, 8'h00, 4'b1000, 2'b11, "SHR1_A_inv11_1");
apply_test(8'h00, 8'h00, 4'b1001, 2'b00, "SHL1_A_inv00_0");
apply_test(8'h00, 8'h00, 4'b1001, 2'b01, "SHL1_A_inv01_0");
apply_test(8'h00, 8'h00, 4'b1001, 2'b11, "SHL1_A_inv11_0");
apply_test(8'hFF, 8'h00, 4'b1001, 2'b11, "SHL1_A_inv11_255");
apply_test(8'h80, 8'h00, 4'b1001, 2'b11, "SHL1_A_inv11_128");
apply_test(8'h01, 8'h00, 4'b1001, 2'b11, "SHL1_A_inv11_1");
apply_test(8'h00, 8'h00, 4'b1010, 2'b00, "SHR1_B_inv00_0");
apply_test(8'h00, 8'h00, 4'b1010, 2'b10, "SHR1_B_inv10_0");
apply_test(8'h00, 8'h00, 4'b1010, 2'b11, "SHR1_B_inv11_0");
apply_test(8'h00, 8'hFF, 4'b1010, 2'b11, "SHR1_B_inv11_255");
apply_test(8'h00, 8'h80, 4'b1010, 2'b11, "SHR1_B_inv11_128");
apply_test(8'h00, 8'h01, 4'b1010, 2'b11, "SHR1_B_inv11_1");
apply_test(8'h00, 8'h00, 4'b1011, 2'b00, "SHL1_B_inv00_0");
apply_test(8'h00, 8'h00, 4'b1011, 2'b10, "SHL1_B_inv10_0");
apply_test(8'h00, 8'h00, 4'b1011, 2'b11, "SHL1_B_inv11_0");
apply_test(8'h00, 8'hFF, 4'b1011, 2'b11, "SHL1_B_inv11_255");
apply_test(8'h00, 8'h80, 4'b1011, 2'b11, "SHL1_B_inv11_128");
apply_test(8'h00, 8'h01, 4'b1011, 2'b11, "SHL1_B_inv11_1");
apply_test(8'hB4, 8'h01, 4'b1100, 2'b11, "ROL_by_1_bit");
apply_test(8'hB4, 8'h03, 4'b1100, 2'b11, "ROL_by_N_bits");
apply_test(8'hB4, 8'h00, 4'b1100, 2'b11, "ROL_by_0_bits");
apply_test(8'hB4, 8'h08, 4'b1100, 2'b11, "ROL_by_8_bits");
apply_test(8'hF0, 8'hA5, 4'b1100, 2'b01, "ROL_inp_valid_A_only");
apply_test(8'hF0, 8'hA5, 4'b1100, 2'b00, "ROL_inp_valid_none");
apply_test(8'hB4, 8'h01, 4'b1101, 2'b11, "ROR_by_1_bit");
apply_test(8'hB4, 8'h03, 4'b1101, 2'b11, "ROR_by_N_bits");
apply_test(8'hB4, 8'h00, 4'b1101, 2'b11, "ROR_by_0_bits");
apply_test(8'hB4, 8'h08, 4'b1101, 2'b11, "ROR_by_8_bits");
apply_test(8'hF0, 8'hA5, 4'b1101, 2'b01, "ROR_inp_valid_A_only");
apply_test(8'hF0, 8'hA5, 4'b1101, 2'b00, "ROR_inp_valid_none");
        end
    endtask

//apply tesst dor muliplcation
 
    // Apply test and check
    task applytestm(
        input [7:0] a,b,
        input [3:0] cmd,
        input [1:0] inp_valid1,
        input [80*8:1] test_name,
        input check
    );
        begin
            
            OPA = a;
            OPB = b;
            CMD = cmd;
            inp_valid=inp_valid1;
            @(posedge CLK);
            if(check)
            begin
                    @(posedge CLK);
            test_count = test_count + 1;
            
            if (compare_outputs()) begin
                $display("[PASS] %s: OPA=0x%d OPB=0x%d CMD=0x%d", 
                         test_name, a, b, cmd);
                         //display_mismatch();
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: OPA=0x%d OPB=0x%d CMD=0x%d", 
                         test_name, a, b, cmd);
                display_mismatch();
                fail_count = fail_count + 1;
            end
            end
        end
    endtask


    // Apply test and check
    task apply_test(
        input [7:0] a, b,
        input [3:0] cmd,
        input [1:0] inp_valid1,
        input [80*8:1] test_name
    );
        begin
            @(posedge CLK);
            OPA = a;
            OPB = b;
            CMD = cmd;
            inp_valid=inp_valid1;
            
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            test_count = test_count + 1;
            
            if (compare_outputs()) begin
                $display("[PASS] %s: OPA=0x%d OPB=0x%d CMD=0x%d", 
                         test_name, a, b, cmd);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: OPA=0x%d OPB=0x%d CMD=0x%d", 
                         test_name, a, b, cmd);
                display_mismatch();
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Compare DUT vs Reference
    function compare_outputs();
        begin
            compare_outputs = 1;
            if(ERR_ref==1)
            begin
                if(!compare_bit(ERR_dut, ERR_ref))
                compare_outputs = 0;
            end               
             else
             begin


            if (RES_dut !== RES_ref)
                    compare_outputs = 0;
            
            
            // Compare flags (handle Z values)
            if (!compare_bit(COUT_dut, COUT_ref)) compare_outputs = 0;
            if (!compare_bit(OFLOW_dut, OFLOW_ref)) compare_outputs = 0;
            if (!compare_bit(G_dut, G_ref)) compare_outputs = 0;
            if (!compare_bit(E_dut, E_ref)) compare_outputs = 0;
            if (!compare_bit(L_dut, L_ref)) compare_outputs = 0;
             end
        end
    endfunction

    // Compare single bit (handle Z)
    function compare_bit(input dut, ref1);
        begin
            if (dut === ref1)
                compare_bit = 1;
            else
                compare_bit = 0;
        end
    endfunction

    // Display mismatch details
    task display_mismatch();
        begin
            $display("  DUT: RES=0x%d COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
            $display("  REF: RES=0x%d COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask

    // Waveform dump
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_testbench);
    end

endmodule