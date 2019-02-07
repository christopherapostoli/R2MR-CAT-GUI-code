function [] = generateGraph_v2(resultData,routeSubApp,currentMetricTypeValue,currentMetricValue)

%resultData(:,2) = sums and means
%resultData(:,3) = STD
%resultData(:,4) = SEM
%resultData(:,5) = number of participants

h = barwitherr([resultData{:,3}],[resultData{:,1}]); %(SEM,values)
title(sprintf('%s',currentMetricValue));
xlabel('Routes');

if contains(currentMetricValue,'Percentage')
    ylabel(horzcat('% ',currentMetricTypeValue));
    ytickformat('percentage');
elseif strcmp(currentMetricTypeValue,'Time')
    ylabel('Seconds(s)');
else
    ylabel('Count (#)');
end

%Fix bar graph when there's only one point... pad data
if length(routeSubApp) == 1
    h.XData = [0,1,2];
    h.YData = [0,h.YData,0];
    set(gca,'XtickLabel',{'',routeSubApp{1},''});
    h.BarWidth = 3;
else
    set(gca,'Xtick',1:length(routeSubApp));
    set(gca,'XtickLabel',routeSubApp);
end
set(gca,'XtickLabelRotation',15);