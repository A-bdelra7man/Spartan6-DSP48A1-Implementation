module DSP48_tb();
    
    parameter A0REG = 0 ;
    parameter A1REG = 1 ;
    parameter B0REG = 0 ;
    parameter B1REG = 1 ;
    parameter CREG = 1 ;
    parameter DREG = 1 ;
    parameter MREG = 1 ;
    parameter PREG = 1 ;
    parameter CARRYINREG = 1 ;
    parameter CARRYOUTREG = 1 ;
    parameter OPMODEREG = 1 ;
    parameter CARRYINSEL = 1 ;  // 1 FOR OPMODE[5] & 0 FOR CARRYIN
    parameter B_INPUT = 1 ;     // 1 FOR DIRECT & 0 FOR CASCADED
    parameter RSTTYPE = 1 ;     // 1 FOR SYNC & 0 FOR ASYNC
    
    reg [17:0] A ;
    reg [17:0] B ;
    reg [17:0] BCIN ;
    reg [17:0] D ;
    reg [47:0] C ;
    reg [47:0] PCIN ;
    reg [7:0] opmode ;
    reg CARRYIN ; 
    reg CLK ;
    reg CEA ;
    reg CEB ;
    reg CEC ;
    reg CED ;
    reg CEM ;
    reg CEP ;
    reg CEOPMODE ;
    reg CECARRYIN ;
    reg RSTA ;
    reg RSTB ;
    reg RSTC ;
    reg RSTD ;
    reg RSTM ;
    reg RSTP ;
    reg RSTCARRYIN ;
    reg RSTOPMODE ;
    wire [47:0] PCOUT ; 
    wire CARRYOUTF ;

    wire [47:0] P_dut ;
    wire [17:0] BCOUT_dut ;
    wire [35:0] M_dut ;
    wire CARRYOUT_dut ;
    
    DSP48 #(.A0REG(A0REG), .B0REG(B0REG)) DUT (   
        .A(A), 
        .B(B),
        .BCIN(BCIN),
        .D(D),
        .C(C),
        .PCIN(PCIN),
        .opmode(opmode),
        .CARRYIN(CARRYIN), 
        .CLK(CLK),
        .CEA(CEA),
        .CEB(CEB),
        .CEC(CEC),
        .CED(CED),
        .CEM(CEM),
        .CEP(CEP),
        .CEOPMODE(CEOPMODE),
        .CECARRYIN(CECARRYIN),
        .RSTA(RSTA),
        .RSTB(RSTB),
        .RSTC(RSTC),
        .RSTD(RSTD),
        .RSTM(RSTM),
        .RSTP(RSTP),
        .RSTOPMODE(RSTOPMODE),
        .RSTCARRYIN(RSTCARRYIN),
        .BCOUT(BCOUT_dut),
        .M(M_dut),
        .P(P_dut),
        .PCOUT(PCOUT),
        .CARRYOUT(CARRYOUT_dut),
        .CARRYOUTF(CARRYOUTF)
    ); 
    

    initial begin
        CLK = 0;
        forever begin
            #1 CLK = ~CLK;
        end
    end


    initial begin
    // Verify Reset Operation    
        RSTA = 1 ;
        RSTB = 1 ;
        RSTC = 1 ;
        RSTD = 1 ;
        RSTM = 1 ;
        RSTP = 1 ;
        RSTCARRYIN = 1 ;
        RSTOPMODE = 1 ;
        repeat(1)begin
            @(negedge CLK);
            if (M_dut != 0 || P_dut != 0 || BCOUT_dut != 0 || CARRYOUT_dut !=0) begin
                $display ("RESET FAILED");
                $stop;
            end
            else begin
                $display ("reset passed");
            end 
        end

        //Deassert all reset signals
        RSTA = 0 ;
        RSTB = 0 ;
        RSTC = 0 ;
        RSTD = 0 ;
        RSTM = 0 ;
        RSTP = 0 ;
        RSTCARRYIN = 0 ;
        RSTOPMODE = 0 ;
        // assert all clock enable signals
        CEA = 1 ;
        CEB =1 ;
        CEC = 1 ;
        CED = 1 ;
        CEM = 1 ;
        CEP = 1 ;
        CEOPMODE = 1 ;
        CECARRYIN = 1 ;
        
        //Verify DSP Path 1
        opmode = 8'b11011101 ;
        A = 20 ;
        B = 10 ;
        C = 350 ;
        D = 25 ;
    
        BCIN = $random ;
        PCIN = $random ;
        CARRYIN = $random ;
        repeat(4) @(negedge CLK);
        if ( P_dut != 'h32) begin
            $display ("PATH_1 'P' FAILED");
            $stop;
        end
        else if (BCOUT_dut != 'hf) begin
            $display ("PATH_1 'BCOUT' FAILED");
            $stop;
        end
        else if (CARRYOUT_dut !=0) begin
            $display ("PATH_1 'CARRYOUT' FAILED");
            $stop;
        end
        else if (M_dut != 'h12c ) begin
            $display ("PATH_1 'M' FAILED");
            $stop;
        end
        else begin
            $display ("PATH_1 passed");
        end 

        // 2.3. Verify DSP Path 2
        opmode = 8'b00010000 ;
        A = 20 ;
        B = 10 ;
        C = 350 ;
        D = 25 ;
    
        BCIN = $random ;
        PCIN = $random ;
        CARRYIN = $random ;
        repeat(3) @(negedge CLK);
        if ( P_dut != 'h0) begin
            $display ("PATH_2 'P' FAILED");
            $stop;
        end
        else if (BCOUT_dut != 'h23) begin
            $display ("PATH_2 'BCOUT' FAILED");
            $stop;
        end
        else if (CARRYOUT_dut !=0) begin
            $display ("PATH_2 'CARRYOUT' FAILED");
            $stop;
        end
        else if (M_dut != 'h2bc ) begin
            $display ("PATH_2 'M' FAILED");
            $stop;
        end
        else begin
            $display ("PATH_2 passed");
        end 


        // 2.4. Verify DSP Path 3 
        opmode =  8'b00001010 ;
        A = 20 ;
        B = 10 ;
        C = 350 ;
        D = 25 ;
    
        BCIN = $random ;
        PCIN = $random ;
        CARRYIN = $random ;
        repeat(3) @(negedge CLK);
        if ( P_dut != PCOUT) begin
            $display ("PATH_3 'P' FAILED");
            $stop;
        end
        else if (BCOUT_dut != 'ha) begin
            $display ("PATH_3 'BCOUT' FAILED");
            $stop;
        end
        else if (CARRYOUT_dut != CARRYOUTF) begin
            $display ("PATH_3 'CARRYOUT' FAILED");
            $stop;
        end
        else if (M_dut != 'hc8 ) begin
            $display ("PATH_3 'M' FAILED");
            $stop;
        end
        else begin
            $display ("PATH_3 passed");
        end 

        // 2.5. Verify DSP Path 4  
        opmode =  8'b10100111 ;
        A = 5 ;
        B = 6 ;
        C = 350 ;
        D = 25 ;
        PCIN = 3000 ;
    
        BCIN = $random ;
        CARRYIN = $random ;
        repeat(3) @(negedge CLK);
        if ( P_dut != 'hfe6fffec0bb1) begin
            $display ("PATH_4 'P' FAILED");
            $stop;
        end
        else if (BCOUT_dut != 'h6) begin
            $display ("PATH_4 'BCOUT' FAILED");
            $stop;
        end
        else if (CARRYOUT_dut != 1) begin
            $display ("PATH_4 'CARRYOUT' FAILED");
            $stop;
        end
        else if (M_dut != 'h1e ) begin
            $display ("PATH_4 'M' FAILED");
            $stop;
        end
        else begin
            $display ("PATH_4 passed");
        end 
        $stop;
    end

    initial begin
        $monitor ("M_dut=%h, BCOUT_dut=%h, CARRYOUT_dut=%h, P_dut=%h", M_dut, BCOUT_dut, CARRYOUT_dut, P_dut);
    end

endmodule

