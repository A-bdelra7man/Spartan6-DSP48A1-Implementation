module register( clk, rst, cenable, reg_in, reg_out);

    parameter WIDTH = 18 ;
    parameter A0REG = 1 ;
    parameter RSTTYPE = 1 ;                                 // 1 FOR SYNC & 0 FOR ASYNC

    input clk, rst, cenable ;
    input [WIDTH-1:0] reg_in ;
    output reg  [WIDTH-1:0] reg_out ;
    
    reg  [WIDTH-1:0] dff ;
    
    generate                                     
           if (RSTTYPE == 1'b0) begin                        // ASYNC RS
                always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        dff <= 0 ; 
                    end 
                    else if (cenable) begin
                        dff <= reg_in ;   
                    end
                end 
            end   
            else if (RSTTYPE == 1'b1)  begin                    // SYNC RST
                   always @(posedge clk ) begin
                        if (rst) begin
                           dff <= 0 ; 
                        end 
                        else if (cenable) begin
                            dff <= reg_in ;   
                        end
                   end  
            end       
    endgenerate                                          
            always @(*)begin
                if (A0REG) begin
                    reg_out = dff ;
                end
                else begin
                    reg_out = reg_in ; 
                end
                
            end
    
endmodule


module DSP48 (
    input [17:0] A ,
    input [17:0] B ,
    input [17:0] BCIN ,
    input [17:0] D ,
    input [47:0] C ,
    input [47:0] PCIN ,
    input [7:0] opmode ,
    input CARRYIN , 
    input CLK ,
    input CEA ,
    input CEB ,
    input CEC ,
    input CED ,
    input CEM ,
    input CEP ,
    input CEOPMODE ,
    input CECARRYIN ,
    input RSTA ,
    input RSTB ,
    input RSTC ,
    input RSTD ,
    input RSTM ,
    input RSTP ,
    input RSTOPMODE ,
    input RSTCARRYIN ,

    output [17:0] BCOUT ,
    output [35:0] M ,
    output [47:0] P ,
    output [47:0] PCOUT ,
    output CARRYOUT ,
    output CARRYOUTF 
);

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


    // A pipeline 1st stage
    wire [17:0] A_stage1 ;
    register #(.WIDTH(18), .A0REG(A0REG), .RSTTYPE(RSTTYPE)) REG_A1 
    (
        .clk(CLK), .rst(RSTA), .cenable(CEA), .reg_in(A), .reg_out(A_stage1)
    );


    // B pipeline 1st stage
    wire [17:0] B_stage1 ;
    wire [17:0] B_mux ;
    assign B_mux = ((B_INPUT == 1'b1) ? B : BCIN) ;
    register #(.WIDTH(18), .A0REG(B0REG), .RSTTYPE(RSTTYPE)) REG_B1 
    (
        .clk(CLK), .rst(RSTB), .cenable(CEB), .reg_in(B_mux), .reg_out(B_stage1)
    );


    // C pipeline 1st stage
    wire [47:0] C_stage1 ;
    register #(.WIDTH(48), .A0REG(CREG), .RSTTYPE(RSTTYPE)) REG_C1 
    (
        .clk(CLK), .rst(RSTC), .cenable(CEC), .reg_in(C), .reg_out(C_stage1)
    );


    // D pipeline 1st stage
    wire [17:0] D_stage1 ;
    register #(.WIDTH(18), .A0REG(DREG), .RSTTYPE(RSTTYPE)) REG_D1
    (
        .clk(CLK), .rst(RSTD), .cenable(CED), .reg_in(D), .reg_out(D_stage1)
    );


    // OPMODE pipeline stage
    wire [7:0] opmode_stage ;
    register #(.WIDTH(8), .A0REG(OPMODEREG), .RSTTYPE(RSTTYPE)) REG_OPMODE
    (
        .clk(CLK), .rst(RSTOPMODE), .cenable(CEOPMODE), .reg_in(opmode), .reg_out(opmode_stage)
    );


    // PRE_ADD/SUB
    wire [17:0] pre_addsub_result ;
    assign pre_addsub_result = ((opmode[6] == 0) ? (D_stage1 + B_stage1) : (D_stage1 - B_stage1)) ;
    

    // A pipeline 2nd stage
    wire [17:0] A_stage2 ;
    register #(.WIDTH(18), .A0REG(A1REG), .RSTTYPE(RSTTYPE)) REG_A2 
    (
        .clk(CLK), .rst(RSTA), .cenable(CEA), .reg_in(A_stage1), .reg_out(A_stage2)
    );


    // B pipeline 2nd stage
    wire [17:0] B_stage2 ;
    wire [17:0] B_mux2 ;
    assign B_mux2 = ((opmode_stage[4] == 1'b1) ? pre_addsub_result : B_stage1 ) ;
    register #(.WIDTH(18), .A0REG(B1REG), .RSTTYPE(RSTTYPE)) REG_B2 
    (
        .clk(CLK), .rst(RSTB), .cenable(CEB), .reg_in(B_mux2), .reg_out(B_stage2)
    );


    //X MULTIPLIXER & BCOUT
    wire [35:0] mult_result ;
    assign mult_result = (A_stage2 * B_stage2);
    assign BCOUT = B_stage2 ;


    // M pipeline stage
    wire [35:0] m_stage ;
    register #(.WIDTH(36), .A0REG(MREG), .RSTTYPE(RSTTYPE)) REG_M 
    (
        .clk(CLK), .rst(RSTM), .cenable(CEM), .reg_in(mult_result), .reg_out(m_stage)
    );
    
    // M assignment
    assign M = m_stage ;


    // carryin pipeline stage
    wire cin_stage ;
    wire carryin ;
    assign carryin = (CARRYINSEL == 1'b1) ? opmode_stage[5] : CARRYIN ;
    register #(.WIDTH(1), .A0REG(CARRYINREG), .RSTTYPE(RSTTYPE)) REG_CARRYIN 
    (
        .clk(CLK), .rst(RSTCARRYIN), .cenable(CECARRYIN), .reg_in(carryin), .reg_out(cin_stage)
    );


    wire [47:0] X ;
    wire [47:0] Z ;

    assign X = (opmode[1:0] == 2'b00) ? 48'b0 :
               (opmode[1:0] == 2'b01) ? {12'b0,m_stage} :
               (opmode[1:0] == 2'b10) ? PCOUT : { D_stage1[11:0], A_stage2[17:0], B_stage2[17:0]} ;

    assign Z = (opmode[3:2] == 2'b00) ? 48'b0 :
               (opmode[3:2] == 2'b01) ? PCIN  :
               (opmode[3:2] == 2'b10) ? PCOUT : C_stage1 ;

    // post_add/sub
    wire [47:0] post_addsub_result; 
    wire cout ;
    assign {cout, post_addsub_result} = ((opmode_stage[7] == 0) ? (X + Z + cin_stage) : (Z - (X + cin_stage))) ;


    // CARRYOUT pipeline stage
    wire cout_stage ;
    register #(.WIDTH(1), .A0REG(CARRYOUTREG), .RSTTYPE(RSTTYPE)) REG_COUT
    (
        .clk(CLK), .rst(RSTCARRYIN), .cenable(CECARRYIN), .reg_in(cout), .reg_out(cout_stage)
    );

    assign CARRYOUT = cout_stage ;
    assign CARRYOUTF = cout_stage ;


    // P pipeline stage
    wire [47:0] P_stage ;
    register #(.WIDTH(48), .A0REG(PREG), .RSTTYPE(RSTTYPE)) REG_P
    (
        .clk(CLK), .rst(RSTP), .cenable(CEP), .reg_in(post_addsub_result), .reg_out(P_stage)
    );


    assign P = P_stage ;
    assign PCOUT = P ;


endmodule