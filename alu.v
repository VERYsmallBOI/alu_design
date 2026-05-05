module alu #(
    parameter width = 8,
    cwidth = 4
) (
    clk, rst, inp_valid, mode, cmd, ce, opa, opb, cin, err, res, offlow, cout, g, l, e
);
    //change after finishing all res to res
    input wire clk, rst, mode, ce, cin;
    input wire [1:0]inp_valid;
    input wire [width-1:0] opa, opb;
    input wire [cwidth-1:0] cmd;
    output reg g, l, e;
    output wire cout, offlow;
    output reg err;
    output reg [2*width-1:0] res;

    reg [2*width-1:0] res1;

    //cout for unsgined + and overflow for everyother
    //0 is driver default not z

reg mg;//

    reg [1:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res <= 0;
            g      <= 0;
            l      <= 0;
            e      <= 0;
            mg     <= 0;
            res1<=0;
        end else begin
            if (ce) begin
                g      <= 0;
                l      <= 0;
                e      <= 0;
                res <= 0;
                res1<=0;
                count<=(cmd==4'd10||cmd==4'd9)?count:0;
                mg     <= (count!=0)?mg:0;
                if (mode) begin
                    case (cmd)
                        0: begin
                            res <= opa + opb;
                        end
                        1: begin
                            res <= opa - opb;
                        end
                        2: begin
                            res <= cin + opa + opb;
                        end
                        3: begin
                            res <= opa - opb - cin;
                        end
                        4: res <= opa + 1'b1;
                        5: res <= opa - 1'b1;
                        6: res <= opb + 1'b1;
                        7: res <= opb - 1'b1;
                        8: begin
                            g <= (opa > opb);
                            l <= (opa < opb);
                            e <= (opa == opb);
                        end
                        9: 
                        begin
                        if(count>=2'd2)
                        begin
                            res<=res1;
                            count<=0;
                            
                        end
                        else if(count==0)
                        begin
                        mg<=(inp_valid!=2'b11);
                        res1<=(opa+1'b1)*(opb+1'b1);
                        count<=count+1'b1;
                        end
                        else count<=(cmd=='d9)?count+1'b1:1'b1;
                        end
                        10:
                        begin
                        if(count>=2'd2)
                        begin
                            res<=res1;
                            count<=0;
                            
                        end
                        else if(count==0)
                        begin
                        mg<=(inp_valid!=2'b11);
                        res1<=(opa<<1'b1)*(opb);
                        count<=count+1'b1;
                        end
                        else count<=(cmd=='d10)?count+1'b1:1'b1;
                        end
                        11: 
                        begin
                            g <= (opa > opb);
                            l <= (opa < opb);
                            e <= (opa == opb);
                            res <= $signed(opa) + $signed(opb);
                        end
                        
                        12:  begin
                            g <= (opa > opb);
                            l <= (opa < opb);
                            e <= (opa == opb);
                            res <= $signed(opa) - $signed(opb);
                        end
                        default: res <= 0;
                    endcase
                end else begin
                    case (cmd)
                        0:       res <= opa & opb;
                        1:       res <= ~(opa & opb);
                        2:       res <= opa | opb;
                        3:       res <= ~(opa | opb);
                        4:       res <= opa ^ opb;
                        5:       res <= (opa ~^ opb);
                        6:       res <= ~opa;
                        7:       res <= ~opb;
                        8:       res <= opa >> 1;
                        9:       res <= opa << 1;
                        10:      res <= opb >> 1;
                        11:      res <= opb << 1;
                        12:      res <= (((1 << width) - 1) & ((opa >> (width - opb[$clog2(width):0])) | (opa << (opb[$clog2(width):0]))));
                        13:      res <= (((1 << width) - 1) & ((opa << (width - opb[$clog2(width):0])) | (opa >> (opb[$clog2(width):0]))));
                        default: res <= 0;
                    endcase
                end
            end
        end
    end

    assign offlow = rst ? 0 : (
        ((mode & (cmd == 11)) & (opa[width-1] == opb[width-1]) & (res[width-1] != (opa[width-1]))) ||
        ((mode & (cmd == 12)) & (opa[width-1] != opb[width-1]) & (res[width-1] != (opa[width-1]))) ||
        ((mode & (cmd == 1)) & (opb > opa)) ||
        ((mode & (cmd == 3)) & ((opb + cin) > opa))
    );

    assign cout = rst ? 0 : (
        (mode & (cmd == 0) & (res[width])) ||
        (mode & (cmd == 2) & (res[width]))
    );

    always@(posedge clk,posedge rst)
    begin
        if(rst)
        err<=0;
        else
        err<=((mg)&&(count==2'd2))||((inp_valid!=2'b11)&(cmd!=4'd10||cmd!=4'd9))||((cmd==12||cmd==13)&(~mode)&(opb>((1 << $clog2(width)) - 1)));
    end


endmodule