function GUI_Analysis_v3(deviceEvents,deviceData,currentAppValue,outputDir)
% creates a UI with a graph and table detailing the time
% spent per route, depending on the name of the selected route

% how to save graphs and know which users were included in the analysis???

%% Set Metrics and calc values
%set the routeSubApp and title based on the app choice
figureName = horzcat(currentAppValue,' Analytics GUI');
metricType = {'Time','Click','Frequency'}; %Defines metric type that could be analyzed
metricTime = {'Total Time','Average Time per user','Average Time per visit','Average Time per visit per user','Percentage Time on sub-app'}; %Defines metrics that could be analyzed
metricClick = {'Total Clicks','Average Clicks per user','Average Clicks per visit','Average Clicks per visit per user','Percentage Clicks on sub-app'}; %Defines metrics that could be analyzed
metricFreq = {'Total Frequency', 'Average Frequency','Percentage Frequency'}; %Defines metrics that could be analyzed

%Default Global values
currentMetricTypeValue = metricType{1};
currentMetricValue = metricTime{1};
prnt_type = {'-depsc','-dpng'};
prnt_name = {'epsc','png'};
countNoData = 1; %Notify user when they have encountered a 'no data' scenario

%% Parameter Values
%Create table with all parameters 
paramFields = fieldnames(deviceData);
paramFields = paramFields(1:end-3); %Remove last two fields,'Properties' 'Row' 'Variables', not relevant
paramDropDown = paramFields{1};


%% Find all unique users 
uniqueUsers = deviceData.currentUser; 
assignin('base','uniqueUsers',uniqueUsers);  % assign the following variables to the main workspace to be used elsewhere

%% Create Data Tables for TIME, CLICK and FREQUENCY
%Call functions to output tables
[userDataTime,mainRoutes] = getTimeData_v2(deviceEvents,uniqueUsers); %all TIME data
[userDataClick,userDataTrans] = getClickData_v2(deviceEvents,uniqueUsers);
selectRoute = mainRoutes{1};
%% Create and Add UI components

% Create figure UI window
f = figure('Name',figureName,'Position',[100,300,1200,780],'color','white','Units','normalized');

%UIcontrol Position:[left, bottom, width, height]
%---------------------------------------------------------------------------------------------
% 'Select Top Level Route to Display'
routeLevelText = uicontrol('Style','text','String','Top Level:',...
    'Position',[5,650,90,25],'Units','normalized','FontSize',12,'FontWeight','bold'); 
% the drop down popup menu that allows users to select which route(s) to analyze
routeDropDownSelection = uicontrol('Style','popupmenu','String',mainRoutes,...
    'Position',[115,650,90,25],'Callback',@routeSelection_Callback,'Units','normalized');
% Create 'Generate' push button
% generateRouteButton = uicontrol('Style','pushbutton','String','Previous Route',...
%     'Position',[215,735,90,25],'Callback',{@generateRouteButton_Callback},'Units','normalized');

% % 'Select Curr Level Route to Display'
% routeCurrLevelText = uicontrol('Style','text','String','Curr Level:',...
%     'Position',[5,695,90,25],'Units','normalized','FontSize',12,'FontWeight','bold'); 
% % the drop down popup menu that allows users to select which route(s) to analyze
% routeCurrDropDownSelection = uicontrol('Style','popupmenu','String',routeSubApp,...
%     'Position',[115,695,90,25],'Callback',@routeCurrSelection_Callback,'Units','normalized');
% % Create 'Generate' push button
% generateCurrRouteButton = uicontrol('Style','pushbutton','String','Route Data',...
%     'Position',[215,695,90,25],'Callback',{@generateCurrRouteButton_Callback},'Units','normalized');
% 
% % 'Select Route to Display'
% routeNextLevelText = uicontrol('Style','text','String','Next Level:',...
%     'Position',[5,655,90,25],'Units','normalized','FontSize',12,'FontWeight','bold'); 
% % the drop down popup menu that allows users to select which route(s) to analyze
% routeNextDropDownSelection = uicontrol('Style','popupmenu','String',routeSubApp,...
%     'Position',[115,655,90,25],'Callback',@routeNextSelection_Callback,'Units','normalized');
% % Create 'Generate' push button
% generateNextRouteButton = uicontrol('Style','pushbutton','String','Enter Route',...
%     'Position',[215,655,90,25],'Callback',{@generateNextRouteButton_Callback},'Units','normalized');

% 'Select Metric Type'
metricTypeText = uicontrol('Style','text','String','Select Type:',...
    'Position',[5,615,100,25],'Units','normalized','FontSize',12,'FontWeight','bold');
% drop down menu for specific metric given the type
metricTypeDropDownSelection = uicontrol('Style','popupmenu','String',metricType,...
    'Position',[115,615,90,25],'Callback',@metricTypeSelection_Callback,'Units','normalized');

% 'Select Metric'
metricText = uicontrol('Style','text','String','Select Metric:',...
    'Position',[5,575,105,25],'Units','normalized','FontSize',12,'FontWeight','bold');
% the drop down popup menu that allows users to select which metric to employ
metricDropDownSelection = uicontrol('Style','popupmenu','String',metricTime,...
        'Position',[115,575,90,25],'Callback',@metricSelection_Callback,'Units','normalized');
% Create 'Generate' push button
generateMetricButton = uicontrol('Style','pushbutton','String','Generate Data and Plot',...
    'Position',[17,690,195,35],'Callback',{@generateMetricButton_Callback},'Units','normalized','FontSize',13);

% No Data to Display message to the user if there's no data to be seen
hMessageErrorData = uicontrol('Style','text','String','No data to display','ForegroundColor','r',...
        'Visible','on','Position',[230,570,80,100],'Units','normalized','FontSize',14,'FontWeight','bold');

%---------------------------------------------------------------------------------------------
% 'Enter START Date to exclude from data' 
inpTitleDateText = uicontrol('Style','text','String','Enter Inclusion Date',...
    'Position',[25,535,250,30],'Units','normalized','FontSize',14,'FontWeight','bold');
inpStartDateText = uicontrol('Style','text','String','Start Date:',...
    'Position',[10,495,85,30],'Units','normalized','FontSize',12,'FontWeight','bold');
inpStartDateInput = uicontrol('Style','edit','String','dd-mm-yyyy hh:mm:ss',...
    'Position',[110,500,180,30],'Units','normalized','FontSize',10,'FontWeight','bold');  
% 'Enter END Date to exclude from data'
inpEndDateText = uicontrol('Style','text','String','End Date:',...
    'Position',[10,455,85,30],'Units','normalized','FontSize',12,'FontWeight','bold');
inpEndDateInput = uicontrol('Style','edit','String','dd-mm-yyyy hh:mm:ss', ...
    'Position',[110,460,180,30],'Units','normalized','FontSize',10,'FontWeight','bold');
% the table that lists the users included in the analysis and allows for selecting/deselecting
dateInclTable = uitable('Parent',f,'Position',[10,335,315,120],... 
    'ColumnFormat',{'char','char','logical','logical'},'Data',[],'ColumnName',{'Start','End','Selected','Delete'},...
    'ColumnEditable',[true true true true],'ColumnWidth',{'auto','auto',50,50},...
    'Units','normalized');
% select/deselect/delete all buttons
generateStartDateButton = uicontrol('Style','pushbutton','String','Add Inclusion',...
    'Position',[15,300,145,30],'Callback',{@generateStartButton_Callback},'Units','normalized', 'FontSize',15);
deleteDateButton = uicontrol('Style','pushbutton','String','Delete Selected',...
    'Position',[165,300,145,30],'Callback',@deleteDate_Callback,'Units','normalized','FontSize',15);
% No Data to Display message to the user if there's no data to be seen
hMessageErrorDateData = uicontrol('Style','text','String','Error Date Format','ForegroundColor','r',...
        'Visible','off','Position',[35,265,250,30],'Units','normalized','FontSize',14,'FontWeight','bold');
hMessageErrorDataExists = uicontrol('Style','text','String','Not Unique','ForegroundColor','r',...
        'Visible','off','Position',[35,265,250,30],'Units','normalized','FontSize',14,'FontWeight','bold'); 
%---------------------------------------------------------------------------------------------
% Param DISPLAY - show criteria the user can select
%Display Paramter Criteria
dispParamText = uicontrol('Style','text','String','Display Param Criteria',...
    'Position',[699.0,427.0,250.0,30],'Units','normalized','FontSize',15,'FontWeight','bold');
dataParamFieldText = uicontrol('Style','text','String','Select Param:',...
    'Position',[675.0,381,115.0,25],'Units','normalized','FontSize',12,'FontWeight','bold');
dataParamFieldDrop = uicontrol('Style','popupmenu','String',paramFields,...
    'Position',[818.0,380,150,25.0],'Callback',@dataParam_Callback,'Units','normalized');
dataParamCriteraText = uicontrol('Style','text','String','Select Criteria:',...
    'Position',[679.0,344.0,120,25],'Units','normalized','FontSize',12,'FontWeight','bold');
dataParamCriteraDrop = uicontrol('Style','popupmenu','String',{'Select'},...
    'Position',[816.0,347,150,25.0],'Units','normalized');
% No Data to Display message to the user if there's no data to be seen
hMessageErrorCriteriaNoData = uicontrol('Style','text','String','No Data','ForegroundColor','r',...
        'Visible','off','Position',[420,301,150,50],'Units','normalized','FontSize',14,'FontWeight','bold');
hMessageErrorCriteriaExists = uicontrol('Style','text','String','Not Unique','ForegroundColor','r',...
        'Visible','off','Position',[745,307,150,50],'Units','normalized','FontSize',14,'FontWeight','bold'); 
%---------------------------------------------------------------------------------------------
%PARAMTER table - extracted from Data txt files
% paramText = uicontrol('Style','text','String','Parameters:',...
%     'Position',[730,750,100,30],'Units','normalized','FontSize',12,'FontWeight','bold');
% the table that lists the users included in the analysis and allows for selecting/deselecting
paramTable = uitable('Parent',f,'Position',[315,505,185,270],... 
    'ColumnFormat',{'char','char','logical'},'Data',[],'ColumnName',{'Param','Criteria','Selected'},...
    'ColumnEditable',[true true true],'ColumnWidth',{'auto','auto','auto'},...
    'CellEditCallback',@paramDependentData,'Units','normalized');
selectAllParamButton = uicontrol('Style','pushbutton','String','Select All',...
    'Position',[320,475,80,25],'Callback',@selectAllParam_Callback,'Units','normalized');
deselectAllParamButton = uicontrol('Style','pushbutton','String','Deselect All',...
    'Position',[405,475,80,25],'Callback',@deselectAllParam_Callback,'Units','normalized');

%---------------------------------------------------------------------------------------------
% USER SELECTION - the table that lists the users included in the analysis and allows for selecting/deselecting
userSelectionTable = uitable('Parent',f,'Position',[510,500,190,275],... %[780,500,320,250]
    'ColumnFormat',{'char','logical'},'Data',[],'ColumnName',{'User','Selected'},...
    'ColumnEditable',[true true],'ColumnWidth',{'auto','auto'},...
    'CellEditCallback',@userDependentData,'Units','normalized');
selectedUsers(1:size(uniqueUsers,1),1) = {true}; %Checkbox all users to start
userSelectionTable.Data = [uniqueUsers,selectedUsers]; %Show all users 
% select/deselect all buttons
selectAllUserButton = uicontrol('Style','pushbutton','String','Select All',...
    'Position',[525,475,80,25],'Callback',@selectAllUser_Callback,'Units','normalized');
deselectAllUserButton = uicontrol('Style','pushbutton','String','Deselect All',...
    'Position',[610,475,80,25],'Callback',@deselectAllUser_Callback,'Units','normalized');

%---------------------------------------------------------------------------------------------
% TIME DISPLAY - show start and end time of data set

%Display Time
dispTimeText = uicontrol('Style','text','String','Display Date Timeframe',...
    'Position',[407.0,426.0,250.0,30],'Units','normalized','FontSize',15,'FontWeight','bold');
dataStartDateText = uicontrol('Style','text','String','Start Data:',...
    'Position',[344.0,380,85.0,30],'Units','normalized','FontSize',12,'FontWeight','bold');
dataStartInput = uicontrol('Style','edit','String','dd-mm-yyyy hh:mm:ss',...
    'Position',[450.0,381,150.0,30],'Units','normalized','FontSize',10,'FontWeight','bold');  
% 'Enter END Date to exclude from data'
dataEndText = uicontrol('Style','text','String','End Data:',...
    'Position',[343.0,340.0,85.0,30],'Units','normalized','FontSize',12,'FontWeight','bold');
dataEndInput = uicontrol('Style','edit','String','dd-mm-yyyy hh:mm:ss', ...
    'Position',[446.0,341,150.0,25.0],'Units','normalized','FontSize',10,'FontWeight','bold');

%---------------------------------------------------------------------------------------------
% PPT DATA - the table that lists the data 
hTableDataTime = uitable('Parent',f,'Data',[],'ColumnName',{'','','','','',''},...
    'ColumnWidth',{'auto','auto','auto','auto','auto','auto'},'Position',[710,470,480,305],'Units','normalized');
hTableDataClick = uitable('Parent',f,'Data',[],'ColumnName',{'','','','','',''},...
    'ColumnWidth',{'auto','auto','auto','auto','auto','auto'},'Position',[10.0,35,520,245],'Units','normalized');
hTableDataFreq = uitable('Parent',f,'Data',[],'ColumnName',{'','','','','',''},...
    'ColumnWidth',{'auto','auto','auto','auto','auto','auto'},'Position',[645,40,520,245],'Units','normalized');
% export data and figure buttons
exportDataButton = uicontrol('Style','pushbutton','String','Export Data','Fontsize',13,'Fontweight','bold', ...
    'Position',[20,10,200,30],'Callback',@exportDataButton_Callback,'Units','normalized');
% export success/failure feedback to the user
exportSuccessFeedback = uicontrol('Style','text','String','Export successful!',...
    'ForegroundColor',[.176 .785 .215],'Visible','off','Position',[870,25,120,30],...
    'Units','normalized','Fontsize',9,'Fontweight','bold');
exportFailFeedback = uicontrol('Style','text','String','Export failed!',...
    'ForegroundColor',[.8 .195 .195],'Visible','off','Position',[870,25,120,30],...
    'Units','normalized','Fontsize',9,'Fontweight','bold');
figExportSuccessFeedback = uicontrol('Style','text','String','Graph export successful!',...
    'ForegroundColor',[.176 .785 .215],'Visible','off','Position',[855,5,150,30],...
    'Units','normalized','Fontsize',9,'Fontweight','bold');

%--------------------------------- Generate Graph -------------------------------------------
% open a graph for plotting the data
% hChart = axes('Position',[395,145,780,275],'Units','pixels');
%hChart = axes('Position',[0.364166666666667,0.183333333333333,0.619166666666667,0.352564102564103],'Units','normalized');
movegui(f,'center');
fprintf('... GUI has succefully been created.\n');

%% Select Values using Dropdown
% ------------------ Top Level ROUTE Selection ---------------------------------
% route selection callback function
    function routeSelection_Callback(source,eventdata) % The first argument is the UI component that triggered the callback. The second argument provides event data to the callback function. If there is no event data available to the callback function, then MATLAB passes the second input argument as an empty array.
        str = source.String; % lists possible strings (from catrouteSubApp)
        val = source.Value; % finds the value (digit) of the index of the string selected (e.g. 'Latvia' is number 12 in the list)
        % set curret data to selected data set then run time_per_selection to calculate data based on selection
        selectRoute = str{val};
    end
% ------------------ Curr Level ROUTE Selection ---------------------------------
% route selection callback function
%     function routeCurrSelection_Callback(source,eventdata) % The first argument is the UI component that triggered the callback. The second argument provides event data to the callback function. If there is no event data available to the callback function, then MATLAB passes the second input argument as an empty array.
%         str = source.String; % lists possible strings (from catrouteSubApp)
%         val = source.Value; % finds the value (digit) of the index of the string selected (e.g. 'Latvia' is number 12 in the list)
%         % set curret data to selected data set then run time_per_selection to calculate data based on selection
%         selectRoute = str{val};
%     end
% ------------------ Next Level ROUTES Selection ---------------------------------
% route selection callback function
%     function routeNextSelection_Callback(source,eventdata) % The first argument is the UI component that triggered the callback. The second argument provides event data to the callback function. If there is no event data available to the callback function, then MATLAB passes the second input argument as an empty array.
%         str = source.String; % lists possible strings (from catrouteSubApp)
%         val = source.Value; % finds the value (digit) of the index of the string selected (e.g. 'Latvia' is number 12 in the list)
%         % set curret data to selected data set then run time_per_selection to calculate data based on selection
%         selectRoute = str{val};
%     end

% ------------------ METRIC TYPE Selection ----------------------------
% metric selection callback function
    function metricTypeSelection_Callback(source,eventdata) 
        str = source.String; % lists possible strings (from catrouteSubApp)
        val = source.Value; % finds the value (digit) of the index of the string selected (e.g. 'Latvia' is number 12 in the list)
        % set curret data to selected data set then run time_per_selection to calculate data based on selection
        currentMetricTypeValue = str{val};
        generateMetricTypeButton_Callback(source,eventdata);
    end    
    
% ------------------ METRIC VALUE Selection ----------------------------
% metric selection callback function
    function metricSelection_Callback(source,eventdata) 
        str = source.String; % lists possible strings (from catrouteSubApp)
        val = source.Value; % finds the value (digit) of the index of the string selected (e.g. 'Latvia' is number 12 in the list)
        % set curret data to selected data set then run time_per_selection to calculate data based on selection
        currentMetricValue = str{val};
    end

%% Generate Button
% ------------------ TOP LEVEL ROUTE Button ---------------------------------
% Program push button: Function dictates actions when button is clicked
% function generateRouteButton_Callback(source,eventdata)
%     
%     hMessageErrorData.Visible = 'on';
%     disp('No data for this route');
%     %Create graph of data for a specific metric as the x axis
%     %*** Need to think this through****
% 
% end

% ------------------Previous Route Button ---------------------------------
% Program push button: Function dictates actions when button is clicked
% function generatePrevRouteButton_Callback(source,eventdata)
%     
%     hMessageErrorData.Visible = 'on';
%     disp('No data for this route');
%     %Create graph of data for a specific metric as the x axis
%     %*** Need to think this through****
% 
% end

% ------------------NEXT LEVEL ROUTES Button ---------------------------------
% Program push button: Function dictates actions when button is clicked
% function generateNextRouteButton_Callback(source,eventdata)
%     
%     hMessageErrorData.Visible = 'on';
%     disp('No data for this route');
%     %Create graph of data for a specific metric as the x axis
%     %*** Need to think this through****
% 
% end

% ------------------ METRIC TYPE Button ---------------------------------
% Program push button: Change metric list based on metric type
function generateMetricTypeButton_Callback(source,eventdata) 
    posMetric = getpixelposition(metricDropDownSelection,true); %Find pixel coordinate relative to figure. 
    delete(metricDropDownSelection); %Replace metric list with updated metric type
    if strcmp(currentMetricTypeValue,metricType{1,1}) %Time
        metricDropDownSelection = uicontrol('Style','popupmenu','String',metricTime,...
            'Position',posMetric,'Callback',@metricSelection_Callback,'Units','normalized');
        currentMetricValue = metricTime{1}; %default
    elseif strcmp(currentMetricTypeValue,metricType{1,2}) %Click
        metricDropDownSelection = uicontrol('Style','popupmenu','String',metricClick,...
            'Position',posMetric,'Callback',@metricSelection_Callback,'Units','normalized');
        currentMetricValue = metricClick{1}; %default
    elseif strcmp(currentMetricTypeValue,metricType{1,3}) %Frequency
        metricDropDownSelection = uicontrol('Style','popupmenu','String',metricFreq,...
            'Position',posMetric,'Callback',@metricSelection_Callback,'Units','normalized');
        currentMetricValue = metricFreq{1}; %default
    end
end
 
% ------------------ METRIC VALUE Button ---------------------------------
% Program push button: Function dictates actions when button is clicked
function generateMetricButton_Callback(source,eventdata)
    
    for m = 1:length(mainRoutes)
        
        selectRoute = mainRoutes{m};
        
        %Display on a graph the users metric value for all routes based on:
        % - metric type, metric value
        %Find MetricType of data
        hMessageErrorData.Visible = 'off'; % turn off 'No data to display' message
        hMessageErrorDataExists.Visible = 'off'; %Turn on error message
        
        %Write to UITable    
        metricSplit = strsplit(currentMetricValue,' ');
        metricSplitTime = metricSplit;
        metricSplitTime{2} = 'Time';
        metricSplitTime = strjoin(metricSplitTime,' '); 
        metricSplitClick = metricSplit;
        metricSplitClick{2} = 'Clicks';
        metricSplitClick = strjoin(metricSplitClick,' ');
        metricSplitFreq = metricSplit;
        metricSplitFreq{2} = 'Frequency';
        metricSplitFreq = strjoin(metricSplitFreq,' ');

        fprintf("Route: %s || Type: %s || Metric: %s ... ",selectRoute,currentMetricTypeValue,currentMetricValue);

        %Acquire CLICK data        
        assignin('base','userTimeData',userDataTime);  % assign the following variables to the main workspace to be used elsewhere
        assignin('base','userClickData',userDataClick);  % assign the following variables to the main workspace to be used elsewhere
        assignin('base','userTransData',userDataTrans);  % assign the following variables to the main workspace to be used elsewhere

        %Determine Time and Users to include
            %Check if there's data
        if ~isempty(userDataTime) || ~isempty(userDataClick) || ~isempty(userDataTrans)

            %Analysis of data based on selected participants and parameters 
            %Call Search cretieria to find new values

            %Time    
            [dataStartInput.String,dataEndInput.String,selectedDataTime,criteriaUsers] = searchCritera(userDataTime,uniqueUsers,selectedUsers,deviceData,paramTable.Data,dateInclTable.Data); %Sort Data
            selectedUsersCriteria = num2cell(ismember(uniqueUsers,criteriaUsers)); %Update selectedUsers
            [resultTimeData,subRoutesTime] = analTimeFreqData_v2(uniqueUsers([selectedUsersCriteria{:,1}]),metricSplitTime,metricTime,selectedDataTime,selectRoute); %Perform Statistics

            %Click
            [~,~,selectedDataClickTrans,~] = searchCritera(userDataTrans,uniqueUsers,selectedUsers,deviceData,paramTable.Data,dateInclTable.Data); %Sort Data
            [dataStartInput.String,dataEndInput.String,selectedDataClickUser,criteriaUsers] = searchCritera(userDataClick,uniqueUsers,selectedUsers,deviceData,paramTable.Data,dateInclTable.Data); %Sort Data
            selectedUsersCriteria = num2cell(ismember(uniqueUsers,criteriaUsers)); %Update selectedUsers
            [resultClickData,subRoutesClick] = analClickData_v2(uniqueUsers([selectedUsersCriteria{:,1}]),metricSplitClick,metricClick,selectedDataClickUser,selectedDataClickTrans,selectRoute); 

            %Frequency 
            [dataStartInput.String,dataEndInput.String,selectedDataFreq,criteriaUsers] = searchCritera(userDataTime,uniqueUsers,selectedUsers,deviceData,paramTable.Data,dateInclTable.Data); %Sort Data
            selectedUsersCriteria = num2cell(ismember(uniqueUsers,criteriaUsers)); %Update selectedUsers
            [resultFreqData,subRoutesFreq] = analTimeFreqData_v2(uniqueUsers([selectedUsersCriteria{:,1}]),metricSplitFreq,metricFreq,selectedDataFreq,selectRoute);

            if ~isempty(resultTimeData) && nansum([resultTimeData{:,2}]) > 0

                %Time
                hTableDataTime.ColumnName = [{'All Route'},{'Sub Route'},{metricSplitTime},{'STD'},{'SEM'},{'# Users'}]; %Create headers for table
                hTableDataTime.Data = resultTimeData(:,1:6); % route name, metric, number of observations
                %Click
                hTableDataClick.ColumnName = [{'All Route'},{'Sub Route'},{metricSplitClick},{'STD'},{'SEM'},{'# Users'}]; %Create headers for table
                hTableDataClick.Data = resultClickData(:,1:6); % route name, metric, number of observations 

                %Freq
                hTableDataFreq.ColumnName = [{'All Route'},{'Sub Route'},{metricSplitFreq},{'STD'},{'SEM'},{'# Users'}]; %Create headers for table
                hTableDataFreq.Data = resultFreqData(:,1:6); % route name, metric, number of observations 

                %{
                plotAx = figure; 

                %Create Graph
                
                if ~isempty(resultTimeData(:,3:5))
                    dataAx1 = subplot(3,1,1);
                    generateGraph_v3(dataAx1,resultTimeData(:,3:5),subRoutesTime,metricSplitTime); % generate the graph
                end
                
                if ~isempty(resultClickData(:,3:5))
                    dataAx2 = subplot(3,1,2);
                    generateGraph_v3(dataAx2,resultClickData(:,3:5),subRoutesClick,metricSplitClick); % generate the graph
                end
                
                if ~isempty(resultFreqData(:,3:5))
                    dataAx3 = subplot(3,1,3);
                    generateGraph_v3(dataAx3,resultFreqData(:,3:5),subRoutesFreq,metricSplitFreq); % generate the graph
                end
                %}
                
                exportDataButton_Callback; %Call export for each MainRoute - used to help Jerry 

                fprintf("Complete\n");  
            else % if empty, print message
                hMessageErrorData.Visible = 'on';
                fprintf('No result data %d\n',countNoData); 
                countNoData = countNoData + 1; %increment
            end  
        else % if empty, print message
            hMessageErrorData.Visible = 'on';
            fprintf('No result data %d\n',countNoData); 
            countNoData = countNoData + 1; %increment
        end     
    end
end

%% Date Selection

% % ------------------ Generate Time Inclusion --------------------------------- 
function generateStartButton_Callback(source,eventdata)
    
    hMessageErrorDataExists.Visible = 'off'; %Turn off error message
    hMessageErrorDateData.Visible = 'off'; %Turn off error message
   
    try
        if isempty(inpStartDateInput.String) || isempty(inpEndDateInput.String)
            hMessageErrorDateData.Visible = 'on'; %Turn on error message
        elseif ~isempty(dateInclTable.Data)
            fprintf('Date: %s\n',datetime(inpStartDateInput.String,'InputFormat','dd-MM-yyyy HH:mm:ss'));
            fprintf('Date: %s\n',datetime(inpEndDateInput.String,'InputFormat','dd-MM-yyyy HH:mm:ss'));
            %Update Date table
            if isempty(find(strcmp(dateInclTable.Data(:,1),inpStartDateInput.String) + strcmp(dateInclTable.Data(:,2),inpEndDateInput.String) == 2, 1)) %check whether an identical start and end time already exists in the table
                dateInclTable.Data = [{inpStartDateInput.String},{inpEndDateInput.String},{true},{false};dateInclTable.Data]; %Show all users 
            else
                hMessageErrorDataExists.Visible = 'on'; %Turn on error message
            end
        else %Write to table since it is empty, no need to check for uniqueness
            dateInclTable.Data = [{inpStartDateInput.String},{inpEndDateInput.String},{true},{false};dateInclTable.Data]; %Show all users 
        end
    catch
        inpStartDateInput.String = 'dd-mm-yyyy hh:mm:ss'; %Reset
        inpEndDateInput.String = 'dd-mm-yyyy hh:mm:ss'; %Reset   
        hMessageErrorDateData.Visible = 'on'; %Turn on error message
    end
       
end

% ------------------ Delete All Users - Date Inclusion Table --------------------------------- 
function deleteDate_Callback(source,eventdata)
    % deselect all Users, no analysis
    % Empty all checkboxes
    try
        dateInclTable.Data([dateInclTable.Data{:,end}],:) = [];
    catch
       disp('Error'); 
    end
end

%% Parameter Selection

% ------------------ Select All Users ---------------------------------
function selectAllParam_Callback(source,eventdata)
    % select all Users for analysis
    %Fill all checkboxes
    paramTable.Data(:,2) = {true}; % update the user table
    
end
% ------------------ Deselect All Users --------------------------------- 
function deselectAllParam_Callback(source,eventdata)
    % deselect all Users, no analysis
    % Empty all checkboxes
    paramTable.Data(:,2) = {false};
end

% ---------------- Select and Deselect Users -----------------------------
function paramDependentData(source,eventdata)
    % Add to a criteria list - Table
    
end

function dataParam_Callback(source,eventdata)
    % Create Parameter for users
    str = source.String;
    val = source.Value; 
    posCritera = getpixelposition(dataParamCriteraDrop,true); %Find pixel coordinate relative to figure. 
    %Find Critera based on users Param choice
    CriteraDropDown = unique(cellfun(@num2str,deviceData.(str{val}),'uni',0)); %Finds unique values of cell, turns numbers in strings then back into numbers since 'unqiue' only works on character cells
    paramDropDown = str(val); 
    if ~isempty([CriteraDropDown{:}]) || sum([CriteraDropDown{:}]) == 0
        hMessageErrorCriteriaNoData.Visible = 'off'; %Turn off error message
        delete(dataParamCriteraDrop); %Replace Critera list with updated Critera list
        %Create new drop down
        dataParamCriteraDrop = uicontrol('Style','popupmenu','String',CriteraDropDown,...
            'Position',posCritera,'Callback',@criteriaSelection_Callback,'Units','normalized');   
    else
        hMessageErrorCriteriaNoData.Visible = 'on'; %Turn on error message
    end
end

function criteriaSelection_Callback(source,eventdata)
    % Add critera to list
    hMessageErrorCriteriaExists.Visible = 'off'; %Turn off error message
    if isempty(paramTable.Data)
        %Table is empty, write to table
        paramTable.Data = [paramDropDown,source.String(source.Value),true;paramTable.Data];  %Write to table
    elseif isempty(find(strcmp(paramTable.Data(:,1),paramDropDown) + strcmp(paramTable.Data(:,2),source.String(source.Value)) == 2, 1))
        paramTable.Data = [paramDropDown,source.String(source.Value),true;paramTable.Data];  %Write to table 
    else
        fprintf('The parameter is not unique\n'); %Display message to user saying that the entry already exists
        hMessageErrorCriteriaExists.Visible = 'on'; %Turn off error message
    end
    
end

%% User Selection

% ------------------ Select All Users ---------------------------------
function selectAllUser_Callback(source,eventdata)
    % select all Users for analysis
    %Fill all checkboxes
    selectedUsers(:,1) = {true}; %update - select all users  == 1
    userSelectionTable.Data = [uniqueUsers,selectedUsers]; % update the user table
    
    generateMetricButton_Callback(source,eventdata); %call function
end
% ------------------ Deselect All Users --------------------------------- 
function deselectAllUser_Callback(source,eventdata)
    % deselect all Users, no analysis
    % Empty all checkboxes
    selectedUsers(:,1) = {false}; %update - deselect all users == 0
    userSelectionTable.Data = [uniqueUsers,selectedUsers];
    hTableDataTime.Data = {};
    hTableDataClick.Data = {};
    hTableDataFreq.Data = {};
    
    cla; %Clear are data
end

% ---------------- Select and Deselect Users -----------------------------
function userDependentData(source,eventdata)
    % Update select/deselected users
    selectedUsers(:,1) = userSelectionTable.Data(:,2); % convert to matrix   
end


%% Export 
%NEEDS EDITING

% ------------------ Data Button ---------------------------------
function exportDataButton_Callback(source,eventdata)
    %Write to output excel file
    %fromat = XLSWRITE(FILE,ARRAY,SHEET,RANGE)
    %Create folder of result output
    fprintf('Export initiated ...\n');
    resultsFolder = 'Results';
    splitOutput = strsplit(outputDir,'\');
    fileName = horzcat('Output_Data_',currentAppValue,'.xlsx'); %Output_Data_R2MR or _CAT
    splitName = strsplit(currentMetricValue,' ');
    sheetName = horzcat(selectRoute,'-',currentMetricTypeValue,'-',splitName{1}); %Sheet Name
    sheetName = strrep(sheetName,' ','-'); %Remove colon so we can write as sheetname in excel
    
    %Check if "Results" folder was selected, if not - create a new folder
    %called "Results"
    if ~exist(horzcat(outputDir,'\',resultsFolder),'dir') && ~(strcmp(splitOutput{end},resultsFolder))
         sucessFolder = mkdir(outputDir,resultsFolder);
         outputFile = horzcat(outputDir,'\',resultsFolder,'\',fileName);
         fullImName = horzcat(outputDir,resultsFolder,'\',sheetName); %File name
         if sucessFolder
            fprintf('Created folder: %s\n',resultsFolder);
         else
            fprintf('Did not create folder: %\n', resultsFolder);
         end
    else
        outputFile = horzcat(outputDir,'\',fileName);
        fullImName = horzcat(outputDir,'\',sheetName); %Full file name, ready for .pdf, .eps
    end
      
    if exist(outputFile,'file')
       %Check if sheet name already exists
       [~,allSheetsNames] = xlsfinfo(outputFile);
       %Check for unique file name
       strCheck = contains(allSheetsNames,sheetName);
       if any(strCheck)
          numFile = length(find(strCheck == 1)) + 1;                       
          sheetName = horzcat(sheetName,'-',num2str(numFile)); 
          fullImName = horzcat(fullImName,'-',num2str(numFile)); 
       end
    end
    
    %Account for all tables
    splitMetric = strsplit(currentMetricValue,' ');
    splitMetric{2} = 'METRIC';
    splitMetric = strjoin(splitMetric,' ');
    xlswrite(outputFile,{'Route',selectRoute,'Type','All', 'Metric',splitMetric},sheetName,'A1:F1'); %Write Route,Type,Metric
    %Combine all data tables into one
%     allDataTable = [hTableDataTime.ColumnName'; hTableDataTime.Data; ...
%         hTableDataClick.ColumnName'; hTableDataClick.Data; ...
%         hTableDataFreq.ColumnName'; hTableDataFreq.Data];

    dataTime = [hTableDataTime.ColumnName'; hTableDataTime.Data];
    dataClick = [hTableDataClick.ColumnName'; hTableDataClick.Data];
    dataFreq = [hTableDataFreq.ColumnName'; hTableDataFreq.Data];
    
    
    tableSzTime = 2 + size(dataTime,1); 
    xlswrite(outputFile,dataTime,sheetName, ... 
        horzcat('A3',':F',num2str(tableSzTime))); %Write Data Table
    
    tableSzClick = 2 + size(dataClick,1); 
    xlswrite(outputFile,dataClick,sheetName, ... 
        horzcat('H3',':M',num2str(tableSzClick))); %Write Data Table
    
    tableSzFreq = 2 + size(dataFreq,1); 
    xlswrite(outputFile,dataFreq,sheetName, ... 
        horzcat('O3',':T',num2str(tableSzFreq))); %Write Data Table
          
    xlswrite(outputFile,[userSelectionTable.ColumnName';userSelectionTable.Data([userSelectionTable.Data{:,2}],:)],sheetName, ... 
        horzcat('V3:W',num2str(2+size(userSelectionTable.Data([userSelectionTable.Data{:,2}]),2)))); %Write User Selected Table
    
    if ~isempty(paramTable.Data)
        xlswrite(outputFile,[paramTable.ColumnName';paramTable.Data([paramTable.Data{:,3}],:)], sheetName, ... 
            horzcat('X3:Z',num2str(2+size(paramTable.Data([paramTable.Data{:,3}]),2)))); %Write Param Table
    end
    
    if ~isempty(dateInclTable.Data)
        xlswrite(outputFile,[dateInclTable.ColumnName';dateInclTable.Data([dateInclTable.Data{:,3}],:)], ... 
            horzcat('AB3:AE',num2str(2+size(dateInclTable.Data([dateInclTable.Data{:,3}]),2)))); %Write Inclusion Time Table
    end
    
            
    %Export figure of graphs 
    %{
    if isempty(plotAx.Children)
        plotAx.Units = 'pixels'; 
        pos = plotAx.Position; 
        %Change the axes units to pixels and store the Position and TightInset property values for the axes. 
        %The TighInset property is a four-element vector of the form [left bottom right top]. 
        %The values are the margins used around the axes for the tick values and text labels.
        ti = plotAx.TightInset;
        %Create a four-element vector, rect, that defines a rectangular area covering the axes plus the automatically calculated margin. 
        %The first two elements of rect specify the lower left corner of the rectangle relative to the lower left corner of the axes. 
        %The last two elements of rect specify the width and height of the rectangle.
        rect = [-ti(1), -ti(2), pos(3)+ti(1)+ti(3), pos(4)+ti(2)+ti(4)];
        F = getframe(plotAx,rect);
        h = figure;
        set(h,'visible','off','Color', 'white');
        imshow(F.cdata);
        print(h,'-depsc2','-painters','-r1000',fullImName); %add to .eps
    %     print(h,'-dpdf','-painters','-r1000','-bestfit',horzcat(outputDir,'\ExportIM\',sheetName)); %add to .pdf
    %     print(h,'-djpeg','-r1000',horzcat(fileName,'.jpg')); %add to .jpg    
        print(h,'-dpng','-painters','-r1000',fullImName); %add to .png
    end
    %}
    
    %Copy Main matlab GUI figure to excel;
    f2=copyobj(f,0);
    set(f2,'visible','off');
    %Find size of f2
    f2.Units = 'pixels';
    posF2 = get(f2, 'Position');
    %Write image of figure to specified cell
    xlsPasteTo(f2,outputFile,sheetName,posF2(3),posF2(4),'O20'); %Print Entire Figure - used for reference
    
    fprintf('... Data transfer to Excel completed\n');

    
end

end
