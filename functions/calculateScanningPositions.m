function[MeasureStructur,Outline]=calculateScanningPositions(Settings)
% This function calculates all the positions at which the
% velocity/displacement should be obtained. Both a square cell with x- and y
% positions for all the scanning points and a cell with some points of the
% outline are returned. The outline can be used as a preview to eliminate erroneous settings.

d=Settings.Scanning.DiaWidth;
stepNum=Settings.Scanning.NumSteps; %number of measurement points
stepWidth=ceil(d/(stepNum-1));
PosX=Settings.Scanning.PosX;
PosY=Settings.Scanning.PosY;
LocCurrentPos=Settings.Scanning.LocCurrentPos;
%% corner and center calculation
% the diameter and number of steps are given relative to a point which does
% not need to be the center of the shape. So we first need to calculate the
% 'real' center and the outer corners of the enclosing rectangle.

%The enclosing rectangle is not necessarily a square so the distance can be
%different in x and y direction.
AreaType=Settings.Scanning.Area;
switch AreaType
    case 'Square'
        dx=d;
        dy=d;
    case 'Circle'
        dx=d;
        dy=d;
    case 'Line  |'
        dx=0;
        dy=d;
    case 'Line  -'
        dx=d;
        dy=0;
    case 'Point'
        dx=0;
        dy=0;
    otherwise
        uiwait(msgbox('Error! Area type not implemented!'));
        return;        
end

%fill CornerPoints with 4 rows of [PosY, PosX]. Then calculate a
%correction factor and add it to the Matrix
%The sequence of CornerPoints/Correction=P is:
%   P(1,:)=upper left point         P(4,:)=upper right point
%                       P(5,:)=CENTER
%   P(2,:)=lower left point         P(3,:)=lower right point

encRect=repmat([PosY, PosX],5,1);
Correction=zeros(5,2);
switch LocCurrentPos
    case 'SelCurPosUL' %upper left(column)
        Correction=[0,0;-dy,0;-dy,dx;0,dx;-dy/2,dx/2];
    case 'SelCurPosCL' %center left
        Correction=[dy/2,0;-dy/2,0;-dy/2,dx;dy/2,dx;0,dx/2];
    case 'SelCurPosLL' %lower left
        Correction=[dy,0;0,0;0,dx;dy,dx;dy/2,dx/2];
    case 'SelCurPosUC' %upper center 
        Correction=[0,-dx/2;-dy,-dx/2;-dy,dx/2;0,dx/2;-dy/2,0];
    case 'SelCurPosCC' %center
        Correction=[dy/2,-dx/2;-dy/2,-dx/2;-dy/2,+dx/2;dy/2,dx/2;0,0];
    case 'SelCurPosLC' %lower center
        Correction=[dy,-dx/2;0,-dx/2;0,dx/2;dy,dx/2;dy/2,0];
    case 'SelCurPosUR' %upper right (column)
        Correction=[0,-dx;-dy,-dx;-dy,0;0,0;-dy/2,-dx/2];
    case 'SelCurPosCR' %center right
        Correction=[dy/2,-dx;-dy/2,-dx;-dy/2,0;dy/2,0;0,-dx/2];
    case 'SelCurPosLR' %lower right
        Correction=[dy,-dx;0,-dx;0,0;dy,0;dy/2,-dx/2];
end
encRect=ceil(encRect+Correction); %enclosingRectangle
%some generic points
Center.Y=encRect(5,1); %encRec(5,:)=Center(y,x)
Center.X=encRect(5,2); 
StartP.Y=encRect(1,1); %always start from the left upper corner
StartP.X=encRect(1,2);

%% Some checks to make sure wo won't leave the area of the stage

%check if points are in the valid working area
if min(encRect(:,2))<0
    uiwait(msgbox('Error! Points for x axis are below zero point of the axis'));
    return;
elseif max(encRect(:,2))>120000
    uiwait(msgbox('Error! Points for x axis are above maximum of the axis'));
    return;
elseif min(encRect(:,1))<0
    uiwait(msgbox('Error! Points for y axis are below zero point of the axis'));
    return;
elseif max(encRect(:,1))>120000
    uiwait(msgbox('Error! Points for y axis are above maximum of the axis'));
    return;
end

%% Calculate the point arrays in the scanning area 

        

if strcmp(Settings.Scanning.Area,'Point')
    %% scanning area should be a point
    MeasureStructur=cell(1,1);
    MeasureStructur{1,1}.PosX=PosX;
    MeasureStructur{1,1}.PosY=PosY;
    MeasureStructur{1,1}.PosXrelToCenter=0;
    MeasureStructur{1,1}.PosYrelToCenter=0;
    Outline=[PosY, PosX];
    

elseif strfind(Settings.Scanning.Area,'Line')
    %% scanning area should be a line 
    % and a horizontal one
    if strfind(Settings.Scanning.Area,'-')
        MeasureStructur=cell(1,stepNum); %(ySize,xSize)
        
        iy=1;
        for ix=1:stepNum
            iPosX=(StartP.X+(ix-1)*stepWidth);
            MeasureStructur{iy,ix}.PosX=iPosX;
            MeasureStructur{iy,ix}.PosY=StartP.Y;
            MeasureStructur{iy,ix}.PosXrelToCenter=iPosX-Center.X;
            MeasureStructur{iy,ix}.PosYrelToCenter=0;
        end
    % Scanning area should be a vertical line
    elseif strfind(Settings.Scanning.Area,'|')
        MeasureStructur=cell(stepNum,1); %(ySize,xSize)

        ix=1;
        for iy=1:stepNum
            iPosY=(StartP.Y-(iy-1)*stepWidth);
            MeasureStructur{iy,ix}.PosX=StartP.X;
            MeasureStructur{iy,ix}.PosY=iPosY;
            MeasureStructur{iy,ix}.PosXrelToCenter=0;
            MeasureStructur{iy,ix}.PosYrelToCenter=iPosY-Center.Y;
        end     
    end
    Outline=[encRect(1,:),encRect(3,:)];

elseif strcmp(Settings.Scanning.Area,'Square')
    %% Scanning area should be a square
    MeasureStructur=cell(stepNum,stepNum);

    for ix=1:stepNum
        for iy=1:stepNum
            iPosX=(StartP.X+(ix-1)*stepWidth);
            iPosY=(StartP.Y-(iy-1)*stepWidth);
            MeasureStructur{iy,ix}.PosX=iPosX;
            MeasureStructur{iy,ix}.PosY=iPosY;
            MeasureStructur{iy,ix}.PosXrelToCenter=iPosX-Center.X;
            MeasureStructur{iy,ix}.PosYrelToCenter=iPosY-Center.Y;
        end
    end
    Outline=[encRect(1:4,:);encRect(1,:)];
    
    
elseif strcmp(Settings.Scanning.Area,'Circle')
    %% Scanning area should be a circle
    ySize=stepNum;
    xSize=stepNum;
    MeasureStructur=cell(ySize,xSize);
     
    PosXValues=NaN(ySize,xSize);
    for ix=1:stepNum
        for iy=1:stepNum
            iPosX=(StartP.X+(ix-1)*stepWidth);
            iPosY=(StartP.Y-(iy-1)*stepWidth);
            %check if position is inside the circle via euklidic distance
            %to the center
            d_euk=sqrt((iPosX-Center.X)^2+(iPosY-Center.Y)^2);
             if d_euk<=d/2
                MeasureStructur{iy,ix}.PosX=iPosX;
                MeasureStructur{iy,ix}.PosY=iPosY;
                MeasureStructur{iy,ix}.PosXrelToCenter=iPosX-Center.X;
                MeasureStructur{iy,ix}.PosYrelToCenter=iPosY-Center.Y;
            else
                MeasureStructur{iy,ix}.PosX=NaN;
                MeasureStructur{iy,ix}.PosY=NaN;
                MeasureStructur{iy,ix}.PosXrelToCenter=NaN;
                MeasureStructur{iy,ix}.PosYrelToCenter=NaN;
            end 
            PosXValues(iy,ix)=MeasureStructur{iy,ix}.PosX;%save the x positions seperately
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
