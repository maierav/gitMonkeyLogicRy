function [x,y,left,right,timestamp] = decodetouch(samples)

bin = dec2bin(samples(:,1),32);

x = (2*('0'==bin(:,3))-1) .* bin2dec(bin(:,5:18));
y = (2*('0'==bin(:,4))-1) .* bin2dec(bin(:,19:32));
left = '1'==bin(:,1);
right = '1'==bin(:,2);
row = ~(left|right);
x(row) = NaN;
y(row) = NaN;
timestamp = samples(:,2);
