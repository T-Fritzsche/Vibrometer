function[]=moveStageTo(sAxis,PosX, PosY)
% moves the transducer to the specified position and waits until the 
% stage has reached it.
%
    if ~(isnan(PosX)||isnan(PosY)) %check for NaN as wrong values
        fprintf(sAxis, ['MVP ABS, 0, ' num2str(PosX)]);
        pause(0.1);
        fprintf(sAxis, ['MVP ABS, 1, ' num2str(PosY)]);
        pause(0.3);
        fprintf(sAxis,'MVP REL, 2, 0');
        %wait until they get there
        [ sAxisPos.x, sAxisPos.y, sAxisPos.z] = getStagePosition(sAxis);
        while ((sAxisPos.x ~= PosX)||(sAxisPos.y ~= PosY))
            fprintf(sAxis, ['MVP ABS, 0, ' num2str(PosX)]);
            fprintf(sAxis, ['MVP ABS, 1, ' num2str(PosY)]);
            pause(0.3);
            [ sAxisPos.x, sAxisPos.y, sAxisPos.z] = getStagePosition(sAxis);
        end
    else
        return
    end
end
