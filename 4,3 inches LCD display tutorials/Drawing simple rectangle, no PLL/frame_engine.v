module frame_engine (
    input clk,
    input rst,
    input start,
    output reg busy,
    output reg we,
    output reg [13:0] addr,
    output reg [15:0] data
);

reg start_d;
wire start_edge = start & ~start_d;

localparam FB_W = 160;
localparam FB_H = 90;
localparam FB_SIZE = FB_H * FB_W;

localparam FG_X0 = 20;
localparam FG_Y0 = 4;
localparam FG_W = 25;
localparam FG_H = 12;

reg [13:0] i;
reg [7:0] x;
reg [6:0] y;

wire in_fg=
    (x >= FG_X0 && x < (FG_X0 + FG_W)) &&
    (y >= FG_Y0 && y < (FG_Y0 + FG_H));

always @(posedge clk or negedge rst)begin
    if (!rst) begin
        busy <= 0;
        we <= 0;
        addr <= 0;
        data <= 0;
        i <= 0;
        x <= 0;
        y <= 0;
        start_d <= 0;
    end else begin
        start_d <= start;
        if(start_edge && !busy)begin
            busy <= 1;
            i <= 0;
            x <= 0;
            y <= 0;
        end

        we <= 0;

        if(busy) begin
            we <= 1;
            addr <= i;

            if(in_fg)
                data <= 16'hf800;
            else
                data <= 16'h07e0;


            if(i == FB_SIZE - 1)begin
                busy <= 0;
            end else begin
                i <= i + 1;

                if (x == FB_W - 1) begin
                    x <= 0;
                    y <= y+1;
                end else begin
                    x <= x + 1;
                end
        end

    end

end

end



endmodule