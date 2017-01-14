function out = dec2binvec(dec,n)

if ~exist('n','var')
    out = dec2bin(dec);
else
    out = dec2bin(dec,n);
end

out = logical(str2num(flipud([out; blanks(length(out))]')))'; %#ok<ST2NM>
