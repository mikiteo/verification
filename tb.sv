module tb_image_filter();
    
    parameter p_data_bw = 10;
    parameter p_win_size = 9;

    logic i_clk, i_rstn;
    logic [p_data_bw - 1 : 0] i_config;

    logic i_dxi_in_valid;
    logic o_dxi_in_ready;
    logic [p_data_bw - 1 : 0] i_dxi_in_data [p_win_size];
    
    logic [p_data_bw - 1 : 0] o_dxi_out_data;
    logic o_dxi_out_valid;
    logic i_dxi_out_ready;

    image_filter #(
        .p_data_bw          (p_data_bw),
        .p_win_size         (p_win_size)
    ) DUT (
        .i_clk              (i_clk),
        .i_rstn             (i_rstn),
        .i_config           (i_config),

        .i_dxi_in_valid     (i_dxi_in_valid),
        .o_dxi_in_ready     (o_dxi_in_ready),
        .i_dxi_in_data      (i_dxi_in_data),

        .o_dxi_out_data     (o_dxi_out_data),
        .o_dxi_out_valid    (o_dxi_out_valid),
        .i_dxi_out_ready    (i_dxi_out_ready)
    );

    initial begin
        clk = 0;
        forever begin
            #(p_clk_period/2) clk = ~clk;
        end
    end

    initial begin
        i_rstn = 0;
        #15 
        i_rstn = 1;
    end

    task set_filter_type(input logic [1:0] filter_type);
        i_config = filter_type;
    endtask



    initial begin

    end


endmodule
