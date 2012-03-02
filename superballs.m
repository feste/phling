function [] = superballs(subjectNo)

% to do:
%   switch colors when they pass going towards each other (vertical)
%   center no-cause balls
%   spacebar to record segmentations

% delay is number of frames before movement starts
% gap is the number of pixels that separate the balls
% color1 and color2 options are 'red', 'blue', 'green', and 'white'
% lag is the number of frames for the lag in between balls moving.
% cond is the condition.  so far i have made the conditions 'cause',
%   'no-cause', and 'vert'.
% speed and radius are optional arguments for the disks.

AssertOpenGL;
try
    waitframes = 1;
    doublebuffer=1;
    screens=Screen('Screens');
    screenNumber=max(screens);
    fix_r = 10; % radius of fixation point (pixels)
    
    [w, rect] = Screen('OpenWindow', screenNumber, 0,[], 32, doublebuffer+1);
    
    % Enable alpha blending with proper blend-function. We need it
    % for drawing of smoothed points:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [center(1), center(2)] = RectCenter(rect);
    fps=Screen('FrameRate', w);      % frames per second
    ifi=Screen('GetFlipInterval', w);
    if fps==0
        fps=1/ifi;
    end;
    
    black = BlackIndex(w);
    white = WhiteIndex(w);
    red = [255 0 0];
    blue = [0 0 255];
    green = [0 255 0];
    HideCursor;	% Hide the mouse cursor
    Priority(MaxPriority(w));
    
    % Do initial flip...
    vbl=Screen('Flip', w);
    
    vertbound = 300;
    horizbound = 500;
    
    screenResWidth = 1440;
    screenWidth = 28.575;
    %screenWidth = 36.83;
    speed_cmps = 40;
    %speed_cmps = 5;
    
    velocity = speed_cmps*(1/fps)*(screenResWidth / screenWidth);
    radius = 40;
    gap = 0;
    delayBeforeStart = 10;
    
    offset = 40;
    
    nframes = 1230/velocity + delayBeforeStart; % number of animation frames in loop
    
    instructions(w);
    
    %causeTrialsPerLag = 10;
    causeTrialsPerLag = 0;
    reverseTrialsPerLag = 10;
    %reverseTrialsPerLag = 0;
    
    %***************PUT TRIAL INFORMATION HERE***********************
    %fprintf('starting to initialize trials')
    lags = [30 50 70 90 110 130 150 170];
    %lags = [30];
    lags = (lags / 1000) * fps;
    ntrials = length(lags) * (causeTrialsPerLag + reverseTrialsPerLag);
    %trials = cell(causeTrialsPerLag * reverseTrialsPerLag, 4);
    trials = cell(ntrials, 4);
    c = 1;
    for lag=lags
        for i=1:causeTrialsPerLag  %cause: 5 trials per lag 
            trials{c, 1} = lag;
            trials{c, 2} = 'cause';
            trials{c, 3} = red;
            trials{c, 4} = blue;
            c = c + 1;
        end
        for i=1:reverseTrialsPerLag   %reverse: 3 trials per lag
            trials{c, 1} = lag;
            trials{c, 2} = 'reverse';
            trials{c, 3} = red;
            trials{c, 4} = blue;
            c = c + 1;
        end
    end
    trials = trials(randperm(length(trials)),:);
    %***************END TRIAL INFORMATION****************************
    
    %dataFile=fopen(sprintf('data.txt'),'a');
    %fprintf(dataFile, 'subj\tdisplay\tlag\tcause\tdate');
    numtrials = size(trials,1);
    for t=1:numtrials
        lag = trials{t,1};
        cond = trials{t,2};
        col1 = trials{t,3};
        col2 = trials{t,4};
        fprintf('about to call littleballs for trial %i\n', t)
        littleballs(subjectNo, doublebuffer, ifi, w, nframes, offset, ...
            vertbound, horizbound, vbl, center, waitframes, lag, gap, ...
            cond, delayBeforeStart, velocity, radius, col1, col2);
    end
    
    waituntilspacepress
    
    Priority(0);
    ShowCursor;
    Screen('CloseAll');
catch
    Priority(0);
    ShowCursor;
    Screen('CloseAll');
end
end

function [] = instructions(w)
%if ~IsLinux
    Screen('TextFont',w,'Arial');
    Screen('TextSize',w,24);
%end
white = WhiteIndex(w);
right = 270;
top = 180;
step = 40;
Screen('DrawText', w, 'Hello!  Thank you for participating in this experiment. You will be ',right,top,white);
Screen('DrawText', w, 'presented with displays involving some action.  For each display, ',right,top+step,white);
Screen('DrawText', w, 'please rate the extent to which you agree with the following statement.',right,top+step*2,white);
Screen('TextSize', w, 36);
Screen('DrawText', w, '     The movement of the red ball caused the movement of the blue ball.',right - 150,top+step*5,white);
Screen('TextSize', w, 14);
Screen('DrawText', w, 'strongly disagree                      disagree                  somewhat disagree         neighter agree nor disagree         somewhat agree                    agree                         strongly agree',right - 150,top+step*8,white);
Screen('TextSize', w, 24);
Screen('DrawText', w, '1                       2                       3                       4                       5                       6                       7',right - 100,top+step*9,white);
Screen('DrawText', w, 'Press any key to begin.',right,top+step*12,white);
Screen('Flip', w);
% Wait for keypress
pause(1);
KbWait;
Screen('Flip', w);
go=1;
end
