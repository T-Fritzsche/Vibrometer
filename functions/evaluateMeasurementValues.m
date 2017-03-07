function[PlotX,PlotY,PlotZPhase,PlotZDisplacement,PlotZVelocity,PlotZ_t,overview]= evaluateMeasurementValues(MeasurementValues)
% this function uses the obtained waveforms and creates 'surf' plots for
% displacement, velocity, the phase shift between voltage excitation and the
% mechanical response and the time-dependent displacment/velocity.

ERRORVAL=9.9E+37;

[iyMAX, ixMAX] = size(MeasurementValues);
%overview=NaN(numel(MeasurementValues),15);
ifreqAverage=1; %initialize it
k=1;
for ix=1:ixMAX
    for iy=1:iyMAX
        PosXi=MeasurementValues{iy,ix}.PosX;
        PosYi=MeasurementValues{iy,ix}.PosY;
        if ~(isnan(PosXi)||isnan(PosYi)||(MeasurementValues{iy,ix}.Aq3==ERRORVAL)) %use only measurement points
            ifreqAverage(k)=MeasurementValues{iy,ix}.Aq3;
            k=k+1;
        end
    end
end
freqAverage=mean(ifreqAverage);

i=1;
for ix=1:ixMAX
    for iy=1:iyMAX
        PosXi=MeasurementValues{iy,ix}.PosX;
        PosYi=MeasurementValues{iy,ix}.PosY;
        if ~(isnan(PosXi)||isnan(PosYi)) %use only measurement points
            %as in overview file
            %fprintf(fileOV,'ix\t iy\t PosX\t PosY\t PosXrelToCenter\t PosYrelToCenter\t PhaseShift\t VoltsPerDiv1\t VoltsPerDiv2\t SecPerDiv\t Points\t');
            overview(i,1)=ix;
            overview(i,2)=iy;
            overview(i,3)=MeasurementValues{iy,ix}.PosX;
            overview(i,4)=MeasurementValues{iy,ix}.PosY; 
            overview(i,5)=MeasurementValues{iy,ix}.PosXrelToCenter;
            overview(i,6)=MeasurementValues{iy,ix}.PosYrelToCenter;       
            overview(i,7)=MeasurementValues{iy,ix}.PhaseShift;

            %calculate the velocity from the voltage
            VResolution = MeasurementValues{iy,ix}.VelocityRes; %resolution is between 1...1000mm/s/V. 
            MeasurementValues{iy,ix}.YVelocity = MeasurementValues{iy,ix}.YData2 * VResolution/1000; %Value in [m/s]

            ifreq=MeasurementValues{iy,ix}.Aq3;
            ifreqStimulating=MeasurementValues{iy,ix}.Aq2;

            if (isnan(ifreq) ||ifreq>=ERRORVAL)
                if ifreqStimulating~=ERRORVAL
                    ifreq=ifreqStimulating; %take waveform of the stimulation wave if the other isn't readable
                end
            else
                 ifreq=freqAverage;
            end
            %the vibrometer has a time delay which is depending on the
            %resolution. To correct this, we change the phaseshift
            %accordingly
            iPhaseShift=MeasurementValues{iy,ix}.PhaseShift;
            if ~(isnan(iPhaseShift) ||iPhaseShift>=ERRORVAL)
                switch MeasurementValues{iy,ix}.VelocityRes
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
                    otherwise
                        tDelay=6E-06;
                      
                end
                iPhaseShift=MeasurementValues{iy,ix}.PhaseShift;
                iPhaseShiftCorrected=iPhaseShift-360*tDelay*ifreq; %remove delay
                iPhaseShiftCorrected=wrapTo180(iPhaseShiftCorrected); %map to 180deg
                MeasurementValues{iy,ix}.PhaseShift=iPhaseShiftCorrected; %save the corrected value
                overview(i,7)=iPhaseShiftCorrected; 
            end
            
            MeasurementValues{iy,ix}.YDisplacement =MeasurementValues{iy,ix}.YVelocity /(2*pi*ifreq); %Value in [m]

            %save max and min of velocity and displacement
            overview(i,12)=max(MeasurementValues{iy,ix}.YVelocity);
            MeasurementValues{iy,ix}.iYVelocityMAX=max(MeasurementValues{iy,ix}.YVelocity);
            overview(i,13)=min(MeasurementValues{iy,ix}.YVelocity);
            MeasurementValues{iy,ix}.iYVelocityMIN=min(MeasurementValues{iy,ix}.YVelocity);
            overview(i,14)=max(MeasurementValues{iy,ix}.YDisplacement);
            MeasurementValues{iy,ix}.iYDisplacementMAX=max(MeasurementValues{iy,ix}.YDisplacement);
            overview(i,15)=min(MeasurementValues{iy,ix}.YDisplacement);
            MeasurementValues{iy,ix}.iYDisplacementMIN=min(MeasurementValues{iy,ix}.YDisplacement);
%             overview(i,17)=MeasurementValues{iy,ix}.YDisplacement;
            i=i+1;
        end
    end
end

%% Clean the data and fit it to the use case
%create a unice x and y vector for the surf plot
Xvect=myUnique(overview(:,5)); %unique without NaN
Yvect=myUnique(overview(:,6));

%get the minimum,maximum velocity of whole measure set
velMAX=max(overview(:,12));
velMIN=min(overview(:,13));
displMAX=max(overview(:,14));
displMIN=min(overview(:,15));


%% Animate the Amplitude

%we first obtain the zero-crossing of the actuating sinus wave by
%searching for down crossings of 0
firstColEntry=overview(1,1); %NaN points don't have a sin wave recorded
firstRowEntry=overview(1,2);
x = diff(sign(MeasurementValues{firstRowEntry,firstColEntry}.YData1));
indx_down = find(x<0);
t0_Index=indx_down(1);
t1_Index=indx_down(2);
MaxNumberOfTimePoints=250;
tSteps=ceil((t1_Index-t0_Index)/MaxNumberOfTimePoints);
t=t0_Index:tSteps:t1_Index;
PI4th=round(length(t)/4);
tDisp=[t(3*PI4th:end),t(1:3*PI4th-1)]; %the displacement is shifted by 90deg cause it is the integration of the velocity

%run to all Positions (cell entries {iy,ix}. Then for each of those
%measurement points get the sinus value for every time step between t0 and
%t1 and safe thos values into Zamp{t}. So later on we can sweep through
%Zamp{t} and plot every Amplitude{iy,ix}. Together with surf this will show
%the current velocity value at each time point of the sinusoidal wave.
%Take care of the {iy,ix} which surf requires!
PlotZ_t=cell(length(t),1);
for i=1:length(t)
    PlotZ_t{i,1}.Velocity=NaN(length(Xvect),length(Yvect));     %zeros ixMAX iyMAX
    PlotZ_t{i,1}.Displacement=NaN(length(Xvect),length(Yvect)); %zeros
end
%% Fill the X and Y matrix with Xvect' and Yvect as surf requires

PlotY=Yvect(:,ones(length(Xvect),1));
PlotX=Xvect(:,ones(length(Yvect),1))';
PlotZPhase=NaN(length(Xvect),length(Yvect));
PlotZDisplacement=NaN(length(Xvect),length(Yvect));
PlotZVelocity=NaN(length(Xvect),length(Yvect));


for i=1:1:size(overview,1)
    PosXi=overview(i,5);
    PosYi=overview(i,6);
    Phasei=overview(i,7);
    Displacementi=overview(i,14);
    Velocityi=overview(i,12);
   
    %find the entries of Xi and Yi in X and Y
    %in overview(:,1) and overview(:,2) are positions of the measurement
    %values in the cell MeasurementValues==MSStructure. But those values
    %differ from the x and y values in PloxX,PlotY, Plot* because the plot
    %values do not contain NaN Positions, while the MSStrucure does. So we
    %need to get the index in the Plox* Matrix from the ix,iy in MMStructure
    MSStrctIndex_ix = overview(i,1);
    MSStrctIndex_iy = overview(i,2);
    ColGuessed=MSStrctIndex_ix;
    RowGuessed=MSStrctIndex_iy;
    if (ColGuessed > size(PlotX,2)); ColGuessed = size(PlotX,2); end %check for overflows
    if (ColGuessed < 1 ); ColGuessed = 1; end %check for overflows
    if (RowGuessed > size(PlotX,1)); RowGuessed = size(PlotX,1); end %check for overflows
    if (RowGuessed < 1); RowGuessed = 1; end %check for overflows

    if ((PlotX(RowGuessed,ColGuessed)==PosXi) && (PlotY(RowGuessed,ColGuessed)==PosYi))
        Col=ColGuessed;
        Row=RowGuessed;
    else
      %somehow the order in the matrix got mixed up.. so we're
      %searching by hand...
       Col = find(PlotX(1,:)==PosXi);
       Row = find(PlotY(:,1)==PosYi);

    end
    
    
    PlotZVelocity(Row,Col)=Velocityi;
    PlotZDisplacement(Row,Col)=Displacementi;
    for k=1:length(t)
        %disp(['iy: ' num2str(MSStrctIndex_iy) ' ix: ' num2str(MSStrctIndex_ix) ' k: ' num2str(k) ' t(k): ' num2str(t(k)) ' tDisp(k): ' num2str(tDisp(k))]); %just for debugging
        PlotZ_t{k,1}.Velocity(Row,Col) = MeasurementValues{MSStrctIndex_iy,MSStrctIndex_ix}.YVelocity(t(k));
        PlotZ_t{k,1}.Displacement(Row,Col) = MeasurementValues{MSStrctIndex_iy,MSStrctIndex_ix}.YDisplacement(tDisp(k));    
    end
    
    %check if phase value is not the error of the oszi (9,9E37)
    %this is only nessesary for correct values of the phase
    if Phasei < ERRORVAL
        PlotZPhase(Row,Col)=Phasei;
    else
        PlotZPhase(Row,Col)=NaN;
    end
        
end

%% save the Results to the workspace
MeasurementValues{1,1}.Plot.PlotX=PlotX;
MeasurementValues{1,1}.Plot.PlotY=PlotY;
MeasurementValues{1,1}.Plot.PlotZPhase=PlotZPhase;
MeasurementValues{1,1}.Plot.PlotZDisplacement=PlotZDisplacement;
MeasurementValues{1,1}.Plot.PlotZVelocity=PlotZVelocity;
MeasurementValues{1,1}.Plot.PlotZ_t=PlotZ_t;
MeasurementValues{1,1}.Plot.overview=overview;
assignin('base','MSResults',MeasurementValues);



