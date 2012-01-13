function [] = balls()
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
      HideCursor;	% Hide the mouse cursor
      Priority(MaxPriority(w));
      
      % Do initial flip...
      vbl=Screen('Flip', w);
      
      d1_r = 50;
      pos = -400;
      nframes = 36000; % number of animation frames in loop
      
      d1_left = center(1)+pos-d1_r;
      d1_top = center(2)-d1_r;
      d1_right = center(1)+pos+d1_r;
      d1_bottom = center(2)+d1_r;
      
      d1_cord = [d1_left; d1_top; d1_right; d1_bottom];
      d1_change = [2;0;2;0];
      d2_change = [2;0;2;0];
      d2_cord = [center(1)-d1_r; d1_top; center(1)+d1_r; d1_bottom];
      
      has_hit = false;
      
      % --------------
      % animation loop
      % --------------
      for i = 1:nframes
          if (i>1)
               if (has_hit == false)
                   d1_cord = d1_cord + d1_change;
                   if (d1_cord(3) == d2_cord(1))
                       has_hit = true;
                   end
               else
                   d2_cord = d2_cord + d2_change;
               end
              Screen('FillOval', w, uint8(white), d1_cord);
              Screen('FillOval', w, uint8(white), d2_cord);
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