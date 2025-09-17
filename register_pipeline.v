module register( clk, rst, cenable, reg_in, reg_out);

    parameter WIDTH = 18 ;
    parameter A0REG = 1 ;
    parameter RSTTYPE = 1 ;                                 // 1 FOR SYNC & 0 FOR ASYNC

    input clk, rst, cenable ;
    input [WIDTH-1:0] reg_in ;

    output reg  [WIDTH-1:0] reg_out ;
    
    generate
        if (A0REG) begin                                     // registered ASSIGNMENT
           if (RSTTYPE == 1'b0) begin                        // ASYNC RS
                always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        reg_out <= 0 ; 
                    end 
                    else if (cenable) begin
                        reg_out <= reg_in ;   
                    end
                end 
            end   
            else if (RSTTYPE == 1'b1)                        // SYNC RST
                   always @(posedge clk ) begin
                        if (rst) begin
                           reg_out <= 0 ; 
                        end 
                        else if (cenable) begin
                            reg_out <= reg_in ;   
                        end
                   end  
        end 
        else begin                                          // DIRECT ASSIGNMENT
            always @(*)begin
                reg_out = reg_in ;
            end
        end
    endgenerate

endmodule