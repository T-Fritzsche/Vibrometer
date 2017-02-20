function [ output_args ] = MYplot(varargin)
% set the figure options for plot
% valid parameter are:
% 'FontSize';'FontName';'PictureWidth'

optargin = size(varargin,2);

% default values 
    FSize = 14;
    FontName = 'Calibri';
    X = 14;
% options and transfer parameter
    if mod(optargin,2) == 0
        for index=1:2:optargin
            if strcmp(varargin(index) , 'FontSize') == true
                FSize = varargin{index+1};
            elseif strcmp(varargin(index) , 'FontName') == true
                FontName = varargin{index+1};
            elseif strcmp(varargin(index) , 'PictureWidth') == true
                X = varargin{index+1};
            end
        end
        xSize = X*1.12;    
        ySize = xSize/1.23;
        PixelPerCm=get(0, 'ScreenPixelsPerInch')/2.54; 
        set(0,'defaultaxesfontname',FontName);
        set(0,'defaultaxesfontsize',FSize);
        set(gcf,'color','white');
        set(gcf,'PaperUnits','centimeters');
        set(gcf,'Position',[50 50 xSize*PixelPerCm ySize*PixelPerCm]);
        set(gcf,'PaperPositionMode','auto');
%       set(gca,'color','none');
    else
         output_args = fprintf('not enough input arguments')
    end
end