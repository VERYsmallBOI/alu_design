module alu #(
    parameter width = 8,
    cwidth = 4
) (
    clk, rst, inp_valid, mode, cmd, ce, opa, opb, cin, err, result, offlow, cout, g, l, e
);
    //change after finishing all result to res
    input wire clk, rst, inp_valid, mode, ce, cin;
    input wire [width-1:0] opa, opb;
    input wire [cwidth-1:0] cmd;
    output reg g, l, e;
    output wire cout, offlow;
    output wire err;
    output reg [2*width-1:0] result;

    //cout for unsgined + and overflow for everyother
    //0 is driver default not z

    reg [1:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
            g      <= 0;
            l      <= 0;
            e      <= 0;
        end else begin
            if (ce) begin
                g      <= 0;
                l      <= 0;
                e      <= 0;
                result <= 0;
                if (mode) begin
                    case (cmd)
                        0: begin
                            result <= opa + opb;
                        end
                        1: begin
                            result <= opa - opb;
                        end
                        2: begin
                            result <= cin + opa + opb;
                        end
                        3: begin
                            result <= opa - opb - cin;
                        end
                        4: result <= opa + 1;
                        5: result <= opa - 1;
                        6: result <= opb + 1;
                        7: result <= opb - 1;
                        8: begin
                            g <= (opa > opb);
                            l <= (opa < opb);
                            e <= (opa == opb);
                        end
                        9: 
                        result<=(opa+1)*(opb+1);

                        10: result<=(opa<<1)*(opb);
                        11: 
                        begin
                            g <= (opa > opb);
                            l <= (opa < opb);
                            e <= (opa == opb);
                            result <= $signed(opa) + $signed(opb);
                        end
                        
                        12:  begin
                            g <= (opa > opb);
                            l <= (opa < opb);
                            e <= (opa == opb);
                            result <= $signed(opa) - $signed(opb);
                        end
                        default: result <= 0;
                    endcase
                end else begin
                    case (cmd)
                        0:       result <= opa & opb;
                        1:       result <= ~(opa & opb);
                        2:       result <= opa | opb;
                        3:       result <= ~(opa | opb);
                        4:       result <= opa ^ opb;
                        5:       result <= (opa ~^ opb);
                        6:       result <= ~opa;
                        7:       result <= ~opb;
                        8:       result <= opa >> 1;
                        9:       result <= opa << 1;
                        10:      result <= opb >> 1;
                        11:      result <= opb << 1;
                        12:      result <= (((1 << width) - 1) & ((opa >> (width - opb[2:0])) | (opa << (opb[2:0]))));
                        13:      result <= (((1 << width) - 1) & ((opa << (width - opb[2:0])) | (opa >> (opb[2:0]))));
                        default: result <= 0;
                    endcase
                end
            end
        end
    end

    assign offlow = rst ? 0 : (
        ((mode & (cmd == 11)) & (opa[width-1] == opb[width-1]) & (result[width-1] != (opa[width-1]))) ||
        ((mode & (cmd == 12)) & (opa[width-1] != opb[width-1]) & (result[width-1] != (opa[width-1]))) ||
        ((mode & (cmd == 1)) & (opb > opa)) ||
        ((mode & (cmd == 3)) & ((opb + cin) > opa))
    );

    assign cout = rst ? 0 : (
        (mode & (cmd == 0) & (result[width-1])) ||
        (mode & (cmd == 2) & (result[width-1]))
    );

endmodule