% get xy points (deg) on screen for eye calibration for dichoptic
% paradigms
clear all; 
xconstant = 0; 

% extract screen info from TrialRecord
fig = findobj('tag', 'xycalibrate');
BasicData = get(fig, 'userdata');

ScreenInfo = BasicData.ScreenInfo;
pixperdeg   = ScreenInfo.PixelsPerDegree;

bg_color    = [0.5 0.5 0.5]; %ScreenInfo.BackgroundColor; 
cr_color    = [0 0 0]; 

xpix  = ScreenInfo.Xsize; 
ypix  = ScreenInfo.Ysize; 

xdegs = xpix/pixperdeg; 
ydegs = ypix/pixperdeg; 

% find center points on each half of screen 
xRC = xdegs/4; 
yRC = 0; 

int = 5; 
y = [5:-int:-5];
x = y + xRC;
x = x (x>0);
x = [x (x.*-1)]; 
tl = combvec(x,y); 
c = [xRC -xRC; 0 0]; 
new_targetlist = [c tl]; 
 
% only right eye 
rightlist = new_targetlist(:,find(new_targetlist(1,:)>0)); 

% only left eye
leftlist  = new_targetlist(:,find(new_targetlist(1,:)<0)); 

clearvars -except rightlist leftlist new_targetlist