function [] = balls(lag, cond, speed, radius)

% to do: 
%   switch colors when they pass going towards each other (vertical)
%   color options so first and second balls can have colors switched
%   ****beginning: dots stable.  then move on space press.
%   

% lag is the number of frames for the lag in between balls moving.
% cond is the condition.  so far i have made the conditions 'cause',
%   'no-cause', and 'vert'.
% speed and radius are optional arguments for the disks.

  % Check number of inputs.
  if nargin > 4
    error('myfuns:somefun2:TooManyInputs', ...
        'lag, speed, radius');
  end
  
  % Fill in unset optional values.
  switch nargin
      case 2
          speed = 5;
          radius = 100;
      case 3
          radius = 100;
  end

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
      
      %vertical versus horizontal
      if strcmp(cond, 'cause')
          firstBallStart = [-horizbound, 0];
          secondBallStart = [0,0];
          change = [speed; 0; speed; 0];
      elseif strcmp(cond, 'vert')
          firstBallStart = [0,-vertbound];
          secondBallStart = [0,0];
          change = [0; speed; 0; speed];
      elseif strcmp(cond, 'no-cause')
          firstBallStart = [-horizbound, -vertbound];
          secondBallStart = [horizbound,0];
          change = [speed; 0; speed; 0];
      end
      
      nframes = 600; % number of animation frames in loop
      
      firstBallCoord = getCoord(center, firstBallStart, radius);
      secondBallCoord = getCoord(center, secondBallStart, radius);
      ghostSecondBallCoord = getCoord(center, [0,0], radius);
      
      hasHit = false;
      lagCounter = 0;
      
      % --------------
      % animation loop
      % --------------
      for i = 1:nframes
          if (i>10)
              noCause = strcmp(cond, 'no-cause');
              beforeMidPoint = abs(secondBallCoord(1) - ghostSecondBallCoord(1)) < speed;
              inBounds = inbounds(secondBallCoord, vertbound, horizbound, center, radius);
              if ~(noCause && beforeMidPoint) && inBounds
                  if (hasHit == false)
                      firstBallCoord = firstBallCoord + change;
                      vertCond = strcmp(cond, 'vert');
                      vertTouch = abs(firstBallCoord(4) - secondBallCoord(2)) < speed;
                      horizTouch = abs(firstBallCoord(3) - ghostSecondBallCoord(1)) < speed;
                      if ((vertCond && vertTouch) || (~vertCond && horizTouch))
                          hasHit = true;
                      end
                  else
                      lagCounter = lagCounter + 1;
                      if (lagCounter > lag)
                          if strcmp(cond, 'no-cause')
                              secondBallCoord = secondBallCoord - change;
                          else
                              secondBallCoord = secondBallCoord + change;
                          end
                      end
                  end
              end
              Screen('FillOval', w, uint8(red), firstBallCoord);
              Screen('FillOval', w, uint8(blue), secondBallCoord);
              Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
          end;
          [mx, my, buttons]=GetMouse(screenNumber);
          if KbCheck | any(buttons) % break out of loop
              break;
          end;
          if (doublebuffer==1)
              vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
          end;
      end
      
      waituntilspacepress
      
      Priority(0);
      ShowCursor
      Screen('CloseAll');
  catch
      Priority(0);
      ShowCursor
      Screen('CloseAll');
      fprintf('you are in catch now\n');
  end
end

function coordinates = getCoord(center, ball_coord, radius)
  coordinates = [center(1) + ball_coord(1) - radius;
                 center(2) + ball_coord(2) - radius;
                 center(1) + ball_coord(1) + radius;
                 center(2) + ball_coord(2) + radius];
end

function bool = inbounds(coord, vertbound, horizbound, center, radius)

  rightbound = -horizbound + center(1);
  leftbound = horizbound + center(1);
  topbound = -vertbound + center(2);
  bottombound = vertbound + center(2);
  
  right = coord(1) + radius >= rightbound;
  left = coord(3) - radius <= leftbound;
  top = coord(2) + radius >= topbound;
  bottom = coord(4) - radius <= bottombound;
  
  bool = right && left && top && bottom;
end