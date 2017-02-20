%% Measure the Velocity over frequency at one point
% This is a hack'ish program which controls all the devices and does a
% frequency sweep at the current position in order to get the mechanical
% response. Actually it would be nice to integrate this functionality into the
% 'main' program.

%% Set the nessecary values
freq=linspace(44,48,100);
%freq=20:0.1:100;
Settings.FGen.Vpp=1;
MSValues=NaN(length(freq),5); %space for freq, amp, vel amp, res, phase

numOfValues=5;
MSCell=cell(1,numOfValues);
for j=1:numOfValues
    MSCell{j}.Voltage=j*2;
end



%% Set the device options
ErrorValue=9.9E+37;
VelocityRes=[1,5,25,125,1000]; %corrects sorting of velocity values of vibrometer
VelocityResNr=[2,3,4,5,1]; %turn the weird numbering of the vibrometer into a compatible to 'VelocityRes'
for j=1:numOfValues
    MSValues(:,1)=freq';
    Settings.FGen.Vpp=MSCell{j}.Voltage;
    UperDiv=0.5+Settings.FGen.Vpp/10;
    fprintf(visaOszi,[':CHAN2:SCAL ' num2str(UperDiv) 'V']);
    for i=1:length(freq)
        %% Configure the Function Generator
        %set frequency, voltage from settings. Offset is 0, and channel is 1
         fprintf(sFG,['SOUR1:APPL:SIN ' num2str(MSValues(i,1)) 'KHZ,' num2str(Settings.FGen.Vpp) ',0']);
         pause(0.5);
        operationComplete = str2double(query(sFG,'*OPC?'));
        while ~(operationComplete==1)
            operationComplete = str2double(query(sFG,'*OPC?'));
             pause(0.01);
        end
        fprintf(sFG,'SYST:LOC'); %allow the user to change the settings afterwards

        %let the oszi run and wait until the transducer is used to the new
        %frequency
    %     fprintf(visaOszi,':RUN');
        pause(4);
    %     fprintf(visaOszi,':STOP');
    %     pause(0.3);


        % Measure Oszi
            fprintf(visaOszi,':DIGitize');
            operationComplete = str2double(query(visaOszi,'*OPC?'));
            while ~operationComplete
                operationComplete = str2double(query(visaOszi,'*OPC?'));
            end
             iVelocityRes=VelocityRes(VelocityResNr(str2double(query(sVibrometer,'VELO?')))); %the range will be saved as 1,5,125,1000 [mm/V] 
            %Get the data
             iVpp1= str2double(query(visaOszi,':MEASure:VPP? CHAN1'));
             iVpp2= str2double(query(visaOszi,':MEASure:VPP? CHAN2'));
             iPhaseShift=str2double(query(visaOszi,':MEASure:PHASe? CHAN2,CHAN1'));
             ifreq= str2double(query(sFG,'SOUR1:FREQ?')); %save the value of the actual frequency
             %the vibrometer has a time delay which is depending on the
            %resolution. To correct this, we change the phaseshift
            %accordingly
            if ~(isnan(iPhaseShift) ||iPhaseShift>=ErrorValue)
                switch iVelocityRes
                    case 1
                        tDelay=23.9E-06;
                    case 5
                        tDelay=7.7E-06;
                    case 25
                        tDelay=6E-06;
                    case 125
                        tDelay=6E-06;
                    case 1000
                        tDelay=5.2E-06;
                end
                iPhaseShiftCorrected=iPhaseShift-360*tDelay*ifreq; %remove delay
                iPhaseShift=wrapTo180(iPhaseShiftCorrected); %map to 180deg
            else
                iPhaseShift=NaN;
            end
            %save the data
             MSValues(i,1)= ifreq; %save the value of the actual frequency
             MSValues(i,2)= iVpp1/2;
             MSValues(i,3)= iVpp2/2;
             MSValues(i,4)= iVelocityRes;
             MSValues(i,5)= iPhaseShift;
        disp(['Measures f=' num2str(MSValues(i,1)) ' kHz, Vpp=' num2str(MSValues(i,3)), 'V, Phase=', num2str(MSValues(i,5))]);
    end
    MSCell{j}.MSValues=MSValues;
end

%% Auswertung

MSValues(:,6)=MSValues(:,3).*MSValues(:,4); %_--> velocity in [mm/s]
MSValues(:,7)=(MSValues(:,3)).*(MSValues(:,4)) ./(2*pi.*(MSValues(:,1)/1000)); %--> displacement in [um]

for j=1:numOfValues
    MSCell{j}.MSValues(:,6)=MSCell{j}.MSValues(:,3).*MSCell{j}.MSValues(:,4); %_--> velocity in [mm/s]
    MSCell{j}.MSValues(:,7)=(MSCell{j}.MSValues(:,3)).*(MSCell{j}.MSValues(:,4)) ./(2*pi.*(MSCell{j}.MSValues(:,1)/1000)); %--> displacement in [um]
end 
figure
for j=1:numOfValues
    MSValues=MSCell{j}.MSValues;
    freq=MSValues(:,1);disp=MSValues(:,7);phase=MSValues(:,5);
    hold on
    plotyy(freq,disp,freq,phase);
    hold on
end
    
