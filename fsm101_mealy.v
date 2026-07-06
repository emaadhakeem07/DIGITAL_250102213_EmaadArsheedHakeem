`timescale 1ns / 1ps

module fsm101_mealy(
        input wire x,
        input wire clk,  
        output reg z
    );
    
    parameter A = 4'b0, B = 4'b1, C = 4'b10, D = 4'b101, E = 4'b1010, F = 4'b1011;
    
    reg[4:1] current = A; 
    reg[4:1] next = A; 
    
    always @( posedge clk) begin
        case (current)
            A: begin
                if (x == 1'b1) next = B; 
                else next = A; 
            end 
            B: begin
                if (x == 1'b1) next = B; 
                else next = C;
            end
            C: begin
                if (x == 1'b1) next = D; 
                else next = A;
            end
            D: begin
                if (x == 1'b1) next = F; 
                else next = E;
            end
            E: begin
                if (x == 1'b1) next = D; 
                else next = A;
            end
            F: begin
                if (x == 1'b1) next = B; 
                else next = C;
            end
            default: next = A; 
        endcase
        current = next; 
        if (current == F || current == E || current == D) begin
            z = 1'b1;  
        end else begin
            z = 1'b0; 
        end 
    end
    
endmodule
