% do nothing until the spacebar is pressedwhile 1	[keyIsDown,secs,keyCode] = KbCheck;        if keyIsDown             if strcmp('space',KbName(keyCode)),                break;            end        endend