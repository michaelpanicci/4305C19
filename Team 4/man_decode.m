function [ mnrz_wavefm ] = man_decode(bin_str)
    L_lc = 2;
    index = 'not found';
    ones_arr = ones(1,L_lc);
    mnrz_wavefm = [];
    for ind = 1:2:length(bin_str)-1
        if (bin_str(ind) == 0 && bin_str(ind+1) == 1)
            mnrz_wavefm = [mnrz_wavefm 1];

        elseif (bin_str(ind) == 1 && bin_str(ind+1) == 0)
            mnrz_wavefm = [mnrz_wavefm 0];
            
        else
            mnrz_wavefm = [mnrz_wavefm 0];
        end
    end
end
