function [] = generateGraph_v2(resultData,routeSubApp,currentMetricTypeValue,currentMetricValue)

%resultData(:,2) = sums and means
%resultData(:,3) = STD
%resultData(:,4) = SEM
%resultData(:,5) = number of participants

barwitherr([resultData{:,3}],[resultData{:,1}]); %(SEM,values)
title(sprintf('%s',currentMetricValue));
xlabel('Routes');

if contains(currentMetricValue,'Percent')
    ylabel('Percent of Total Usage (%)');
elseif strcmp(currentMetricTypeValue,'Time')
    ylabel('Seconds(s)');
else
    ylabel('Count (#)');
end
set(gca,'XTick',1:length(routeSubApp),'XtickLabel',routeSubApp);
set(gca,'XtickLabelRotation',15);