function plotInfinite(plotHandle, ZData, Zname,delay)

while 1
    for i=1:length(ZData)
        plotHandle.ZData = ZData{i,1}.(Zname);
         axis manual %Keep the current axis limits by setting the limits mode to manual.
         pause(delay);
    end
end