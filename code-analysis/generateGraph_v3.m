function [] = generateGraph_v3(dataAx,resultData,subRoutes, metricSplit)

%resultData(:,2) = sums and means
%resultData(:,3) = STD
%resultData(:,4) = SEM
%resultData(:,5) = number of participants

%Create Figure that contains image of all three fig

%Find main route
try 
    %Multiple routes exist
    routeSubApp = strsplit(subRoutes{1},'.');
    mainRoute = routeSubApp{1};
    %Remove main Route from all route names if there is another proceeding field 
    if any(contains(subRoutes,horzcat(mainRoute,'.')) & cellfun('length',subRoutes)-length(mainRoute) >= 1)
        idxRoutes = (contains(subRoutes,horzcat(mainRoute,'.')) & cellfun('length',subRoutes)-length(mainRoute) >= 1);
        subRoutesParse = erase(subRoutes(idxRoutes),horzcat(mainRoute,'.'));
    else
        subRoutesParse = subRoutes;
    end
catch
    %There is only on route, set vars to the one route
    mainRoute = subRoutes;
    subRoutesParse = subRoutes; 
end

%Set font 
fontName = 'sans-serif'; 

%Create bar graph plot with error bars
barwitherr([resultData{:,3}],[resultData{:,1}]); %(SEM,values)

%Set Xtick values
set(dataAx,'XTick',1:length(subRoutesParse),'XtickLabel',subRoutesParse);
set(dataAx,'XtickLabelRotation',25, ...
    'FontSize',14, ...
    'FontUnits','points', ...
    'FontWeight', 'normal',...
    'FontName',fontName);

%Set y-axis label based on metric value 
if contains(metricSplit,'Percent')
    %remove percentage
    spltiPer = strsplit(metricSplit,' ');
    ylabel(horzcat(strjoin(spltiPer(2:end)),' (%)'), ...
        'FontUnits','points',...
        'FontWeight','bold',...
        'FontSize',18,...
        'FontName',fontName);
elseif contains(metricSplit,'Time')
    ylabel(horzcat(metricSplit, ' (s)'), ...
        'FontUnits','points',...
        'FontWeight','bold',...
        'FontSize',18,...
        'FontName',fontName);
else
    ylabel(horzcat(metricSplit, ' (#)'),...
        'FontUnits','points',...
        'FontWeight','bold',...
        'FontSize',18,...
        'FontName',fontName);
end

%Set x-axis label 
xlabel('Route', ...
    'FontUnits','points',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FontName',fontName);

%Set title to main route
title(horzcat(mainRoute,'.'), ...
    'FontSize',25, ...
    'FontUnits','points', ...
    'FontWeight', 'Bold',...
    'FontName',fontName);