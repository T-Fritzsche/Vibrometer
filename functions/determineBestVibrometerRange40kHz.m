function [iVelocityResSett]=determineBestVibrometerRange40kHz(sVibrometer)
% measures the amplitude of the mechanical response and sets the range of 
% the vibrometer in order to obtain the highes possible resolution. 
% With one of the two available vibrometer analyzers (OFV 3001), only some of
% the ranges can be used above 20kHz. So this function limits the available
% range for frequencys above 20kHz.
%%this function only uses the values which can be measured above 20kHz
vMIN=2; %first entry of VeloSettingsString that may be used
vMAX=4; %last entry of VeloSettingsString that may be used
    VeloSettingsString=['VELO5';'VELO1';'VELO2';'VELO3';'VELO4'];
    VelocityResNr=[2,3,4,5,1]; %turn it in the 'real'
    iVelocityResSett=VelocityResNr(str2double(query(sVibrometer,'VELO?')));
    if str2double(query(sVibrometer,'OVR'))==1
        %the current value is out of range. so we stepwise
        %increase the velo per div until it IS back in range
        stilOutOfRange = true;
        while stilOutOfRange&&(iVelocityResSett<vMAX) %either not in range or we can't go higher
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
        while stillInRange && (iVelocityResSett > vMIN)
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
