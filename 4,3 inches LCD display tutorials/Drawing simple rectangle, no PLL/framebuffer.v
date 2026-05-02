module framebuffer (
    input clk,
    input we,
    input [13:0] waddr,
    input [15:0] wdata,
    input [13:0] raddr,
    output reg [15:0] rdata
);

localparam FB_W = 160;
localparam FB_H = 90;
localparam FB_SIZE = FB_W * FB_H;

reg [15:0] mem [0:FB_SIZE-1];

always @(posedge clk)begin
    if (we)
        mem[waddr] <=wdata;

    rdata <= mem[raddr];
end

endmodule