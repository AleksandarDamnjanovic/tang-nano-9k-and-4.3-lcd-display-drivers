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

always @(posedge XTAL_IN or negedge nRST) begin

    if(!nRST) begin
        x <= 0;
        y <= 0;

    end else begin

        if(x == 799) begin
            x <= 0;

            if(y == 524)
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

wire signed [11:0] px = x - 43;
wire signed [11:0] py = y - 12;

wire visible =
    (px >= 0 && px < 480 &&
     py >= 0 && py < 272);

reg vis_d;

always @(posedge XTAL_IN)
    vis_d <= visible;


localparam SCALE = 4;
localparam TEXT_W = 72;
localparam TEXT_H = 28;

localparam TEXT_X = (480 - TEXT_W)/2;
localparam TEXT_Y = (272 - TEXT_H)/2;

wire signed [11:0] lx = px - TEXT_X;
wire signed [11:0] ly = py - TEXT_Y;

wire inside_text = 
                (lx >= 0 && lx < TEXT_W &&
                 ly >= 0 && ly < TEXT_H);

wire [11:0] tx = lx >>> 2;
wire [11:0] ty = ly >>> 2;
wire [2:0] char_x = tx % 6;
wire [2:0] char_y = ty;
wire [1:0] char_id = tx / 6;


function font_lookup;
    input [1:0] cid;
    input [2:0] cx;
    input [2:0] cy;

    begin
        font_lookup = 0;
        case(cid)
            0:begin
                case(cy)
                    0: font_lookup = (cx==0 || cx==4);
                    1: font_lookup = (cx==0 || cx==4);
                    2: font_lookup = (cx==0 || cx==4);
                    3: font_lookup = (cx<=4);
                    4: font_lookup = (cx==0 || cx==4);
                    5: font_lookup = (cx==0 || cx==4);
                    6: font_lookup = (cx==0 || cx==4);
                endcase
            end
            1:begin
                case(cy)
                    0: font_lookup = (cx<=4);
                    1: font_lookup = (cx==0);
                    2: font_lookup = (cx==0);
                    3: font_lookup = (cx<=3);
                    4: font_lookup = (cx==0);
                    5: font_lookup = (cx==0);
                    6: font_lookup = (cx<=4);
                endcase
            end
            2:begin
                case(cy)
                    0: font_lookup = (cx==0 || cx==4);
                    1: font_lookup = (cx==0 || cx==4);
                    2: font_lookup = (cx==1 || cx==3);
                    3: font_lookup = (cx==2);
                    4: font_lookup = (cx==2);
                    5: font_lookup = (cx==2);
                    6: font_lookup = (cx==2);
                endcase
            end

        default:
            font_lookup = 0;
        endcase
    end
endfunction

wire font_pixel = 
                inside_text &&
                font_lookup(char_id, char_x, char_y);

wire left_n =
            inside_text &&
            font_lookup((tx-1)/6, (tx-1)%6, char_y);

wire right_n =
            inside_text &&
            font_lookup((tx+1)/6, (tx+1)%6, char_y);

wire up_n =
            inside_text &&
            font_lookup(char_id, char_x, ty - 1);

wire down_n =
            inside_text &&
            font_lookup(char_id, char_x, ty + 1);

wire aa_pixel=
            !font_pixel &&
            (left_n || right_n || up_n ||down_n);

reg [15:0] color;

always @(*)begin
    color = 16'h0010;

    if(aa_pixel)
        color = 16'h4810;

    if(font_pixel)
        color = 16'hffff;

end


reg [15:0] pixel_d;

always @(posedge XTAL_IN)
    pixel_d <= color;

assign LCD_R = vis_d ? pixel_d[15:11] : 0;
assign LCD_G = vis_d ? pixel_d[10:5]  : 0;
assign LCD_B = vis_d ? pixel_d[4:0]   : 0;

assign LCD_DEN   = vis_d;
assign LCD_HSYNC = hsync;
assign LCD_VSYNC = vsync;

endmodule