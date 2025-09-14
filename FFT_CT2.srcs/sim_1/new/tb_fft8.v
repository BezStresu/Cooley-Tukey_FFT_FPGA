// tb_fft8.v
`timescale 1ns/1ps
module tb_fft8;
    parameter INW = 16;
    parameter IW  = 32;

    reg signed [INW-1:0] in_re0, in_re1, in_re2, in_re3, in_re4, in_re5, in_re6, in_re7;
    reg signed [INW-1:0] in_im0, in_im1, in_im2, in_im3, in_im4, in_im5, in_im6, in_im7;

    wire signed [IW-1:0] out_re0, out_re1, out_re2, out_re3, out_re4, out_re5, out_re6, out_re7;
    wire signed [IW-1:0] out_im0, out_im1, out_im2, out_im3, out_im4, out_im5, out_im6, out_im7;

    // Instantiate FFT
    fft8_top #(.INW(INW), .IW(IW)) dut (
        .in_re0(in_re0), .in_re1(in_re1), .in_re2(in_re2), .in_re3(in_re3), .in_re4(in_re4), .in_re5(in_re5), .in_re6(in_re6), .in_re7(in_re7),
        .in_im0(in_im0), .in_im1(in_im1), .in_im2(in_im2), .in_im3(in_im3), .in_im4(in_im4), .in_im5(in_im5), .in_im6(in_im6), .in_im7(in_im7),
        .out_re0(out_re0), .out_re1(out_re1), .out_re2(out_re2), .out_re3(out_re3), .out_re4(out_re4), .out_re5(out_re5), .out_re6(out_re6), .out_re7(out_re7),
        .out_im0(out_im0), .out_im1(out_im1), .out_im2(out_im2), .out_im3(out_im3), .out_im4(out_im4), .out_im5(out_im5), .out_im6(out_im6), .out_im7(out_im7)
    );

    initial begin
        // Input: x[n] = cos(2*pi*n/8)  (Q1.15)
        // Precomputed Q1.15 values:
        in_re0 = 16'h7fff; //  1.0000
        in_re1 = 16'h5a82; //  0.7071
        in_re2 = 16'h0000; // ~0
        in_re3 = 16'ha57e; // -0.7071
        in_re4 = 16'h8001; // -1.0000 (-32767)
        in_re5 = 16'ha57e; // -0.7071
        in_re6 = 16'h0000; // ~0
        in_re7 = 16'h5a82; //  0.7071

        // all imag parts = 0
        in_im0 = 16'h0000; in_im1 = 16'h0000; in_im2 = 16'h0000; in_im3 = 16'h0000;
        in_im4 = 16'h0000; in_im5 = 16'h0000; in_im6 = 16'h0000; in_im7 = 16'h0000;

        #5; // wait combinational propagation

        $display("FFT-8 outputs (integer Q-format scaled by 2^15):");
        $display("k |  re (int)    imag (int)   |  re (float)        imag (float)");
        $display("---------------------------------------------------------------");
        $display("0 | %8d %8d | %12f %12f", out_re0, out_im0, $itor(out_re0)/32767.0, $itor(out_im0)/32767.0);
        $display("1 | %8d %8d | %12f %12f", out_re1, out_im1, $itor(out_re1)/32767.0, $itor(out_im1)/32767.0);
        $display("2 | %8d %8d | %12f %12f", out_re2, out_im2, $itor(out_re2)/32767.0, $itor(out_im2)/32767.0);
        $display("3 | %8d %8d | %12f %12f", out_re3, out_im3, $itor(out_re3)/32767.0, $itor(out_im3)/32767.0);
        $display("4 | %8d %8d | %12f %12f", out_re4, out_im4, $itor(out_re4)/32767.0, $itor(out_im4)/32767.0);
        $display("5 | %8d %8d | %12f %12f", out_re5, out_im5, $itor(out_re5)/32767.0, $itor(out_im5)/32767.0);
        $display("6 | %8d %8d | %12f %12f", out_re6, out_im6, $itor(out_re6)/32767.0, $itor(out_im6)/32767.0);
        $display("7 | %8d %8d | %12f %12f", out_re7, out_im7, $itor(out_re7)/32767.0, $itor(out_im7)/32767.0);

        $finish;
    end
endmodule
