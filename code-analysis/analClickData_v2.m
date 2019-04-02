function [resultClickData,subRoutes,subRoutesParse] = analClickData_v2(selectedUsers,currentMetricValue,metric,userClickData,userTransData,selectRoute)

%% Per page analysis
%Now that the click data and trans data has been sorted by time, lets match
%up clicks with the page they occured on
%Find ind for Time and Users that have been selected

%% Search for specific Routes

%Find all routes 
allRoutes = unique(cellfun(@num2str,{userTransData.currFromPage,userTransData.currToPage},'uni',0)); 
%Find all subroutes
indMainRoute = strcmp(regexp(allRoutes, '[^.]+(?<=.)', 'match', 'once'),selectRoute);
subRoutes = allRoutes(indMainRoute);

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

%Initialize
pageCurr = {}; 
pageMain = {};
pageSame = {};
indClickTotal = zeros(1,length({userClickData.userID}));
%Find the time between each transition and pause
for a = 1:size(selectedUsers,1) %num users
    %Seperate Click data
    indClick = strcmp({userClickData.userID}, selectedUsers{a,1});
    indClickTotal = (indClickTotal + indClick) > 0; %Total indices to include with all users data
    if sum(indClick) > 0
        userOnlyClick = cell2struct({userClickData(indClick).time;userClickData(indClick).userID}, ...
            {'time','userID'},1);
        %Seperate Transition data
        indTrans = strcmp({userTransData.userID}, selectedUsers{a,1});
        userOnlyTrans = cell2struct({userTransData(indTrans).time;userTransData(indTrans).currFromPage; ...
            userTransData(indTrans).pageFromMain;userTransData(indTrans).currToPage; ...
            userTransData(indTrans).pageToMain;userTransData(indTrans).userID}, ...
            {'time','currFromPage','pageFromMain','currToPage','pageToMain','userID'},1);
        countTrans = 1; %Counter for next traversing time
        pageChange = 1; %first page entry
        flag = 1; %Used for last transition to designate first entry into page. Change to 0 after first entry
        for b = 1:size({userOnlyClick.time},2)
            if etime(datevec(userOnlyTrans(countTrans).time),datevec(userOnlyClick(b).time)) > 0 %transition time - Click time, therefore tran>click
                %If positive, then trans>click, means take *from* of the trans
                %and enter it for that click
                pageCurr = [pageCurr; userOnlyTrans(countTrans).currFromPage];
                pageMain = [pageMain; userOnlyTrans(countTrans).pageFromMain];
                pageSame = [pageSame;pageChange];
                pageChange = 0; %change page to zero, not first page entry        
            else
                % If negative, trans<click, means check the next trans
                % is bigger, so increment count and do the same as the if 
                if countTrans + 1 <= size({userOnlyTrans.time},2)
                    countTrans = countTrans + 1; %increment counter
                    pageCurr = [pageCurr; userOnlyTrans(countTrans).currFromPage];
                    pageMain = [pageMain; userOnlyTrans(countTrans).pageFromMain];
                    if strcmp(userOnlyTrans(countTrans).pageFromMain,userOnlyTrans(countTrans).pageToMain)
                        pageSame = [pageSame;pageChange]; %In the same main page
                        pageChange = 0;
                    else
                        if b > 1 %Perform change before adding new entry
                            pageSame{end} = 1; %Last page of that route
                        end
                        pageSame = [pageSame;1]; %Entered new main page                    
                    end
                else
                    %Negative and last transition recorded, take from the To
                    %page cuz that is where we are now
                    pageCurr = [pageCurr; userOnlyTrans(countTrans).currToPage];
                    pageMain = [pageMain; userOnlyTrans(countTrans).pageToMain];
                    if flag == 1
                        if b > 1 %Perform change before adding new entry
                            pageSame{end} = 1; %Last page of that route
                        end
                        pageSame = [pageSame;1]; %Entered new main page
                        flag = 0; %not new page after this first entry
                    else
                        pageSame = [pageSame;0]; %In the same main page
                    end
                end
            end
        end
    end
end

%Set var names so easier to read when calling userClickPage structure
if sum(indClickTotal) > 0
    time = [userClickData(indClickTotal).time]';
    type = {userClickData(indClickTotal).type}';
    posX = [userClickData(indClickTotal).posX]';
    posY = [userClickData(indClickTotal).posY]';
    target = {userClickData(indClickTotal).target}';
    userID = {userClickData(indClickTotal).userID}';

    compT = table(time,type,posX,posY,target,pageCurr,pageMain,pageSame,userID);
    userClickPage = table2struct(sortrows(compT,1),'ToScalar',true); % Sort events by timestamp and convert to a cell structure
else
    userClickPage = []; %Empty case, no data
end

%% Analyse Data - CLICK
%Let's now create an output with all the desired metrics
%Parameters users can pick
%routes = {'Select','sub-apps','attention-control','continuum','goal-setting','index','memory','self-talk','settings','tactical-breathing','visualization'};
%metricClick = {'Select','Total Clicks','Average click per user','Average click per visit','Average click per visit per user'}; %Defines metrics that could be analyzed
   
%selectRoute = 'sub-apps';
%currentMetricValue = 'Total time';

%% Calculate Metrics

%Define size of variable
%{
%metricTime = {'Select','Total time','Average time per user','Average time per page visit','Average time per visit per user','Percentage of clicks on sub-app'};
Metrics will follow this order of setup: 

For R2MR 
routeSubApp = {'Select','sub-apps','attention-control','continuum','goal-setting','index','memory','self-talk','settings','tactical-breathing','visualization'};
totalTime(1) = all Apps
totalTime(2) = attention-control
totalTime(3) = continuum
totalTime(4) = goal-setting
totalTime(5) = index
totalTime(6) = memory
totalTime(7) = self-talk
totalTime(8) = settings
totalTime(9) = tactical-breathing
totalTime(10) = visualization

For CAT
routeSubApp = {'Select','sub-apps','briefing-tools','country-guide','feedback','info','index','latvia','lessons-learned','notes','rbm-vs-opp','rle','scenario-development','settings','terminology','training-education'};
totalTime(1) = all Apps
totalTime(2) = briefing-tools
totalTime(3) = country-guide
totalTime(4) = feedback
totalTime(5) = info
totalTime(6) = index
totalTime(7) = latvia
totalTime(8) = lessons-learned
totalTime(9) = notes
totalTime(10) = visualization
totalTime(11) = rbm-vs-opp
totalTime(12) = rle
totalTime(13) = scenario-development
totalTime(14) = settings
totalTime(15) = terminology
totalTime(16) = training-education
%}
if ~isempty(userClickPage) %Make sure there is data
    %Find metrics for each user and list in cell array table
    for c = 1:size(selectedUsers,1) %Go through each user

        %Search for index based on user 
        indUser = find(strcmp([userClickPage.userID], selectedUsers{c,1}));
        %Remove data and put into another table
        userClicks = cell2struct({userClickPage.userID(indUser);
            userClickPage.time(indUser);userClickPage.type(indUser); ...
            userClickPage.posX(indUser);userClickPage.posY(indUser); ...
            userClickPage.target(indUser); userClickPage.pageCurr(indUser); ...
            userClickPage.pageMain(indUser);userClickPage.pageSame(indUser)}, ...
            {'userID','time','type','posX','posY','target','pageCurr','pageMain','pageSame'},1);
        %Change currPage to only include first page, not worried about sup-apps
        %within page
    %     userClicks.pageMain = regexp(userClicks.currPage, '[^.]+(?<=.)', 'match', 'once'); %need userClick to be scalar so that we can search page names

        for r = 1:size(subRoutes,2) %Go through each route for that sub-app

            %Calculate total time of user
            indRoute = strcmp(userClicks.pageCurr,subRoutes(r)); %Find indexes of routeSubApp

            %Input User ID
            outputClick.userID(c,1) = selectedUsers(c,1); 
            %Total clicks used in sub-app by user
            outputClick.totalClicksSum(c,r) = sum(indRoute);         
            %Calculate Average Click Per Page Visit
            outputClick.avgClickPerPage(c,r) = sum(indRoute);
            %Find 1's, subtract the times at each 1. If there is no one,
            %subtract the last value. 
            indSame = find([userClicks.pageSame{indRoute}] == 1);
    %         outputClick.avgClickPerPage(c,r) = mean([userClicks.timeDiff{indRoute}]);

        end   
    end

    %Post analaysis after all values have been calculates
    for numUser = 1:size(selectedUsers,1) %Go through each user
        for numRoute = 1:r %number of routes
            %Percent of time spent on a page relative to the other pages
            outputClick.totalClickPagePercent(numUser,numRoute) = outputClick.totalClicksSum(numUser,numRoute)/sum(outputClick.totalClicksSum(numUser,:)); 
        end
    end

    resultClickData = cell(size(subRoutes,2),8);
    % Analyse Data
    for i = 1:size(subRoutes,2)

        %Find index of users selected
        indUser = strcmp(outputClick.userID,selectedUsers(:,1));
        resultClickData(i,1) = {mainRoute}; %All Route name
        resultClickData(i,2) = subRoutesParse(i); %Sub Route name

        % Generate Table with appropriate column names based on metric
        if strcmp(currentMetricValue,metric(1)) %'Total Clicks'
            indNonZeroNaN = (outputClick.totalClicksSum(indUser,i) ~= 0) & ~isnan(outputClick.totalClicksSum(indUser,i)); %Index of non zero inputs
            resultClickData{i,3} = nansum(outputClick.totalClicksSum(indNonZeroNaN,i)); %Value = sum
            resultClickData{i,4} = nanstd(outputClick.totalClicksSum(indNonZeroNaN,i)); %Value = std
            resultClickData{i,5} = nanstd(outputClick.totalClicksSum(indNonZeroNaN,i))/sqrt(length(outputClick.totalClicksSum(indNonZeroNaN,i))); %Value = sem
            resultClickData{i,6} = sum(indNonZeroNaN); %Value = num of users
            resultClickData{i,7} = selectedUsers(indNonZeroNaN,1); %Value = users in data
            resultClickData{i,8} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data
        elseif strcmp(currentMetricValue,metric(2)) %'Average clicks per user'
            indNonZeroNaN = (outputClick.totalClicksSum(indUser,i) ~= 0) & ~isnan(outputClick.totalClicksSum(indUser,i)); %Index of non zero inputs
            resultClickData{i,3} = nanmean(outputClick.totalClicksSum(indNonZeroNaN,i)); %Value = sum
            resultClickData{i,4} = nanstd(outputClick.totalClicksSum(indNonZeroNaN,i)); %Value = std
            resultClickData{i,5} = nanstd(outputClick.totalClicksSum(indNonZeroNaN,i))/sqrt(length(outputClick.totalClicksSum(indNonZeroNaN,i))); %Value = sem
            resultClickData{i,6} = sum(indNonZeroNaN); %Value = num of users
            resultClickData{i,7} = selectedUsers(indNonZeroNaN,1); %Value = users - not in table
            resultClickData{i,8} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data - not in table
    %     elseif strcmp(currentMetricValue,metric(3)) %'Average click per visit'
    %         resultClickData{i,2} = nansum(outputClick.avgTimePerPage(indUser,i)); %Value = sum
    %         resultClickData{i,3} = nanstd(outputClick.avgTimePerPage(indUser,i)); %Value = std
    %         resultClickData{i,4} = sum(indUser); %Value = num of users
    %         resultClickData{i,5} = selectedUsers(indUser); %Value = users 
    %     elseif strcmp(currentMetricValue,metric(4)) %'Average click per visit per user'
    %         resultClickData{i,2} = nansum(outputClick.totalTimeSum(indUser,i)); %Value = sum
    %         resultClickData{i,3} = nanstd(outputClick.totalTimeSum(indUser,i)); %Value = std
    %         resultClickData{i,4} = sum(indUser); %Value = num of users
    %         resultClickData{i,5} = selectedUsers(indUser); %Value = users  
        elseif strcmp(currentMetricValue,metric(5)) %'Percentage of clicks on sub-app'
            totalClick = nansum(nansum(outputClick.totalClickPagePercent)); %Total click in all subapps as a percent
            indNonZeroNaN = (outputClick.totalClickPagePercent(indUser,i) ~= 0) & ~isnan(outputClick.totalClickPagePercent(indUser,i)); %Index of non zero inputs
            resultClickData{i,3} = nansum(outputClick.totalClickPagePercent(indNonZeroNaN,i))/totalClick; %Value = sum
            resultClickData{i,4} = nanstd(outputClick.totalClickPagePercent(indNonZeroNaN,i)); %Value = std
            resultClickData{i,5} = nanstd(outputClick.totalClickPagePercent(indNonZeroNaN,i))/sqrt(length(outputClick.totalClickPagePercent(indNonZeroNaN,i))); %Value = sem
            resultClickData{i,6} = sum(indNonZeroNaN); %Value = num of users
            resultClickData{i,7} = selectedUsers(indNonZeroNaN,1); %Value = users
            resultClickData{i,8} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data
        end

    end
else
    resultClickData = cell(size(subRoutes,2),8);
end
    
    
    
