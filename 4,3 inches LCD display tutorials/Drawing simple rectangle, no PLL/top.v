module top (
    input XTAL_IN,
    input nRST,
    output LCD_CLK,
    output LCD_HSYNC,
    output LCD_VSYNC,
    output LCD_DEN,
    output [4:0] LCD_R,
    output [5:0] LCD_G,
    output [4:0] LCD_B
);

assign LCD_CLK = XTAL_IN;

reg [9:0] x;
reg [9:0] y;

always @(posedge XTAL_IN or negedge nRST)begin
    if(!nRST)begin
        x <= 0;
        y <= 0;
    end else begin
        if(x == 799)begin
            x <= 0;
            if(y==524)
                y <= 0;
            else
                y <= y + 1;
        end else begin
            x <= x + 1;
        end
    end
end

wire hsync = (x < 41);
wire vsync = (y < 10);

wire visible = 
    (x >= 43 && x < 523 &&
    y >= 12 && y < 282);

localparam Y_SHIFT = 20;
wire [7:0] fb_x = x / 3;
wire [9:0] y_shifted = (y>Y_SHIFT) ? (y - Y_SHIFT) : 0;
wire [7:0] fb_y = y_shifted / 3;
wire [13:0] rd_addr = visible ? (fb_y * 160 + fb_x) : 0;

wire [15:0] pixels;

framebuffer fb (
    .clk(XTAL_IN),
    .we(we),
    .waddr(waddr),
    .wdata(wdata),
    .raddr(rd_addr),
    .rdata(pixels)
);

wire we;
wire [13:0] waddr;
wire [15:0] wdata;

frame_engine engine(
    .clk(XTAL_IN),
    .rst(nRST),
    .start(1'b1),
    .busy(),
    .we(we),
    .addr(waddr),
    .data(wdata)
);

reg [15:0] pixel_d;
reg visible_d;
reg hsync_d;
reg vsync_d;

always @(posedge XTAL_IN)begin
    pixel_d <= pixels;
    visible_d <= visible;
    hsync_d <= hsync;
    vsync_d <= vsync;
end

assign LCD_R = visible_d ? pixel_d[15:11] : 0;
assign LCD_G = visible_d ? pixel_d[10:5] : 0;
assign LCD_B = visible_d ? pixel_d[4:0] : 0;

assign LCD_DEN = visible_d;
assign LCD_HSYNC = hsync_d;
assign LCD_VSYNC = vsync_d;

endmodule