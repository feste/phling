function [] = superballs()

% to do: 
%   switch colors when they pass going towards each other (vertical)
%   center no-cause balls
%   spacebar to record segmentations
%	run multiple displays, one after the other (multiple trials in experiment)

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
      
      velocity = 3;
      radius = 40;
      gap = 0;
      delayBeforeStart = 10;
      
      offset = 40;
      
      nframes = 500; % number of animation frames in loop
      
      
      %***************PUT TRIAL INFORMATION HERE***********************
      %this can be made random later.  maybe we can make a function for
      %generating trials
      trials = {0, 'cause', red, blue;
          0, 'reverse', white, green};
      %***************END TRIAL INFORMATION****************************

      numtrials = size(trials,1);  
      for t=1:numtrials
          lag = trials{t,1};
          cond = trials{t,2};
          col1 = trials{t,3};
          col2 = trials{t,4};
      littleballs(doublebuffer, ifi, w, nframes, offset, vertbound, horizbound, vbl, center, ...
          waitframes, lag, gap, cond, delayBeforeStart, velocity, radius, col1, col2);
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