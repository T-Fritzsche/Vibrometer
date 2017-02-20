function [iVelocityResSett]=determineBestVibrometerRange(sVibrometer)
    VeloSettingsString=['VELO5';'VELO1';'VELO2';'VELO3';'VELO4'];
    VelocityResNr=[2,3,4,5,1]; %turn it in the 'real'
    iVelocityResSett=VelocityResNr(str2double(query(sVibrometer,'VELO?')));
    if str2double(query(sVibrometer,'OVR'))==1
        %the current value is out of range. so we stepwise
        %increase the velo per div until it IS back in range
        stilOutOfRange = true;
        while stilOutOfRange&&(iVelocityResSett<length(VelocityResNr)) %either not in range or we can't go higher
            iVelocityResSett=iVelocityResSett+1;
            %set and verify the new range
            while VelocityResNr(str2double(query(sVibrometer,'VELO?')))~=iVelocityResSett
                fprintf(sVibrometer,VeloSettingsString(iVelocityResSett,:));
                pause(0.2)
            end
            pause(2);
            stilOutOfRange=str2double(query(sVibrometer,'OVR'));
        end

    else
        %the current value is IN of range. so we stepwise
        %decrease the velo per div until it is outside of range
        %and take the previous value
        stillInRange=true;
        while stillInRange && (iVelocityResSett > 1)
            iVelocityResSett=iVelocityResSett-1;
            while VelocityResNr(str2double(query(sVibrometer,'VELO?')))~=iVelocityResSett
                fprintf(sVibrometer,VeloSettingsString(iVelocityResSett,:));
                pause(0.2)
            end
            pause(2);
            stillInRange=~(str2double(query(sVibrometer,'OVR')));
        end
        if ~stillInRange 
            %set previous working settings
            iVelocityResSett=iVelocityResSett+1;
            %set and verify the new range
            while VelocityResNr(str2double(query(sVibrometer,'VELO?')))~=iVelocityResSett
                fprintf(sVibrometer,VeloSettingsString(iVelocityResSett,:));
                pause(0.2)
            end
            pause(2);
        end
    end
    pause(0.5);
    iVelocityResSett=VelocityResNr(str2double(query(sVibrometer,'VELO?')));
end