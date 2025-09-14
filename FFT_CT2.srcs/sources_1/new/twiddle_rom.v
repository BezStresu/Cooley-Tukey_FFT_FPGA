// twiddle_rom.v
// ROM for W8^k twiddle factors in Q1.15 (signed 16-bit)
`timescale 1ns/1ps
module twiddle_rom #(parameter TW = 16) (
    input  [2:0] addr,
    output reg signed [TW-1:0] re,
    output reg signed [TW-1:0] im
);
    always @(*) begin
        case (addr)
            3'd0: begin re = 16'h7fff; im = 16'h0000; end //  1.0000 + j0
            3'd1: begin re = 16'h5a82; im = 16'ha57e; end //  0.7071 - j0.7071
            3'd2: begin re = 16'h0000; im = 16'h8001; end //  0      - j1.0000  (-32767)
            3'd3: begin re = 16'ha57e; im = 16'ha57e; end // -0.7071 - j0.7071
            3'd4: begin re = 16'h8001; im = 16'h0000; end // -1.0000 + j0
            3'd5: begin re = 16'ha57e; im = 16'h5a82; end // -0.7071 + j0.7071
            3'd6: begin re = 16'h0000; im = 16'h7fff; end //  0      + j1.0000
            3'd7: begin re = 16'h5a82; im = 16'h5a82; end //  0.7071 + j0.7071
            default: begin re = 16'h0000; im = 16'h0000; end
        endcase
    end
endmodule
