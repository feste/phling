%**************************************************************************
%%%%%%%%%%%%%%%%%%%% MAIN FUNCTION FOR EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%
%**************************************************************************

function [] = physalis(cond, subjNo)

% conditions:
%   A - push, transitive
%   B - gorp, transitive
%   C - touch, intransitive
%   D - gorp, intransitive

% unless stated otherwise, measurements are in pixels and frames.

% psychtoolbox initialization stuff
[w, rect] = Screen('OpenWindow', max(Screen('Screens')), 0,[], 32, 2);
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;	% Hide the mouse cursor
Priority(MaxPriority(w));

% some properties of the screen
width = rect(3);
%height = rect(4);
[center(1), center(2)] = RectCenter(rect);
fps = getFPS(w);
cmWidth = 28.575; %actual measurement of the screen in cm
%cmWidth = 36.83 %which screen is this? is this rm K?

% my variables
percentScreen = 80;
speed_cmps = 40;
radius = 40; %THIS IS NOT RELATIVE TO SCREEN SIZE!!!!!!

% variable computations
%vertBound = round(height * percentScreen / 200);
horizBound = round(width * percentScreen / 200);
ppcm = width / cmWidth; %pixels per cm
cmpp = cmWidth / width; %cm per pixel
speed = round(speed_cmps*(1/fps)*ppcm); %pixels per frame ROUNDED

% Do initial flip...
Screen('Flip', w);

instructions(cond, w);  %play instructions on the screen

%%%%%%% experiment parameters %%%%%%%%%%
msLags = 0:50:200;
cmGaps = 0:0.5:2;
trialsPerCond = 10; %number of trials for each lag-gap pairing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make a cell array with one row for every lag-gap pairing
c=1;
ntrials = length(msLags) * trialsPerCond;
trials = cell(ntrials, 2);
for msLag=msLags
    for cmGap=cmGaps
        for i=1:trialsPerCond
            trials{c,1} = msLag;
            trials{c,2} = cmGap;
            c = c + 1;
        end
    end
end

%put trials in random order
trials = trials(randperm(length(trials)),:);

%%%%% run the experiment and record data %%%%%
dataFile=fopen(sprintf('data.txt'),'a');
timeStart = getTime();
%data = cell(ntrials, 1);
%responses = cell(ntrials, 1);
for t=1:length(trials)
    msLag = trials{t,1};
    cmGap = trials{t,2};
    pGap = round(cmGap * ppcm); % gap in pixels ROUNDED
    fLag = round((msLag / 1000) * fps); % lag in frames ROUNDED
    
    runAnimation(fLag, pGap, radius, speed, w, horizBound, center);
    
    %get and record participant's response
    response = getResponse(w);
    fprintf(dataFile, '\n%i\t%s\t%i\t%i\t%i\t%s\t%s', subjNo, cond, t, ...
        msLag, cmGap, response, timeStart);
    %responses{t} = response;
end
fclose(dataFile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

closing(w);

Priority(0);
ShowCursor;
Screen('CloseAll');

end

%**************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**************************************************************************


%**************************************************************************
%%%%%%%%%%%%%%%%%% subparts of the experiment called %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% from main physalis function %%%%%%%%%%%%%%%%%%%%%%%%%
%**************************************************************************

function [] = instructions(cond, w)
%presents instruction screen for experiment using psychtoolbox tools.
%this function presupposes that there is a window (w) open with 
%psychtoolbox Screen
Screen('TextFont',w,'Arial');
Screen('TextSize',w,24);
white = WhiteIndex(w);
top = 180;
step = 40;
switch cond
    case 'A'
        sentence = 'The red ball pushed the blue ball.';
    case 'B'
        sentence = 'The red ball gorped the blue ball.';
    case 'C'
        sentence = 'The red ball and the blue ball touched.';
    case 'D'
        sentence = 'The red ball and the blue ball gorped.';
end
intro = ['Hello!  Thank you for participating in this experiment. You' ...
	' will be presented with displays involving some action.  For each' ...
	' display, please say whether the following statement is correct.'];
responseInfo = 'F means yes                         J means no';
DrawFormattedText(w, intro, 'center', top+step*3, white, 70);
Screen('TextSize', w, 36);
DrawFormattedText(w, sentence, 'center', 'center', white);
Screen('TextSize', w, 24);
DrawFormattedText(w, responseInfo, 'center', top+step*9, white);
DrawFormattedText(w, 'Press any key to begin.', 'center', top+step*12, white);
Screen('Flip', w);
% Wait for keypress
pause(1);
KbWait;
Screen('Flip', w);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = runAnimation(fLag, pGap, radius, speed, w, horizBound, ...
    center)
%display animation for a trial of physalis

%nframes = (horizBound*2)/speed; % number of animation frames in loop
delayBeforeQuestion = 10;
change = [speed; 0; speed; 0];

%initial ball positions
firstBallStart = [-horizBound, 0];
secondBallStart = [0,0];
firstBallCoord = getCoord(center, firstBallStart, radius);
secondBallCoord = getCoord(center, secondBallStart, radius);

red = [255 0 0];
blue = [0 0 255];
white = WhiteIndex(w);
Screen('FillOval', w, uint8(red), firstBallCoord);
Screen('FillOval', w, uint8(blue), secondBallCoord);
Screen('DrawText', w, 'Press any button to continue.', 540, 300, white);
Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')

%vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
Screen('Flip', w);
KbStrokeWait;

lagCounter = 0;
ball2Start = false;

% --------------
% animation loop
% --------------
inBounds = true;
while inBounds
    currentGap = abs(firstBallCoord(3) - secondBallCoord(1));
    %i say "closeEnough" when the first ball has reached as far as it plans
    %to go (i.e. is exactly as far away from the second ball as the gap for
    %this trial)
    closeEnough = (currentGap == pGap);
    almostCloseEnough = currentGap < speed + pGap;
    inBounds = inbounds(secondBallCoord, horizBound, center, radius);
    if closeEnough
        if lagCounter > fLag
            %second ball moves
            secondBallCoord = secondBallCoord + change;
            ball2Start = true;
        end
        lagCounter = lagCounter + 1;
    elseif almostCloseEnough
        %first ball moves to touch second ball
        changeToTouch = (currentGap - pGap)*[1 0 1 0]';
        firstBallCoord = firstBallCoord + changeToTouch;
    elseif ball2Start
        %second ball moves
        secondBallCoord = secondBallCoord + change;
    else
        %first ball moves
        firstBallCoord = firstBallCoord + change;
    end
    Screen('FillOval', w, uint8(red), firstBallCoord);
    Screen('FillOval', w, uint8(blue), secondBallCoord);
    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('Flip', w);
end

for i = 1:delayBeforeQuestion
    Screen('FillOval', w, uint8(red), firstBallCoord);
    Screen('FillOval', w, uint8(blue), secondBallCoord);
    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('Flip', w);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function response = getResponse(w)
% show response screen and get response from participant
white = WhiteIndex(w);
Screen(w,'fillrect',0);
Screen('TextSize', w, 32);
responseInfo = ['F                               J\n' ...
                'Yes                            No'];
DrawFormattedText(w, responseInfo, 'center', 'center', white);
Screen('Flip',w);

% Wait for the user to input something meaningful
inLoop=true;
f = KbName('f');
j = KbName('j');
while inLoop
    [keyIsDown, ~, keyCode]=KbCheck;
    if keyIsDown
        code = find(keyCode);
        if code == f
                inLoop=false;
                response = '+';
        elseif code == j
                inLoop=false;
                response = '-';
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = closing(w)
%presents closing screen for experiment using psychtoolbox tools.
%this function presupposes that there is a window (w) open with 
%psychtoolbox Screen
Screen('TextFont',w,'Arial');
Screen('TextSize',w,24);
white = WhiteIndex(w);
closing = ['Thank you for your participation.\n\nPlease let the ' ...
    'experimenter know that you have finished.'];
DrawFormattedText(w, closing, 'center', 'center', white);
Screen('Flip', w);
% Wait for keypress
pause(1);
KbWait;
Screen('Flip', w);
end


%**************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**************************************************************************


%**************************************************************************
%%%%%%%%%%%%%%%%%% little functions called in this file %%%%%%%%%%%%%%%%%%%
%**************************************************************************

function time = getTime()
%grabs the time into a nicely formatted string for the data file
c = clock;
year = num2str(c(1));
month = num2str(c(2));
day = num2str(c(3));
hour = num2str(c(4));
min = num2str(c(5));
time = [year '-' month '-' day ' ' hour ':' min];
end

function fps = getFPS(w)
%gets the frames per second using psychtoolbox tools
fps=Screen('FrameRate', w);      % frames per second
ifi=Screen('GetFlipInterval', w);
if fps==0
    fps=1/ifi;
end;
end

function coordinates = getCoord(center, ball_coord, radius)
%this function tells you what the left-top-right-bottom coordinates of a ball 
%with respect to center are if you only know the x-y coordinates on the screen
%---variables---%
%ball_coord : x-y coordinates of the ball
%center : center of screen
%radius : radius of ball
%---end variables---%
coordinates = [center(1) + ball_coord(1) - radius;
    center(2) + ball_coord(2) - radius;
    center(1) + ball_coord(1) + radius;
    center(2) + ball_coord(2) + radius];
end

function bool = inbounds(coord, horizBound, center, radius)
%checks whether a ball is inside the comfortably viewable window that i
%hardcoded for my laptop's screen
%---variables---%
%coord : coordinates (left, top, right, bottom) of the ball's center
%vertbound : hardcoded max vertical distance from center
%horizbound : hardcoded max horizontal distance from center
%center : found by psychtoolbox, center of screen
%radius : radius of the ball
%---end variables---%

rightBound = -horizBound + center(1);
leftBound = horizBound + center(1);

right = coord(1) + radius >= rightBound;
left = coord(3) - radius <= leftBound;

bool = right && left;
end

%**************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**************************************************************************