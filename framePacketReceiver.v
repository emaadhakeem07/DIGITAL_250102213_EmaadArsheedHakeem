`timescale 1ns / 1ps 

module framePacketReceiver(
        input stream, clk, sync_reset, 
        output reg done, parity_err, frame_err, 
        output reg[7:0] data_out
    );
    
    reg[7:0] data_out_temp_store = 8'b00000000;  
    
    integer parity = 0;  
    integer state =0; 
    
    always @(posedge clk) begin
        if (sync_reset == 1) begin
            state = 0; 
            parity = 0; 
            done = 1'b0; 
            frame_err = 1'b0; 
            parity_err = 1'b0; 
            data_out_temp_store = 8'b00000000; 
            data_out = 8'b00000000; 
        end else begin
            case (state)
                0:begin
                    parity = 0;
                    done = 1'b0; 
                    frame_err = 1'b0; 
                    parity_err = 1'b0;
                    
                    if (stream == 1'b1) state = 0;
                    else state = state+1; 
                end 
                1, 2, 3, 4, 5, 6, 7, 8: begin
                     data_out_temp_store[8-state] = stream; 
                     parity = (parity + stream)%2;
                     state = state+1; 
                end
                9: begin
                     if (parity == stream) parity_err = 1'b0; 
                     else parity_err = 1'b1;
                     state = state+1;  
                end
                10: begin
                    if (stream == 1) begin 
                        if (parity_err == 1'b0) begin
                             done = 1'b1;
                             data_out = data_out_temp_store;
                        end else begin
                            data_out = 8'b00000000;   
                        end 
                    end else begin
                        frame_err = 1'b1;  
                        data_out = 8'b00000000; 
                    end
                    parity_err = 1'b0; 
                    state = 0;
                end
            endcase
        end
    end
    
endmodule
