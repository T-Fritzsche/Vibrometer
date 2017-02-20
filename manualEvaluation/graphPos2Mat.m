%% If MeasurementValues does not exist. Create it from files.
%defines:
ERRORVAL=9.9E+37;
XEntry=1; %the x-values were written in the first column in the first version. this was later changed to the second entry in order to generate a picture with y-values in colums and x-values in rows. To use the most current verion change to <2> here.
iVelocityRes=25;
%% Gettig the data

ResultDataDir = uigetdir;          %choose woking directory
files = dir(strcat(ResultDataDir,'\graphPos*')); %lists all files starting with graphPos
fileIndex = find(~[files.isdir]); %select only non-folder files in workDirectory
fileCount=size(fileIndex,2); %returns size of the dimension, e.g. number of files

for i = 1:fileCount
    fileName = files(fileIndex(i)).name;
    filePathComplete=strcat(ResultDataDir,'\',fileName);

    expression1= 'graphPos[%d,%d].txt';
    pos = regexp(filePathComplete,'\d+','match');
    ix = str2double(pos(1));
    iy = str2double(pos(2));

    iValues = importdata(filePathComplete);

    MeasurementValues{iy,ix}.XData = iValues(:,1);
    MeasurementValues{iy,ix}.YData1 = iValues(:,2);
    MeasurementValues{iy,ix}.YData2 = iValues(:,3);
end
%find the overview file
fileOverviewPathComplete=strcat(ResultDataDir,'\overview.txt');
overview = importdata(fileOverviewPathComplete);
[sizeY, sizeX]=size(MeasurementValues);

for i=1:length(overview)
    ix=overview(i,1); % x was written in position 2 in later versions!
    iy=overview(i,2); % y was written in position 1 in later versions!
    iPosX=overview(i,3);
    iPosY=overview(i,4);
    MeasurementValues{iy,ix}.PosX=overview(i,3);
    MeasurementValues{iy,ix}.PosY=overview(i,4);
    MeasurementValues{iy,ix}.PhaseShift=overview(i,5);
    MeasurementValues{iy,ix}.Aq4=overview(i,5);
end


%get the middlepoint
iXmiddle=MeasurementValues{ceil(sizeY/2),ceil(sizeX/2)}.PosX;
iYmiddle=MeasurementValues{ceil(sizeY/2),ceil(sizeX/2)}.PosY;
%set PosXYrelToCenter
for ix=1:sizeX
    for iy=1:sizeY
        iPosX=MeasurementValues{iy,ix}.PosX;
        iPosY=MeasurementValues{iy,ix}.PosY;
        if ~(isnan(iPosX)||isnan(iPosY))
            MeasurementValues{iy,ix}.PosXrelToCenter=iPosX-iXmiddle;
            MeasurementValues{iy,ix}.PosYrelToCenter=iPosY-iYmiddle;
        else
            MeasurementValues{iy,ix}.PosXrelToCenter=NaN;
            MeasurementValues{iy,ix}.PosYrelToCenter=NaN;
        end
    end
end
%% calculate the frequency from the data
%Use the voltage and time to calculate the frequency from the time distance
%between all zero Crossings of the abs of the voltage.
for ix=1:sizeX
    for iy=1:sizeY
        [~,~,UZeroCrossing,iUZeroCrossing]=extrema(abs(MeasurementValues{iy,ix}.YData1));
        %clear all the values where it didn't go until zero (beginning or end for
        %example)
        j=1;
        for i=1:length(UZeroCrossing)
            if UZeroCrossing(i)<=1
                ZeroCrossing(j)=iUZeroCrossing(i);
                j=j+1;
            end
        end
        %sort the crossings by size
        ZeroCrossing=sort(ZeroCrossing);

        tZeroCrossing=MeasurementValues{iy,ix}.XData(ZeroCrossing);
        for i=1:length(tZeroCrossing)-1
            T(i)=tZeroCrossing(i+1)-tZeroCrossing(i);
        end
        ifreq=1/(4*mean(T));
        %and while we're on it.. get the amplitude as well
        MeasurementValues{iy,ix}.Aq1=max(MeasurementValues{iy,ix}.YData2);
        
        MeasurementValues{iy,ix}.Aq2=ifreq;
        MeasurementValues{iy,ix}.Aq3=ifreq;
        
        MeasurementValues{iy,ix}.Aq4=MeasurementValues{iy,ix}.PhaseShift;
        
        %and the resolution of the vibrometer
        MeasurementValues{iy,ix}.VelocityRes=iVelocityRes;
    end
end
%% save it
fpathMSStructure = strcat(ResultDataDir,'\MeasurementValues_Retrieved.mat');
save(fpathMSStructure,'MeasurementValues')

%% 
% k=1;
% for ix=1:sizeX
%     for iy=1:sizeY
%        Dmax(k)=max(MSResults{iy,ix}.iYDisplacementMAX);
%        k=k+1;
%     end
% end
