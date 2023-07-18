module tub_show (
    input wire clk,
    input wire rst_n,
    input wire [31:0] data,
    output reg [7:0] led_en,
    output reg led_ca,
    output reg led_cb,
    output reg led_cc,
    output reg led_cd,
    output reg led_ce,
    output reg led_cf,
    output reg led_cg,
    output wire led_dp
);

assign led_dp = 1'b1;
reg [21:0] cnt;
parameter cnt2ms_Max = 22'd200000;
wire flag_2ms = (cnt == cnt2ms_Max - 22'b1);

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        cnt <= 22'b0;
    else if (flag_2ms)
        cnt <= 22'b0;
    else
        cnt <= cnt + 1;
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        led_en <= 8'b11111110;
    else if (flag_2ms)
        led_en <= {led_en[6:0], led_en[7]};
end

reg [3:0] num;

always @ (*) begin
    case (led_en)
        8'b11111110 :
            num = data[3:0];
        8'b11111101 :
            num = data[7:4];
        8'b11111011 :
            num = data[11:8];
        8'b11110111 :
            num = data[15:12];
        8'b11101111:
            num = data[19:16];
        8'b11011111 :
            num = data[23:20];
        8'b10111111 :
            num = data[27:24];
        8'b01111111 :
            num = data[31:28];
        default :
            num = 4'h0;
    endcase
end

always @ (*) begin
    case (num)
        4'h0 : begin
            led_ca = 0; led_cb = 0; led_cc = 0; led_cd = 0; led_ce = 0; led_cf = 0; led_cg = 1;
        end
        4'h1 : begin
            led_ca = 1; led_cb = 0; led_cc = 0; led_cd = 1; led_ce = 1; led_cf = 1; led_cg = 1;
        end
        4'h2 : begin
            led_ca = 0; led_cb = 0; led_cc = 1; led_cd = 0; led_ce = 0; led_cf = 1; led_cg = 0;
        end
        4'h3 : begin
            led_ca = 0; led_cb = 0; led_cc = 0; led_cd = 0; led_ce = 1; led_cf = 1; led_cg = 0;
        end
        4'h4 : begin
            led_ca = 1; led_cb = 0; led_cc = 0; led_cd = 1; led_ce = 1; led_cf = 0; led_cg = 0;
        end
        4'h5 : begin
            led_ca = 0; led_cb = 1; led_cc = 0; led_cd = 0; led_ce = 1; led_cf = 0; led_cg = 0;
        end
        4'h6 : begin
            led_ca = 0; led_cb = 1; led_cc = 0; led_cd = 0; led_ce = 0; led_cf = 0; led_cg = 0;
        end
        4'h7 : begin
            led_ca = 0; led_cb = 0; led_cc = 0; led_cd = 1; led_ce = 1; led_cf = 1; led_cg = 1;
        end
        4'h8 : begin
            led_ca = 0; led_cb = 0; led_cc = 0; led_cd = 0; led_ce = 0; led_cf = 0; led_cg = 0;
        end
        4'h9 : begin
            led_ca = 0; led_cb = 0; led_cc = 0; led_cd = 1; led_ce = 1; led_cf = 0; led_cg = 0;
        end
        4'ha : begin
            led_ca = 0; led_cb = 0; led_cc = 0; led_cd = 1; led_ce = 0; led_cf = 0; led_cg = 0;
        end
        4'hb : begin
            led_ca = 1; led_cb = 1; led_cc = 0; led_cd = 0; led_ce = 0; led_cf = 0; led_cg = 0;
        end
        4'hc : begin
            led_ca = 1; led_cb = 1; led_cc = 1; led_cd = 0; led_ce = 0; led_cf = 1; led_cg = 0;
        end
        4'hd : begin
            led_ca = 1; led_cb = 0; led_cc = 0; led_cd = 0; led_ce = 0; led_cf = 1; led_cg = 0;
        end
        4'he : begin
            led_ca = 0; led_cb = 1; led_cc = 1; led_cd = 0; led_ce = 0; led_cf = 0; led_cg = 0;
        end
        4'hf : begin
            led_ca = 0; led_cb = 1; led_cc = 1; led_cd = 1; led_ce = 0; led_cf = 0; led_cg = 0;
        end
        default: begin
            led_ca = 0; led_cb = 0; led_cc = 0; led_cd = 0; led_ce = 0; led_cf = 0; led_cg = 0;
        end
    endcase
end

endmodule