module alu#(parameter width=8,cwidth=4)(clk,rst,inp_valid,mode,cmd,ce,opa,opb,cin,err,res,offlow,cout,g,l,e);
//change after finishing all result to res
    input wire clk,rst,inp_valid,mode,ce,cin;
    input wire [width-1:0]opa,opb;
    input wire [cwidth-1:0]cmd;
    output reg g,l,e;
    output wire cout,offlow;
    output wire err;
    output [2*width-1:0]result;

    //cout for unsgined + and overflow for everyother
    //0 is driver default not z

    reg [1:0]count;

    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            result<=0;
            g<=0;
            l<=0;
            e<=0;
            
        end
        else
        begin
            if(ce)
            begin
                if(mode)
                begin
                    case(cmd)
                        0:
                        begin
                            result<=opa+opb;
                        end
                        1:
                        begin
                            result<=opa-opb;

                        end

                        2:
                            begin
                                result<=cin+opa+opb;
                            end
                        

                        3:
                        begin
                            result<=opa-opb-cin;
                        end


                        4:
                        5:
                        6;
                        7:
                        8:
                        9:
                        10:
                        11:
                        12:
                        default:
                    endcase
                end
            end
        end
    end




assign offlow = rst ? 0 : ((
    (mode & (cmd == 11)) & 
    (opa[width-1] == opb[width-1]) & 
    (result[width-1] != (opa[width-1]))
) || (
    (mode & (cmd == 12)) & 
    (opa[width-1] != opb[width-1]) & 
    (result[width-1] != (opa[width-1]))
) || (
    (mode & (cmd == 1)) & 
    (opb > opa)
));


assign cout = rst ? 0 : (( 
    mode & (cmd == 0) & (result[width-1]) 
)||( 
    mode & (cmd == 2) & (result[width-1]) 
)

);


    


endmodule