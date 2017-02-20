function[LinePlots]=createLinePlot(MeasureStructur,LinePoints)
%% Aufbau:
% LinePlots=[PosXrelToCenter, PosYrelToCenter, max(iYVelocity),
% max(iYDisplacement), arithmetischerAbstandToCenter]


%% default values
ERRORVAL=9.9E+37;
[ixMAX, iyMAX] = size(MeasureStructur);
maxsize=max(ixMAX,iyMAX);
LinePlots=NaN(maxsize,5);
%% evaluate
for i=1:length(LinePoints)
    ix=LinePoints(i,2);
    iy=LinePoints(i,1);
    PosXi=MeasureStructur{iy,ix}.PosX;
    PosYi=MeasureStructur{iy,ix}.PosY;
    LinePlots(i,1)=MeasureStructur{iy,ix}.PosXrelToCenter;
    LinePlots(i,2)=MeasureStructur{iy,ix}.PosYrelToCenter;
    if ~(isnan(PosXi)||isnan(PosYi)) %use only measurement points
        %calculate the velocity from the voltage
        iVResolution = MeasureStructur{iy,ix}.VelocityRes; %resolution is between 1...1000mm/s/V. 
        iYVelocity = MeasureStructur{iy,ix}.YData2 * iVResolution/1000; %Value in [m/s]

        ifreq=MeasureStructur{iy,ix}.Aq3;
        ifreqStimulating=MeasureStructur{iy,ix}.Aq2;

        if (isnan(ifreq) ||ifreq>ERRORVAL)
        ifreq=ifreqStimulating; %take waveform of the stimulation wave if the other isn't readable
        end
        iYDisplacement =iYVelocity /(2*pi*ifreq); %Value in [m]

        %save max and min of velocity and displacement and phase
        LinePlots(i,3)=max(iYVelocity);
        LinePlots(i,4)=max(iYDisplacement); 
        
        if i==1
            LinePlots(i,5)=0;
        elseif isnan(LinePlots(i-1,1)) && isnan(LinePlots(i-1,2))
            LinePlots(i,5)=0;
        else
            LinePlots(i,5)=LinePlots(i-1,5)+sqrt((LinePlots(i,1)-LinePlots(i-1,1))^2+(LinePlots(i,2)-LinePlots(i-1,2))^2);
        end
        if (MeasureStructur{iy,ix}.PhaseShift < ERRORVAL)
            LinePlots(i,6)=MeasureStructur{iy,ix}.PhaseShift;
        else 
            LinePlots(i,6)=NaN;
        end
    end
end
% 5.Zeile auch noch mit Null mittig
[minValue, minPosROW]= min(abs(LinePlots(:,1:2)));
[~,minPosColumn]=min(minValue);
MiddleValue=LinePlots(minPosROW(minPosColumn),5);
LinePlots(:,5)=LinePlots(:,5)-MiddleValue;