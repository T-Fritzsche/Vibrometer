function[MeasureStructur,Outline]=calculateScanningPositions(Settings)
% This function calculates all the positions at which the
% velocity/displacement should be obtained. Both a square cell with x- and y
% positions for all the scanning points and a cell with some points of the
% outline are returned. The outline can be used as a preview to eliminate erroneous settings.

d=Settings.Scanning.DiaWidth;
stepNum=Settings.Scanning.NumSteps;
stepwidth=ceil(d/(stepNum-1));

%correction for measurement at one point
if strcmp(Settings.Scanning.Area,'Point')
    d=0;
    stepNum=1;
    stepwidth=0;
end

%fill CornerPoints with 4 rows of [PosX, PosY]. Then calculate a
%correction factor and add it to the Matrix
%The sequence of CornerPoints/Correction=P is:
%   P(1,:)=upper left point     P(4,:)=upper right point
%   P(2,:)=lower left point     P(3,:)=lower right point

Outline=repmat([Settings.Scanning.PosX, Settings.Scanning.PosY],4,1);
Correction=zeros(4,2);

switch Settings.Scanning.LocCurrentPos
    case 'SelCurPosUL'
        Correction=[0,0;0,-d;d,-d;d,0];
    case 'SelCurPosCL'
        Correction=[0,d/2;0,-d/2;d,-d/2;d,d/2];
    case 'SelCurPosLL'
        Correction=[0,d;0,0;d,0;d,d];
    case 'SelCurPosUC'
        Correction=[-d/2,0;-d/2,-d;d/2,-d;d/2,0];
    case 'SelCurPosCC'
        Correction=[-d/2,d/2;-d/2,-d/2;d/2,-d/2;d/2,d/2];
    case 'SelCurPosLC'
        Correction=[-d/2,d;-d/2,0;d/2,0;d/2,d];
    case 'SelCurPosUR'
        Correction=[-d,0;-d,-d;0,-d;0,0];
    case 'SelCurPosCR'
        Correction=[-d,d/2;-d,-d/2;0,-d/2;0,d/2];
    case 'SelCurPosLR'
        Correction=[-d,d;-d,0;0,0;0,d];
end
Outline=ceil(Outline+Correction);
%check if points are in the valid working area
if min(Outline(:,1))<0
    uiwait(msgbox('Error! Points for x axis are below zero point of the axis'));
    return;
elseif max(Outline(:,1))>120000
    uiwait(msgbox('Error! Points for x axis are above maximum of the axis'));
    return;
elseif min(Outline(:,2))<0
    uiwait(msgbox('Error! Points for y axis are below zero point of the axis'));
    return;
elseif max(Outline(:,2))>120000
    uiwait(msgbox('Error! Points for y axis are above maximum of the axis'));
    return;
end

%% Scanning area 

%should be a point
if strcmp(Settings.Scanning.Area,'Point')
    MeasureStructur=cell(3,3);
    %fill everything exept {2,2} with NaN
    for ix=1:3
        for iy=1:3
            MeasureStructur{iy,ix}.PosX=NaN;
            MeasureStructur{iy,ix}.PosY=NaN;
            MeasureStructur{iy,ix}.PosXrelToCenter=NaN;
            MeasureStructur{iy,ix}.PosYrelToCenter=NaN;
        end
    end
    MeasureStructur{2,2}.PosX=Settings.Scanning.PosX;
    MeasureStructur{2,2}.PosY=Settings.Scanning.PosY;
    MeasureStructur{2,2}.PosXrelToCenter=0;
    MeasureStructur{2,2}.PosYrelToCenter=0;
    Outline=[Settings.Scanning.PosX, Settings.Scanning.PosY];
    
% Scanning area should be a line
elseif strfind(Settings.Scanning.Area,'Line')
    % and a horizontal one
    if strfind(Settings.Scanning.Area,'-')
        xSize = stepNum;
        ySize = 1;
        MeasureStructur=cell(ySize,xSize);

        XCenterRel=(xSize/2); 
        StartP=[min(Outline(:,1)),min(Outline(:,2))+((max(Outline(:,2))- min(Outline(:,2)))/2)];
        iy=1;
        for ix=1:xSize
            MeasureStructur{iy,ix}.PosX=(StartP(1)+(ix-1)*stepwidth);
            MeasureStructur{iy,ix}.PosY=StartP(2);
            MeasureStructur{iy,ix}.PosXrelToCenter=(ix-XCenterRel)*stepwidth;
            MeasureStructur{iy,ix}.PosYrelToCenter=0;
        end
        Outline=[StartP;max(Outline(:,1)),StartP(2)]; 
    % Scanning area should be a vertical line
    elseif strfind(Settings.Scanning.Area,'|')
        xSize = 1;
        ySize = stepNum;
        MeasureStructur=cell(ySize,xSize);

        YCenterRel=(ySize/2); 
        StartP=[min(Outline(:,1))+((max(Outline(:,1))- min(Outline(:,1)))/2),min(Outline(:,2))];
        ix=1;
        for iy=1:ySize
            MeasureStructur{iy,ix}.PosX=StartP(1);
            MeasureStructur{iy,ix}.PosY=(StartP(2)+(iy-1)*stepwidth);
            MeasureStructur{iy,ix}.PosXrelToCenter=0;
            MeasureStructur{iy,ix}.PosYrelToCenter=(iy-YCenterRel)*stepwidth;
        end
        Outline=[StartP;StartP(1),max(Outline(:,2))];
    end
% Scanning area should be a square
elseif strcmp(Settings.Scanning.Area,'Square')
    %calculate the number of points to measure
    xSize= stepNum;
    ySize= stepNum;
    %preseve the space needed
    MeasureStructur=cell(ySize,xSize);

    XCenterRel=(xSize/2); %floor
    YCenterRel=(ySize/2); %floor
    
    StartP=[min(Outline(:,1)) , max(Outline(:,2))];
    for ix=1:xSize
        for iy=1:ySize
            MeasureStructur{iy,ix}.PosX=(StartP(1)+(ix-1)*stepwidth);
            MeasureStructur{iy,ix}.PosY=(StartP(2)-(iy-1)*stepwidth);
            MeasureStructur{iy,ix}.PosXrelToCenter=(ix-XCenterRel)*stepwidth;
            MeasureStructur{iy,ix}.PosYrelToCenter=(iy-YCenterRel)*stepwidth;
        end
    end
    Outline=[Outline;Outline(1,:)];
    %% Scanning area should be a circle
    
elseif strcmp(Settings.Scanning.Area,'Circle')
    %calculate the number of points to measure
    xSize= stepNum;
    ySize= stepNum;
    %preseve the space needed
    MeasureStructur=cell(ySize,xSize);

    XCenterRel=(xSize/2); %floor
    YCenterRel=(ySize/2); %floor
    
    %the center of the scanning area is either already given or will be
    %calculated by the width, number of points an position
    ixMiddle=floor(median(Outline(:,1),'omitnan'));
    iyMiddle=floor(median(Outline(:,2),'omitnan'));
    
    PosXValues=NaN(ySize,xSize);
    StartP=[min(Outline(:,1)) , max(Outline(:,2))];
    for ix=1:xSize
        for iy=1:ySize
            PosiX=(StartP(1)+(ix-1)*stepwidth);
            PosiY=(StartP(2)-(iy-1)*stepwidth);
            %check if position is inside the circle via euklidic distance
            %to the center
            d_euk=sqrt((PosiX-ixMiddle)^2+(PosiY-iyMiddle)^2);
             if d_euk<=d/2
                MeasureStructur{iy,ix}.PosX=PosiX;
                MeasureStructur{iy,ix}.PosY=PosiY;
                MeasureStructur{iy,ix}.PosXrelToCenter=(ix-XCenterRel)*stepwidth;
                MeasureStructur{iy,ix}.PosYrelToCenter=(iy-YCenterRel)*stepwidth;
            else
                MeasureStructur{iy,ix}.PosX=NaN;
                MeasureStructur{iy,ix}.PosY=NaN;
                MeasureStructur{iy,ix}.PosXrelToCenter=NaN;
                MeasureStructur{iy,ix}.PosYrelToCenter=NaN;
            end 
            PosXValues(iy,ix)=MeasureStructur{iy,ix}.PosX;%save the x positions in a seperate
            %we are going to search this in the next step to find the
            %outline of the circle to preview the scanning path
        end
    end
 
    
    %%calculate the cornerpoints for a circle to show it in preview
    
 
    %first we select the number of preview points. Which are the positions
    %the xy-stage will drive to in preview.
    if xSize<104   %reduce the number of shown outline points to 2*10-2 or fewer
        numPoints=xSize;
    else
        numPoints=104;
    end
    numPointsPerSeg=ceil(numPoints/4); %we will start with all four corner 
                                       %points and add this number of
                                       %points between every segment of the
                                       %circles

    
    %create the outline of PosXValues and replace all inner values with NaN
    MiddleIndex=floor(length(PosXValues)/2);
    FilledRow=find(~isnan(PosXValues(:,MiddleIndex)'));
    firstFilledRow=FilledRow(1);
    lastFilledRow=FilledRow(end);
    for icol=1:length(PosXValues')
        if ~(icol==MiddleIndex||icol==(MiddleIndex+1))
            PosXValues(firstFilledRow,icol)=NaN;
            PosXValues(lastFilledRow,icol)=NaN;
        end
    end
    
    for iy=firstFilledRow+1:lastFilledRow-1
        rowEntries=find(~isnan(PosXValues(iy,:)));
        if ~isempty(rowEntries)
            for i=2:length(rowEntries)-1
                PosXValues(iy,rowEntries(i))=NaN;
            end
        end
    end
    
    %find the rows and colums with entries which are not NaN
    offset=floor(length(PosXValues)/2);
    MatrixQ1=PosXValues(1:floor(end/2),1:floor(end/2));
    MatrixQ2=PosXValues(floor(end/2)+1:end,1:floor(end/2));
    MatrixQ3=PosXValues(floor(end/2)+1:end,floor(end/2)+1:end);
    MatrixQ4=PosXValues(1:floor(end/2),floor(end/2)+1:end);
    
    [col1, row1] = find(~isnan(MatrixQ1')); %left upper part
    [col2, row2] = find(~isnan(MatrixQ2')); %left lower part
    row2=row2+offset;
    
    [col3, row3] = find(~isnan(MatrixQ3')); %right lower part
    row3=row3+offset;
    col3=col3+offset;
    col3=flipud(col3);  %flip order because we come from bottom of circle
    row3=flipud(row3);  %and we continue upwards
 
    [col4, row4] = find(~isnan(MatrixQ4')); %right upper part
    col4=col4+offset;  
    col4=flipud(col4); %flip order because we come from bottom of circle
    row4=flipud(row4);  %and we continue upwards

    Entries1(1,:)=[MeasureStructur{row1(1),col1(1)}.PosX, MeasureStructur{row1(1),col1(1)}.PosY];
    Entries2(1,:)=[MeasureStructur{row2(1),col2(1)}.PosX, MeasureStructur{row2(1),col2(1)}.PosY];
    Entries3(1,:)=[MeasureStructur{row3(1),col3(1)}.PosX, MeasureStructur{row3(1),col3(1)}.PosY];
    Entries4(1,:)=[MeasureStructur{row4(1),col4(1)}.PosX, MeasureStructur{row4(1),col4(1)}.PosY];
    maxSize=min([length(row1),length(row2),length(row3),length(row4)]);
    for i=1:numPointsPerSeg
        entry=i*round((length(row1)-1)/(numPointsPerSeg+1))+1; %decides which entries should be used
        if entry>=maxSize
            entry=maxSize;
        end
        Entries1(i+1,:)=[MeasureStructur{row1(entry),col1(entry)}.PosX, MeasureStructur{row1(entry),col1(entry)}.PosY];
        Entries2(i+1,:)=[MeasureStructur{row2(entry),col2(entry)}.PosX, MeasureStructur{row2(entry),col2(entry)}.PosY];
        Entries3(i+1,:)=[MeasureStructur{row3(entry),col3(entry)}.PosX, MeasureStructur{row3(entry),col3(entry)}.PosY];
        Entries4(i+1,:)=[MeasureStructur{row4(entry),col4(entry)}.PosX, MeasureStructur{row4(entry),col4(entry)}.PosY];
    end
    OutlineRound=[Entries1;Entries2;Entries3;Entries4;Entries1(1,:)];
    Outline=OutlineRound;
    
    
end
