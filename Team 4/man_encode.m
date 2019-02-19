function [ mnrz_wavefm ] = man_encode(bin_str)
    L_lc = 2;
    ones_arr = ones(1,L_lc);
    mnrz_wavefm = [];
    for ind = 1:1:length(bin_str)
        if (bin_str(ind) == 1)
            mnrz_wavefm = [mnrz_wavefm ones_arr(1:L_lc/2)*0];
            mnrz_wavefm = [mnrz_wavefm ones_arr(1:L_lc/2)*1];

        else
            mnrz_wavefm = [mnrz_wavefm ones_arr(1:L_lc/2)*1];
            mnrz_wavefm = [mnrz_wavefm ones_arr(1:L_lc/2)*0];
        end
    end
end
