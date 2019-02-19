function [signal] = find_preamble(bin_str)
preamble = [1 1 0 1 1 0 1 0 1 1 1 0 0 0 1 1 0 1 0 1 0 1 0];
max_sum = 0;
for i=1:1:length(bin_str)-22

if sum(preamble == bin_str(i:i+22)') > max_sum
    max_sum = sum(preamble == bin_str(i:i+22)');
    index = i;
end
end

signal = man_decode(bin_str(index+23:index+150));

end