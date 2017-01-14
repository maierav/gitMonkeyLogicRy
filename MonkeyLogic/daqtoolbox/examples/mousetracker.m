% This example demonstrates how to acquired the position of the mouse cursor
% continuously (at ~1 kHz).

mouse = pointingdevice;
start(mouse);  % start sampling

timer = tic;
while toc(timer) < 10  % run for 10 sec
    % check the current position
    [x,y,left,right,timestamp] = decodemouse(getsample(mouse));

    fprintf('%4d %4d %1d %1d %8d\r',x,y,left,right,timestamp);
    pause(0.02);
end

stop(mouse);  % stop sampling

% retrieve all samples collected
[x,y,left,right,timestamp] = decodemouse(getdata(mouse));
