function [] = balls(lag, gap, cond, delay, speed, radius, color1, color2)

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

  % Check number of inputs.
  if nargin > 8
    error('myfuns:somefun2:TooManyInputs', ...
        'lag, speed, radius');
  end
  
  % Fill in unset optional values.
  switch nargin
      case 0
          lag = 0;
          gap = 0;
          cond = 'cause';
          delay = 50;
          speed = 3;
          radius = 40;
          color1 = 'red';
          color2 = 'blue';
      case 1
          gap = 0;
          cond = 'cause';
          delay = 50;
          speed = 3;
          radius = 40;
          color1 = 'red';
          color2 = 'blue';
      case 2
          cond = 'cause';
          delay = 50;
          speed = 3;
          radius = 40;
          color1 = 'red';
          color2 = 'blue';
      case 3
          delay = 50;
          speed = 3;
          radius = 40;
          color1 = 'red';
          color2 = 'blue';
      case 4
          speed = 3;
          radius = 40;
          color1 = 'red';
          color2 = 'blue';
      case 5
          radius = 40;
          color1 = 'red';
          color2 = 'blue';
      case 6
          color1 = 'red';
          color2 = 'blue';
      case 7
          color2 = 'blue';
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
      
      switch color1
          case 'blue'
              col1 = blue;
          case 'green'
              col1 = green;
          case 'red'
              col1 = red;
          case 'white'
              col1 = white;
      end
      
      switch color2
          case 'blue'
              col2 = blue;
          case 'green'
              col2 = green;
          case 'red'
              col2 = red;
          case 'white'
              col2 = white;
      end
      
      offset = 40;
      
      %vertical versus horizontal
      switch cond
          case 'cause'
             firstBallStart = [-horizbound, 0];
             secondBallStart = [offset,0];
            change = [speed; 0; speed; 0];
          case 'vert'
              firstBallStart = [0,-vertbound];
              secondBallStart = [0,offset];
              change = [0; speed; 0; speed];
          case 'vert-switch'
              firstBallStart = [0,-vertbound];
              secondBallStart = [0,offset];
              change = [0; speed; 0; speed];
          case 'no-cause'
              firstBallStart = [-horizbound, -vertbound];
              secondBallStart = [horizbound,0];
              change = [speed; 0; speed; 0];
          case 'reverse'
              firstBallStart = [-horizbound, 0];
              secondBallStart = [horizbound,0];
              change = [speed; 0; speed; 0];
              cond = 'no-cause';
      end
      
      nframes = 600; % number of animation frames in loop
      
      firstBallCoord = getCoord(center, firstBallStart, radius);
      secondBallCoord = getCoord(center, secondBallStart, radius);
      ghostSecondBallCoord = getCoord(center, [offset,0], radius);
      
      Screen('FillOval', w, uint8(col1), firstBallCoord);
      Screen('FillOval', w, uint8(col2), secondBallCoord);
      Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')

      vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
      KbStrokeWait;
      
      hasHit = false;
      lagCounter = 0;
      justHit = 2;
      
      %waituntilspacepress;
      % --------------
      % animation loop
      % --------------
      for i = 1:nframes
          if (i>0)
              noCause = strcmp(cond, 'no-cause');
              %vertSwitch = strcmp(cond, 'vert-switch');
              beforeMidPoint = abs(secondBallCoord(1) - ghostSecondBallCoord(1)) < speed;
              inBounds = inbounds(secondBallCoord, vertbound, horizbound, center, radius);
              if ~(noCause && beforeMidPoint) && inBounds && (i>delay)
                  if (hasHit == false)
                      firstBallCoord = firstBallCoord + change;
                      vertCond = strcmp(cond, 'vert') || strcmp(cond, 'vert-switch');
                      vertTouch = abs(firstBallCoord(4) - secondBallCoord(2)) < speed + gap;
                      horizTouch = abs(firstBallCoord(3) - ghostSecondBallCoord(1)) < speed + gap;
                      if ((vertCond && vertTouch) || (~vertCond && horizTouch))
                          hasHit = true;
                          justHit = 0;
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
              %if (vertSwitch && justHit == 1)
              %    old1 = col1;
              %    old2 = col2;
              %    col1 = old2;
              %    col2 = old1;
              %end
              justHit = justHit + 1;
              Screen('FillOval', w, uint8(col1), firstBallCoord);
              Screen('FillOval', w, uint8(col2), secondBallCoord);
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