// butterfly.v
// One radix-2 butterfly: upper = a + (b * W), lower = a - (b * W)
// a inputs are AW bits, b inputs are AW bits (data) and twiddle is BW bits (Q1.15)
`timescale 1ns/1ps
module butterfly
#(
    parameter AW = 32,
    parameter TW = 16
)
(
    input  signed [AW-1:0] a_re,
    input  signed [AW-1:0] a_im,
    input  signed [AW-1:0] b_re,
    input  signed [AW-1:0] b_im,
    input  [2:0] tw_addr, // selects W8^tw_addr
    output signed [AW-1:0] up_re,
    output signed [AW-1:0] up_im,
    output signed [AW-1:0] low_re,
    output signed [AW-1:0] low_im
);
    wire signed [TW-1:0] tw_re;
    wire signed [TW-1:0] tw_im;
    twiddle_rom #(.TW(TW)) rom (.addr(tw_addr), .re(tw_re), .im(tw_im));

    // multiply b by twiddle: b * W
    wire signed [AW-1:0] b_tw_re;
    wire signed [AW-1:0] b_tw_im;
    cplx_mul #(.AW(AW), .BW(TW)) cmul (
        .ar(b_re), .ai(b_im),
        .br(tw_re), .bi(tw_im),
        .rr(b_tw_re), .ri(b_tw_im)
    );

    // sums and diffs
    assign up_re  = a_re + b_tw_re;
    assign up_im  = a_im + b_tw_im;
    assign low_re = a_re - b_tw_re;
    assign low_im = a_im - b_tw_im;
endmodule
