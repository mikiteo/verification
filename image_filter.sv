module filter #(
    parameter p_data_bw = 10,
    parameter p_win_size = 9
)(
    input                               i_clk       ,
    input                               i_rstn      ,

    input   logic [p_data_bw - 1 : 0]   i_config    ,

    input                               i_dxi_in_valid              ,
    output  logic                       o_dxi_in_ready              ,
    input   logic [p_data_bw - 1 : 0]   i_dxi_in_data [p_win_size]  ,

    output  logic [p_data_bw - 1 : 0]   o_dxi_out_data              ,
    output  logic                       o_dxi_out_valid             ,
    input                               i_dxi_out_ready

);

    logic [p_data_bw + 10 -1 : 0] sum_of_coef;
    logic [p_data_bw + 10 -4 -1 : 0] div_sum;
    logic [p_data_bw -1 : 0] result;
    logic [p_data_bw -1 : 0] result_ff;


    always_comb begin
        case (i_config)
            2'b00: begin // Laplacian Kernel 1
                sum_of_coef =           0 * i_dxi_in_data[0] + (-1) * i_dxi_in_data[1] + 0 * i_dxi_in_data[2] +
                                        (-1) * i_dxi_in_data[3] + 4 * i_dxi_in_data[4] + (-1) * i_dxi_in_data[5] +
                                        0 * i_dxi_in_data[6] + (-1) * i_dxi_in_data[7] + 0 * i_dxi_in_data[8];
            end 
            2'b01: begin // Laplacian Kernel 2
                sum_of_coef =           (-1) * i_dxi_in_data[0] + (-1) * i_dxi_in_data[1] + (-1) * i_dxi_in_data[2] +
                                        (-1) * i_dxi_in_data[3] + 8 * i_dxi_in_data[4] + (-1) * i_dxi_in_data[5] +
                                        (-1) * i_dxi_in_data[6] + (-1) * i_dxi_in_data[7] + (-1) * i_dxi_in_data[8];
            end 
            2'b10: begin // Gaussian Filter
                sum_of_coef =           1 * i_dxi_in_data[0] + 2 * i_dxi_in_data[1] + 1 * i_dxi_in_data[2] +
                                        2 * i_dxi_in_data[3] + 4 * i_dxi_in_data[4] + 2 * i_dxi_in_data[5] +
                                        1 * i_dxi_in_data[6] + 2 * i_dxi_in_data[7] + 1 * i_dxi_in_data[8];
            end 
            2'b11: begin // Average Filter
                sum_of_coef =           1 * i_dxi_in_data[0] + 1 * i_dxi_in_data[1] + 1 * i_dxi_in_data[2] +
                                        1 * i_dxi_in_data[3] + 1 * i_dxi_in_data[4] + 1 * i_dxi_in_data[5] +
                                        1 * i_dxi_in_data[6] + 1 * i_dxi_in_data[7] + 1 * i_dxi_in_data[8];
            end 
        endcase
    end

    assign  div_sum = sum_of_coef >>> 2;

    always_comb begin
        if (div_sum > 1023)
            result = 1023;
        else
            result = div_sum;
    end

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            result_ff <= 0;
            o_dxi_out_valid <= 0;
        end else if (i_dxi_in_valid && o_dxi_in_ready) begin
            o_dxi_out_valid <= 1;
            result_ff <= result; 
        end else begin
            o_dxi_out_valid <= 0; 
        end
    end

    assign o_dxi_in_ready = i_dxi_out_ready;
    assign o_dxi_out_data = result_ff;

endmodule  