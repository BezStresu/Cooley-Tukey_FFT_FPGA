// cplx_mul.v
// Complex multiply: (ar + j*ai) * (br + j*bi)
// a inputs width AW, b inputs width BW (twiddle width). Output width = AW (truncated)
// Uses arithmetic shifts; twiddle uses Q1.15 fractional format.
`timescale 1ns/1ps
module cplx_mul
#(
    parameter AW = 32, // data width for 'a' operand (internal)
    parameter BW = 16  // twiddle width (Q1.15)
)
(
    input  signed [AW-1:0] ar,
    input  signed [AW-1:0] ai,
    input  signed [BW-1:0] br,
    input  signed [BW-1:0] bi,
    output signed [AW-1:0] rr,
    output signed [AW-1:0] ri
);
    // products are AW + BW bits
    wire signed [AW+BW-1:0] p0 = ar * br;
    wire signed [AW+BW-1:0] p1 = ai * bi;
    wire signed [AW+BW-1:0] p2 = ar * bi;
    wire signed [AW+BW-1:0] p3 = ai * br;

    // real = p0 - p1 ; imag = p2 + p3
    wire signed [AW+BW-1:0] real_tmp = p0 - p1;
    wire signed [AW+BW-1:0] imag_tmp = p2 + p3;

    // shift right by (BW-1) to account for Q1.15 fractional scaling
    // (BW-1) = 15 for 16-bit twiddles
    localparam integer SHIFT = BW - 1;
    wire signed [AW+BW-1:0] real_shift = real_tmp >>> SHIFT;
    wire signed [AW+BW-1:0] imag_shift = imag_tmp >>> SHIFT;

    // truncate to AW bits (AW chosen wide enough to avoid overflow)
    assign rr = real_shift[AW-1:0];
    assign ri = imag_shift[AW-1:0];
endmodule
