% get xy points (deg) on screen for eye calibration for dichoptic paradigms

% Fall 2015, KD
% April 2016, MAC 

% setup array of x and y cordinates
clear x y tl int
int = 5;
y = [5:-int:-5];
x = y;
tl = combvec(x,y); 
tl = horzcat([0;0], tl);

% extract ScreenInfo from Calibration Window BasicData
clear fig ScreenInfo BasicData
fig = findobj('tag', 'xycalibrate');
BasicData = get(fig, 'userdata');
ScreenInfo   = BasicData.ScreenInfo;
fprintf('\n<<<  Maier Lab  >>> PixelsPerDegree = %0.2f\n',ScreenInfo.PixelsPerDegree);


% findScreenPos
clear rightlist leftlist 
for TOcount = 1:2
    % 1 = LE, 2 = RE
    clear X Y 
    [X,Y] = findScreenPos(TOcount,ScreenInfo,tl(1,:),tl(2,:),'cart');
    
    if TOcount == 1
        leftlist = [X;Y];
    elseif TOcount == 2
        rightlist = [X;Y];
    end
    
end

clear new_targetlist
new_targetlist(:,1) = leftlist(:,1);
new_targetlist(:,2) = rightlist(:,1);
for idx = 2:length(y):length(leftlist)
    new_targetlist = [new_targetlist leftlist(:,idx:idx+length(y)-1)  rightlist(:,idx:idx+length(y)-1)];
end
    
clearvars -except rightlist leftlist new_targetlist