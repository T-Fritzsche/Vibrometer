%% have a look at the surf plot. Get the x (or y) data number the line should be printed of. --> use the marker
%% Load data
[fname pname] = uigetfile('MeasurementValues.mat','Select the Measurement Values to load');
Values = load([pname fname]); 
cellName=fieldnames(Values);%get the name of the data.. somtimes the old versions were called differently
MeasureStructur=Values.(cellName{1});

[iyMAX, ixMAX]=size(MeasureStructur);

%LinePlots(:,5)=zeros(maxsize,1);
%% specify the positions to check for --> LinePoints([ypos,xpos])
rowOfInterest=1;
columnOfInterest=NaN;

%create an array of the points we want to measure at
if ~isnan(columnOfInterest) %so we're looking for a vertical line here
    LinePoints=[(1:iyMAX)',columnOfInterest*ones(iyMAX,1)];
elseif ~isnan(rowOfInterest) %so we're looking for a horizontal line here
    LinePoints=[rowOfInterest*ones(ixMAX,1),(1:ixMAX)'];
end


%% evaluate!
LinePlots=createLinePlot(MeasureStructur,LinePoints);
%% plot it
figure
plot(LinePlots(:,5),LinePlots(:,4))

