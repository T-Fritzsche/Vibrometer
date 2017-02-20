%load the file via evaluateMeasurementValues in the interface
% --> MSResults is in workbench and has the {1,1}.Plot stuff in it

[ixMAX, iyMAX] = size(MSResults);
DisplacementZeros=zeros(ixMAX,iyMAX);
Displacement=NaN(ixMAX,iyMAX);
Velocity=NaN(ixMAX,iyMAX);

for ix=1:ixMAX
    for iy=1:iyMAX
        if (isfield(MSResults{iy,ix}, 'iYDisplacementMAX'))
            Displacement(iy,ix)=MSResults{iy,ix}.iYDisplacementMAX;
            DisplacementZeros(iy,ix)=MSResults{iy,ix}.iYDisplacementMAX;
            Velocity=MSResults{iy,ix}.iYVelocityMAX;
        end
    end
end



%% Einschub Mittelpunkt systematisch finden
x=MSResults{1,1}.Plot.PlotX;
y=MSResults{1,1}.Plot.PlotY;
z=MSResults{1,1}.Plot.PlotZDisplacement;

WorkDir= uigetdir('Select Path to save figures at');

[zmax,imax,zmin,imin] = extrema2(z,1);

figure
surf(x,y,z);

[a, b]=sort(abs(x(imax))+abs(y(imax))); %sortiere nach dem kleinsten Abstand zur ursprünglichen Mitte
j=1;
for i=1:length(a) %übernimm die Einträge mit einem Abstand kleiner 3mm
    if a(i)<3000
        imaxInner(j)=imax(b(i));
        j=j+1;
    end
end
%sortier imax wieder nach dem größen Wert --> maximum
[~,iMaxMit]=max(z(imaxInner));
iMittelpunkt=imaxInner(iMaxMit);
[iMittelpunktX, iMittelpunktY]=ind2sub(size(z),iMittelpunkt); %convert to normal indizes
xOffset=x(1,iMittelpunktX);
yOffset=y(iMittelpunktY,1);
hold on
plot3(x(iMittelpunktX, iMittelpunktY),y(iMittelpunktX, iMittelpunktY),z(iMittelpunktX, iMittelpunktY),'r*')
hold off 
%% Verschieben des Plots, damit Maximum im Mittelpunkt ist
x=x-xOffset;
y=y-yOffset;
surf(x,y,z);
MSResults{1,1}.Plot.PlotX=x;
MSResults{1,1}.Plot.PlotY=y;

% for ix=1:ixMAX
%     for iy=1:iyMAX
%         PosXi=MSResults{iy,ix}.PosX;
%         PosYi=MSResults{iy,ix}.PosY;
%         if ~(isnan(PosXi)||isnan(PosYi)) %use only measurement points
%             MSResults{iy,ix}.Plot.PlotX=MSResults{iy,ix}.Plot.PlotX-xOffset;
%             MSResults{iy,ix}.Plot.PlotY=MSResults{iy,ix}.Plot.PlotY-yOffset;
%             MSResults{iy,ix}.Plot.PlotX=MSResults{iy,ix}.Plot.PosXrelToCenter-xOffset;
%             MSResults{iy,ix}.Plot.PlotY=MSResults{iy,ix}.Plot.PosYrelToCenter-yOffset; 
%         end
%     end
% end
%% save

figure
surf(x,y,MSResults{1,1}.Plot.PlotZPhase);
title('Phaseshift between Velocity and stimulating Amplitude');
zlabel('Phase in deg');
xlabel('X in µm');
ylabel('Y in µm');
savefig(strcat(WorkDir,'\MaxPhaseShift.fig'))
matlab2tikz(strcat(WorkDir,'\MaxPhaseShift.tikz'))

figure
surf(x,y,MSResults{1,1}.Plot.PlotZDisplacement);
title('Absolut Maximum Displacement Value. Not Phase correct');
zlabel('Displacement in m');
xlabel('X in µm');
ylabel('Y in µm');
savefig(strcat(WorkDir,'\MaxDisplacement.fig'))
matlab2tikz(strcat(WorkDir,'\MaxDisplacement.tikz'))

figure
surf(x,y,MSResults{1,1}.Plot.PlotZVelocity);
title('Absolut Maximum Velocity Value. Not Phase correct');
zlabel('Velocity in m/s');
xlabel('X in µm');
ylabel('Y in µm');
savefig(strcat(WorkDir,'\MaxVelocity.fig'))
matlab2tikz(strcat(WorkDir,'\MaxVelocity.tikz'))
%% Line Plot ALL
% specify the positions to check for --> LinePoints([ypos,xpos])
figure;
hold on;
for i=ceil(iyMAX/2-5):ceil(iyMAX/2+5)
    %create an array of the points we want to measure at
    LinePointsCol=[(1:iyMAX)',i*ones(iyMAX,1)];
    LinePointsRow=[i*ones(ixMAX,1),(1:ixMAX)'];

    LinePlotsCol=createLinePlot(MSResults,LinePointsCol);
    LinePlotsRow=createLinePlot(MSResults,LinePointsRow);
    plot(LinePlotsCol(:,5),LinePlotsCol(:,4),'color',rand(1,3))
    plot(LinePlotsRow(:,5),LinePlotsRow(:,4),'--','color',rand(1,3))
end
hold off
%--> such dir den schönsten raus!
%% Line Plot 
% specify the positions to check for --> LinePoints([ypos,xpos])
rowOfInterest=12;
columnOfInterest=13;

%create an array of the points we want to measure at
if ~isnan(columnOfInterest) %so we're looking for a vertical line here
    LinePoints=[(1:iyMAX)',iMittelpunktX*ones(iyMAX,1)];
elseif ~isnan(rowOfInterest) %so we're looking for a horizontal line here
    LinePoints=[iMittelpunktY*ones(ixMAX,1),(1:ixMAX)'];
end

LinePlots=createLinePlot(MSResults,LinePoints);
figure;
plot(LinePlots(:,5),LinePlots(:,4))
%% Maximum und Minima finden
[hmax,imax,hmin,imin] =extrema(LinePlots(:,4)) %minima und maxima in der größe absteigender Reihenfolge
[hMittelpunkt posMittelpunkt]=min(abs(imax-(length(LinePlots(:,4))/2)))
deltaMitte=LinePlots(imax(posMittelpunkt),2)
LinePlots(:,2)=LinePlots(:,2)-deltaMitte; %--> jetzt ist das Maximum in der Mitte
LinePlots(:,5)=LinePlots(:,5)-deltaMitte;

%suche die Minima neben dem Maxima in der Mitte
[a posmin]=sort(abs(imin-imax(posMittelpunkt)));
iposMinLR=imin(posmin(1:2));
posLR=LinePlots(iposMinLR,2);

figure
plot(LinePlots(:,2),LinePlots(:,4),LinePlots(iposMinLR,2),LinePlots(iposMinLR,4),'or',LinePlots(imax(posMittelpunkt),2),LinePlots(imax(posMittelpunkt),4),'*b')
title('Absolut Maximum Displacement Value. Not Phase correct');
zlabel('Displacement in m');
xlabel('X in µm');
ylabel('Y in µm');
savefig(strcat(WorkDir,'\MaxDisplacementLine.fig'))
matlab2tikz(strcat(WorkDir,'\MaxDisplacementLine.tikz'))

%jetzt der selbe spaß noch mit der phase
figure
plot(LinePlots(:,2),LinePlots(:,6))
title('Phaseshift between Exitation and Displacement');
xlabel('X in µm');
ylabel('Phaseshift in deg');
savefig(strcat(WorkDir,'\PhaseShiftLine.fig'))
matlab2tikz(strcat(WorkDir,'\PhaseShiftLine.tikz'))

%% Textausgabe
disp(['Maximale Auslenkung  ' num2str(LinePlots(imax(posMittelpunkt),4)) ' µm.']);
disp(['Minimale Auslenkung an Position ' num2str(LinePlots(iposMinLR(1),2)) ' µm. Mit ' num2str(LinePlots(iposMinLR(1),4)) 'µm Auslenkung']);
disp(['und an Position ' num2str(LinePlots(iposMinLR(2),2)) ' µm. Mit ' num2str(LinePlots(iposMinLR(2),4)) 'µm Auslenkung']);
disp(['die insgesamt maximale Auslenkung war ' num2str(max(max(Displacement)))]);

