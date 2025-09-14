// fft8_top.v
// Structural FFT-8 (combinational), inputs are Q1.15 (16-bit signed).
`timescale 1ns/1ps
module fft8_top
#(
    parameter INW = 16,  // input width (Q1.15)
    parameter IW  = 32,  // internal width (to avoid overflow)
    parameter TW  = 16   // twiddle width (Q1.15)
)
(
    input  signed [INW-1:0] in_re0, in_re1, in_re2, in_re3, in_re4, in_re5, in_re6, in_re7,
    input  signed [INW-1:0] in_im0, in_im1, in_im2, in_im3, in_im4, in_im5, in_im6, in_im7,
    output signed [IW-1:0] out_re0, out_re1, out_re2, out_re3, out_re4, out_re5, out_re6, out_re7,
    output signed [IW-1:0] out_im0, out_im1, out_im2, out_im3, out_im4, out_im5, out_im6, out_im7
);

    // 1) bit reversal (outputs still INW width) -> sign-extend to IW
    wire signed [INW-1:0] br_re [0:7];
    wire signed [INW-1:0] br_im [0:7];

    bitrev #(.AW(INW)) br (
        .in_re0(in_re0), .in_re1(in_re1), .in_re2(in_re2), .in_re3(in_re3), .in_re4(in_re4), .in_re5(in_re5), .in_re6(in_re6), .in_re7(in_re7),
        .in_im0(in_im0), .in_im1(in_im1), .in_im2(in_im2), .in_im3(in_im3), .in_im4(in_im4), .in_im5(in_im5), .in_im6(in_im6), .in_im7(in_im7),
        .out_re0(br_re[0]), .out_re1(br_re[1]), .out_re2(br_re[2]), .out_re3(br_re[3]), .out_re4(br_re[4]), .out_re5(br_re[5]), .out_re6(br_re[6]), .out_re7(br_re[7]),
        .out_im0(br_im[0]), .out_im1(br_im[1]), .out_im2(br_im[2]), .out_im3(br_im[3]), .out_im4(br_im[4]), .out_im5(br_im[5]), .out_im6(br_im[6]), .out_im7(br_im[7])
    );

    // sign-extend to internal width IW
    wire signed [IW-1:0] x_re [0:7];
    wire signed [IW-1:0] x_im [0:7];
    genvar i;
    generate
        for (i=0; i<8; i=i+1) begin : EXT
            assign x_re[i] = {{(IW-INW){br_re[i][INW-1]}}, br_re[i]}; // sign-extend
            assign x_im[i] = {{(IW-INW){br_im[i][INW-1]}}, br_im[i]};
        end
    endgenerate

    // STAGE 1 (k=2): butterflies on pairs (0,1),(2,3),(4,5),(6,7) with twiddle = W8^0 (addr 0)
    wire signed [IW-1:0] s1_re [0:7];
    wire signed [IW-1:0] s1_im [0:7];
    generate
        for (i=0; i<4; i=i+1) begin : S1
            butterfly #(.AW(IW), .TW(TW)) b (
                .a_re(x_re[2*i]), .a_im(x_im[2*i]),
                .b_re(x_re[2*i+1]), .b_im(x_im[2*i+1]),
                .tw_addr(3'd0),
                .up_re(s1_re[2*i]), .up_im(s1_im[2*i]),
                .low_re(s1_re[2*i+1]), .low_im(s1_im[2*i+1])
            );
        end
    endgenerate

    // STAGE 2 (k=4): butterflies on (0,2) tw= W8^0; (1,3) tw= W8^2 (-j); similarly for (4,6),(5,7)
    wire signed [IW-1:0] s2_re [0:7];
    wire signed [IW-1:0] s2_im [0:7];
    // pair (0,2) -> outputs 0 and 2 (tw addr 0)
    butterfly #(.AW(IW), .TW(TW)) b20 (
        .a_re(s1_re[0]), .a_im(s1_im[0]),
        .b_re(s1_re[2]), .b_im(s1_im[2]),
        .tw_addr(3'd0),
        .up_re(s2_re[0]), .up_im(s2_im[0]),
        .low_re(s2_re[2]), .low_im(s2_im[2])
    );
    // pair (1,3) -> outputs 1 and 3 (tw addr 2)
    butterfly #(.AW(IW), .TW(TW)) b21 (
        .a_re(s1_re[1]), .a_im(s1_im[1]),
        .b_re(s1_re[3]), .b_im(s1_im[3]),
        .tw_addr(3'd2),
        .up_re(s2_re[1]), .up_im(s2_im[1]),
        .low_re(s2_re[3]), .low_im(s2_im[3])
    );
    // pair (4,6)
    butterfly #(.AW(IW), .TW(TW)) b22 (
        .a_re(s1_re[4]), .a_im(s1_im[4]),
        .b_re(s1_re[6]), .b_im(s1_im[6]),
        .tw_addr(3'd0),
        .up_re(s2_re[4]), .up_im(s2_im[4]),
        .low_re(s2_re[6]), .low_im(s2_im[6])
    );
    // pair (5,7)
    butterfly #(.AW(IW), .TW(TW)) b23 (
        .a_re(s1_re[5]), .a_im(s1_im[5]),
        .b_re(s1_re[7]), .b_im(s1_im[7]),
        .tw_addr(3'd2),
        .up_re(s2_re[5]), .up_im(s2_im[5]),
        .low_re(s2_re[7]), .low_im(s2_im[7])
    );

    // STAGE 3 (k=8): butterflies on (0,4) tw=W8^0; (1,5) tw=W8^1; (2,6) tw=W8^2; (3,7) tw=W8^3
    butterfly #(.AW(IW), .TW(TW)) b30 (
        .a_re(s2_re[0]), .a_im(s2_im[0]),
        .b_re(s2_re[4]), .b_im(s2_im[4]),
        .tw_addr(3'd0),
        .up_re(out_re0), .up_im(out_im0),
        .low_re(out_re4), .low_im(out_im4)
    );
    butterfly #(.AW(IW), .TW(TW)) b31 (
        .a_re(s2_re[1]), .a_im(s2_im[1]),
        .b_re(s2_re[5]), .b_im(s2_im[5]),
        .tw_addr(3'd1),
        .up_re(out_re1), .up_im(out_im1),
        .low_re(out_re5), .low_im(out_im5)
    );
    butterfly #(.AW(IW), .TW(TW)) b32 (
        .a_re(s2_re[2]), .a_im(s2_im[2]),
        .b_re(s2_re[6]), .b_im(s2_im[6]),
        .tw_addr(3'd2),
        .up_re(out_re2), .up_im(out_im2),
        .low_re(out_re6), .low_im(out_im6)
    );
    butterfly #(.AW(IW), .TW(TW)) b33 (
        .a_re(s2_re[3]), .a_im(s2_im[3]),
        .b_re(s2_re[7]), .b_im(s2_im[7]),
        .tw_addr(3'd3),
        .up_re(out_re3), .up_im(out_im3),
        .low_re(out_re7), .low_im(out_im7)
    );

endmodule
