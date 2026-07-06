`timescale 1ns / 1ps

module bonusCommandReceiver( 
        input stream, clk, sync_reset, 
        output reg done , parity_err, frame_err , 
        output reg[7:0] result
    );
    
    integer state = 0;
    integer parity = 0;
    reg[7:0] temp_data_store = 8'b00000000; 
    reg[1:0] current_command = 2'b00; 
    
    reg[7:0] A = 8'b00000000; 
    reg[7:0] B = 8'b00000000;
    
    integer i = 0;  
    
    always @(posedge clk) begin
        if (sync_reset == 1'b1) begin
            state = 0; 
            parity = 0;
            result = 8'b00000000;
            current_command = 2'b00; 
            A = 8'b00000000;  
            B = 8'b00000000;
            parity_err = 1'b0; 
            frame_err = 1'b0;
            temp_data_store = 8'b00000000;  
            done = 1'b0; 
        end else begin 
            case (state)
                0: begin
                    parity = 0;  
                    done = 1'b0; 
                    parity_err = 1'b0; 
                    temp_data_store = 8'b00000000; 
                    frame_err  = 1'b0;
                    if (stream == 1) state = 0; 
                    else state = state+1;      
                end 
                1, 2: begin
                    current_command[2-state] = stream;  
                    state = state + 1;
                end
                3, 4, 5, 6, 7, 8, 9, 10: begin
                    temp_data_store[10-state] = stream; 
                    parity = (parity + stream)%2;
                    state = state +1;   
                end
                11: begin
                    if (parity == stream) parity_err = 1'b0;  
                    else parity_err = 1'b1;  
                    state = state+1; 
                end
                12 : begin
                    if (stream == 1'b1) begin
                         if (parity_err == 1'b0) begin 
                            done = 1'b1; 
                            case (current_command)
                                2'b00: begin
                                    A = temp_data_store;  
                                    result = A;  
                                end 
                                2'b01: begin
                                    B = temp_data_store; 
                                    result = B;  
                                end
                                2'b10: begin
                                    result = A+B;  
                                end
                                2'b11:begin
                                    A = 8'b00000000; 
                                    B = 8'b00000000; 
                                    result = 8'b00000000;  
                                end
                            endcase
                         end else begin
                             result = 8'b00000000; 
                         end
                    end else begin
                         frame_err = 1'b1;
                         result = 8'b00000000; 
                    end 
                    parity_err = 1'b0; 
                    state = 0; 
                end
            endcase 
        end 
    end
    
    
endmodule
