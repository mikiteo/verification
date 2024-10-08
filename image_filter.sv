module filter__coef #(
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

    logic [p_win_size - 1 : 0] filter_coef
    logic [p_data_bw + 10 -1 : 0] sum_of_coef;
    logic [p_data_bw + 10 -1 : 0] abs_val; 
    logic [p_data_bw + 10 -4 -1 : 0] result;
    logic [p_data_bw -1 : 0] result_ff;


    always_comb begin
        case (i_config)
            
            2'b00: begin // Laplacian Kernel 1
                filter_coef[0] =  0; filter_coef[1] = -1; filter_coef[2] =  0;
                filter_coef[3] = -1; filter_coef[4] = 4;  filter_coef[5] = -1;
                filter_coef[6] =  0; filter_coef[7] = -1; filter_coef[8] =  0;
            end 
            2'b01: begin // Laplacian Kernel 2
                filter_coef[0] = -1; filter_coef[1] = -1; filter_coef[2] = -1;
                filter_coef[3] = -1; filter_coef[4] = 8;  filter_coef[5] = -1;
                filter_coef[6] = -1; filter_coef[7] = -1; filter_coef[8] = -1;
            end 
            2'b10: begin // Gaussian Filter
                filter_coef[0] = 1;  filter_coef[1] = 2;  filter_coef[2] = 1;
                filter_coef[3] = 2;  filter_coef[4] = 4;  filter_coef[5] = 2;
                filter_coef[6] = 1;  filter_coef[7] = 2;  filter_coef[8] = 1;
            end 
            2'b11: begin // Average Filter
                filter_coef[0] = 1;  filter_coef[1] = 1;  filter_coef[2] = 1;
                filter_coef[3] = 1;  filter_coef[4] = 1;  filter_coef[5] = 1;
                filter_coef[6] = 1;  filter_coef[7] = 1;  filter_coef[8] = 1;
            end 
        endcase
    end

    genvar i;
    generate
        for (i = 0; i < p_win_size; ++i) begin
            always_comb begin
                abs_val = (i_dxi_in_data[i] * filter_coef[i]);

                if (abs_val < 0) begin
                    abs_val = -abs_val;
                end

                sum_of_coef = sum_of_coef + abs_val;
            end
        end
    endgenerate

    always_comb begin
        case (i_config)
            2'b00: begin
                result = sum_of_coef >>> 2; 
            end
            2'b01: begin
                result = sum_of_coef >>> 3; 
            end
            2'b10: begin
                result = sum_of_coef >>> 4; 
            end
            2'b11: begin
                result = (sum_of_coef >>> 3) + (sum_of_coef >>> 6); 
            end
        endcase
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