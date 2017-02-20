%% Generate a video from the imported plots
%load files
[baseName, folder] = uigetfile();
fullFileName = fullfile(folder, baseName);
MSResults=load(fullFileName);

%% --> MSResults is in workbench and has the {1,1}.Plot stuff in it
try
    PlotZ_t=MSResults.PlotValues.PlotZ_t;
    PlotX=MSResults.PlotValues.PlotX;
    PlotY=MSResults.PlotValues.PlotY;
   overview=MSResults.PlotValues.overview;
catch exceptions
    uiwait(msgbox('Something somewhere went terribly wrong'));
end

displMAX=max(overview(:,14));
displMIN=min(overview(:,15));

 %% save as video
% figure();
% s2 = surf(PlotX,PlotY,PlotZ_t{1,1}.Displacement,'EdgeColor','none');
% zlim([displMIN displMAX]);
% xlim([-5000 5000]);
% ylim([-5000 5000]);
% % caxis([displMIN displMAX]);
% title('Surface displacement of the transducer');
% zlabel('Displacement in m');
% xlabel('X in µm');
% ylabel('Y in µm');
% 
% for i=1:length(PlotZ_t)
%         s2.ZData = PlotZ_t{i,1}.Displacement;
%         drawnow
%         F(i)=getframe(gcf);
%         pause(0.001);
% end
% path=strcat(folder,'Displacement.avi');
% video=VideoWriter(path,'MPEG-4');
% video.FrameRate=60;
% open(video)
% writeVideo(video,F);
% close(video)
% 
% %default
% video=VideoWriter(path);
% video.FrameRate=60;
% open(video)
% writeVideo(video,F);
% close(video)


%% saving a gif
gifFileName = strcat(folder,'Displacement.gif');
f1=figure();
MYplot('FontSize',20,'FontName','Calibri','PictureWidth',15);
s3 = surf(PlotX/1e3,PlotY/1e3,PlotZ_t{1,1}.Displacement.*1e6);
zlim([displMIN.*1e6 displMAX.*1e6]);
caxis([displMIN.*1e6 displMAX.*1e6]);
xlim([-5 5]);
ylim([-5 5]);
zlabel('Auslenkung in µm');
% xlabel('X in µm');
% ylabel('Y in µm');
set(gcf,'color','white');
f = getframe(gcf);
[im,map] = rgb2ind(f.cdata,256,'nodither');
% im(1,1,1,20) = 0;
for i=1:length(PlotZ_t)
        s3.ZData = PlotZ_t{i,1}.Displacement.*1e6;
        drawnow;
        f = getframe(gcf);
        F(i)=getframe(gcf);
        im(:,:,1,i) = rgb2ind(f.cdata,map,'nodither');
        pause(0.01);
end
imwrite(im,map,gifFileName,'DelayTime',0.25,'LoopCount',inf) %g443800

%video
path=strcat(folder,'Displacement');
video=VideoWriter(path,'MPEG-4');
video.Quality=100;
video.FrameRate=60;
open(video)
writeVideo(video,F);
close(video)


%default
video=VideoWriter(path);
video.FrameRate=60;
video.Quality=100;
open(video)
writeVideo(video,F);
close(video)

