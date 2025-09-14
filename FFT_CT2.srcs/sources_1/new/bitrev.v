// bitrev.v
// bit reversal for N=8 (3-bit reversals).
`timescale 1ns/1ps
module bitrev
#( parameter AW = 16 )
(
    input  signed [AW-1:0] in_re0, in_re1, in_re2, in_re3, in_re4, in_re5, in_re6, in_re7,
    input  signed [AW-1:0] in_im0, in_im1, in_im2, in_im3, in_im4, in_im5, in_im6, in_im7,
    output signed [AW-1:0] out_re0, out_re1, out_re2, out_re3, out_re4, out_re5, out_re6, out_re7,
    output signed [AW-1:0] out_im0, out_im1, out_im2, out_im3, out_im4, out_im5, out_im6, out_im7
);
    // bitrev mapping for 3-bit indices:
    // index -> reversed_index: 0->0,1->4,2->2,3->6,4->1,5->5,6->3,7->7
    assign out_re0 = in_re0; assign out_im0 = in_im0;
    assign out_re1 = in_re4; assign out_im1 = in_im4;
    assign out_re2 = in_re2; assign out_im2 = in_im2;
    assign out_re3 = in_re6; assign out_im3 = in_im6;
    assign out_re4 = in_re1; assign out_im4 = in_im1;
    assign out_re5 = in_re5; assign out_im5 = in_im5;
    assign out_re6 = in_re3; assign out_im6 = in_im3;
    assign out_re7 = in_re7; assign out_im7 = in_im7;
endmodule
