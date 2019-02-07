function [resultTimeFreqData,subRoutes] = analTimeFreqData_v2(selectedUsers,currentMetricValue,metric,userTimeData,selectRoute)
%% Analyse Data - TIME
%Let's now create an output with all the desired metrics
%Parameters users can pick
%routeSubApp = {'Select','sub-apps','attention-control','continuum','goal-setting','index','memory','self-talk','settings','tactical-breathing','visualization'};
%metricTime = {'Select','Total time','Average time per user','Average time per visit','Average time per visit per user','Percentage of time on sub-app'};
%selectRoute = 'sub-apps';
%currentMetricValue = 'Total time';

%Find ind for Time and Users that have been selected
%% Search for specific Routes

%Find all routes 
allRoutes = unique(cellfun(@num2str,{userTimeData.destination},'uni',0));
%Find all subroutes
indMainRoute = strcmp(regexp(allRoutes, '[^.]+(?<=.)', 'match', 'once'),selectRoute);
subRoutes = allRoutes(indMainRoute);

%% Per page analysis

%initialize
currPage = {};
timeOn = {};
userID = {};
index = {};

%Find the time between each transition and pause
for a = 1:size(selectedUsers,1) %num users
    
    %Extract just that users data
    indUser = (strcmp({userTimeData.userID}, selectedUsers{a,1}));
    if sum(indUser) > 0
        %Remove data and put into another table
        userOnlyTime = userTimeData(indUser);

        for b = 2:size(userOnlyTime,1) %num data
            if strcmp(userOnlyTime(b).type,'transition') %Transition  
                %Check dates to see if time falls on the next day
                [y1,m1,d1] = ymd(userOnlyTime(b-1).time); 
                [y2,m2,d2] = ymd(userOnlyTime(b).time);
                if ~any([y1,m1,d1] - [y2,m2,d2]) %want same day times, if [0 0 0], then it's same day. Invert to pass the if statement.
                    timeOn = [timeOn;etime(datevec(userOnlyTime(b).time),datevec(userOnlyTime(b-1).time))]; %Take the current time of transition and subract it from the time you entered the page
                    currPage = [currPage;userOnlyTime(b).source]; % record the page the user transitioned *from*
                    userID = [userID;userOnlyTime(b).userID]; %user id 
                    index = [index; b];
                end
            elseif strcmp(userOnlyTime(b).type,'Pause') %Pause
                [y1,m1,d1] = ymd(userOnlyTime(b-1).time); 
                [y2,m2,d2] = ymd(userOnlyTime(b).time);
                if etime(datevec(userOnlyTime(b).time),datevec(userOnlyTime(b-1).time)) > 1 && ~any([y1,m1,d1] - [y2,m2,d2])
                    timeOn = [timeOn;etime(datevec(userOnlyTime(b).time),datevec(userOnlyTime(b-1).time))]; %Take the current time of transition and subract it from the time you entered the page
                    currPage = [currPage;userOnlyTime(b-1).destination]; % record the page the user transitioned *from*
                    userID = [userID;userOnlyTime(b-1).userID]; %user id
                    index = [index; b];
                end
            end
        end
    end
end
%Make into table
pageT = table(userID,currPage,timeOn,index);
%Filter based on subRoutes
indSubRoutes = contains(pageT.currPage,selectRoute);
%***Output***
perPageTime = table2struct(pageT(indSubRoutes,:),'ToScalar',true); % then convert to struct to better access cells
% perPageTime = table2struct(pageT,'ToScalar',true); % then convert to struct to better access cells

%% Calculate Metrics

%Define size of variable
%{
%metricTime = {'Select','Total time','Average time per user','Average time per page visit','Average time per visit per user'};
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
if ~isempty(perPageTime.userID) %Make sure there is data
    %Find metrics for each user and list in cell array table
    for c = 1:size(selectedUsers,1) %Go through each user

        %Search for index based on user 
        indUser = find(strcmp([perPageTime.userID], selectedUsers{c,1}));
        %Remove data and put into another table
        userTime = cell2struct({perPageTime.userID(indUser);perPageTime.currPage(indUser);perPageTime.timeOn(indUser)},{'userID','currPage','timeOn'},1);

        for r = 1:size(subRoutes,2) %Go through each route for that sub-app

            %Calculate total number of times user was on specified route page
            indRoute = strcmp(userTime.currPage,subRoutes(r)); %Find indexes of routeSubApp

            %Input User ID
            outputTime.userID(c,1) = selectedUsers(c,1); 
            %Total time used in sub-app by user
            outputTime.totalTimeSum(c,r) = sum([userTime.timeOn{indRoute}]);         
            %Calculate Average Time Per Page Visit
            outputTime.avgTimePerPage(c,r) = mean([userTime.timeOn{indRoute}]);

            %Frequency count of page visits
            outputFreq.userID(c,1) = selectedUsers(c,1);
            outputFreq.totalFreqSum(c,r) = sum(indRoute); 
            %Frequency count of average page visit
            outputFreq.avgFreqPerPage(c,r) = mean(indRoute);
        end 
    end

    %Post analaysis after all values have been calculates 
    for numUser = 1:size(selectedUsers,1) %Go through each user
        for numRoute = 1:r %number of routes
            %Percent of time spent on a page relative to the other pages
            outputTime.totalTimePagePercent(numUser,numRoute) = outputTime.totalTimeSum(numUser,numRoute)/sum(outputTime.totalTimeSum(numUser,:)); % TIME
            outputFreq.totalFreqPagePercent(numUser,numRoute) = outputFreq.totalFreqSum(numUser,numRoute)/sum(outputFreq.totalFreqSum(numUser,:)); % Frequency
        end
    end

    if any(contains(metric,'Time'))
        resultTimeFreqData = cell(size(subRoutes,2),4);
        % Analyse Data
        for i = 1:size(subRoutes,2)

            %Find index of users selected
            indUser = strcmp(outputTime.userID,selectedUsers(:,1));
            resultTimeFreqData(i,1) = subRoutes(i); %Route name

            % Generate Table with appropriate column names based on metric
            if strcmp(currentMetricValue,metric(1)) %'Total time'
                indNonZeroNaN = (outputTime.totalTimeSum(indUser,i) ~= 0) & ~isnan(outputTime.totalTimeSum(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = nansum(outputTime.totalTimeSum(indNonZeroNaN,i)); %Value = sum
                resultTimeFreqData{i,3} = nanstd(outputTime.totalTimeSum(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = nanstd(outputTime.totalTimeSum(indNonZeroNaN,i))/sqrt(length(outputTime.totalTimeSum(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users in data
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data
            elseif strcmp(currentMetricValue,metric(2)) %'Average time per user'
                indNonZeroNaN = (outputTime.totalTimeSum(indUser,i) ~= 0) & ~isnan(outputTime.totalTimeSum(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = nanmean(outputTime.totalTimeSum(indNonZeroNaN,i)); %Value = mean
                resultTimeFreqData{i,3} = nanstd(outputTime.totalTimeSum(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = nanstd(outputTime.totalTimeSum(indNonZeroNaN,i))/sqrt(length(outputTime.totalTimeSum(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data
            elseif strcmp(currentMetricValue,metric(3)) %'Average time per visit'
                indNonZeroNaN = (outputTime.avgTimePerPage(indUser,i) ~= 0) & ~isnan(outputTime.avgTimePerPage(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = nansum(outputTime.avgTimePerPage(indNonZeroNaN,i)); %Value = sum
                resultTimeFreqData{i,3} = nanstd(outputTime.avgTimePerPage(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = nanstd(outputTime.avgTimePerPage(indNonZeroNaN,i))/sqrt(length(outputTime.avgTimePerPage(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data
            elseif strcmp(currentMetricValue,metric(4)) %'Average time per visit per user' ****%Needs fixing
                indNonZeroNaN = (outputTime.totalTimeSum(indUser,i) ~= 0) & ~isnan(outputTime.totalTimeSum(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = nansum(outputTime.totalTimeSum(indNonZeroNaN,i)); %Value = sum
                resultTimeFreqData{i,3} = nanstd(outputTime.totalTimeSum(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = nanstd(outputTime.totalTimeSum(indNonZeroNaN,i))/sqrt(length(outputTime.totalTimeSum(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data
            elseif strcmp(currentMetricValue,metric(5)) %'Percentage of time on sub-app'
                indNonZeroNaN = (outputTime.totalTimePagePercent(indUser,i) ~= 0) & ~isnan(outputTime.totalTimePagePercent(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = 100 * nanmean(outputTime.totalTimePagePercent(indNonZeroNaN,i)); %Value = sum
                resultTimeFreqData{i,3} = 100 * nanstd(outputTime.totalTimePagePercent(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = 100 * nanstd(outputTime.totalTimePagePercent(indNonZeroNaN,i))/sqrt(length(outputTime.totalTimePagePercent(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data
            end
        end

    else
        % Analyse Data
        resultTimeFreqData = cell(size(subRoutes,2),4);
        for i = 1:size(subRoutes,2)

            %Find index of users selected
            indUser = strcmp(outputFreq.userID,selectedUsers(:,1));
            resultTimeFreqData(i,1) = subRoutes(i); %Route name

            % Generate Table with appropriate column names based on metric
            if strcmp(currentMetricValue,metric(1)) %'Total Freq'
                indNonZeroNaN = (outputFreq.totalFreqSum(indUser,i) ~= 0) & ~isnan(outputFreq.totalFreqSum(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = nansum(outputFreq.totalFreqSum(indNonZeroNaN,i)); %Value = sum
                resultTimeFreqData{i,3} = nanstd(outputFreq.totalFreqSum(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = nanstd(outputFreq.totalFreqSum(indNonZeroNaN,i))/sqrt(length(outputFreq.totalFreqSum(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users in data
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data 
            elseif strcmp(currentMetricValue,metric(2)) %'Average time per user
                indNonZeroNaN = (outputFreq.totalFreqSum(indUser,i) ~= 0) & ~isnan(outputFreq.totalFreqSum(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = nanmean(outputFreq.totalFreqSum(indNonZeroNaN,i)); %Value = mean
                resultTimeFreqData{i,3} = nanstd(outputFreq.totalFreqSum(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = nanstd(outputFreq.totalFreqSum(indNonZeroNaN,i))/sqrt(length(outputFreq.totalFreqSum(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users in data
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data 
        %     elseif strcmp(currentMetricValue,metric(3)) %'Average time per visit'
        %         resultFreqData{i,2} = nansum(outputFreq.avgFreqPerPage(indUser,i)); %Value = sum
        %         resultFreqData{i,3} = nanstd(outputFreq.avgFreqPerPage(indUser,i)); %Value = std
        %         resultFreqData{i,4} = sum(indUser); %Value = num of users
        %         resultFreqData{i,5} = selectedUsers(indUser); %Value = users 
        %     elseif strcmp(currentMetricValue,metric(4)) %'Average time per visit per user' ****Needs fixing
        %         resultFreqData{i,2} = nansum(outputFreq.avgFreqPerPage(indUser,i)); %Value = sum
        %         resultFreqData{i,3} = nanstd(outputFreq.avgFreqPerPage(indUser,i)); %Value = std
        %         resultFreqData{i,4} = sum(indUser); %Value = num of users
        %         resultFreqData{i,5} = selectedUsers(indUser); %Value = users
            elseif strcmp(currentMetricValue,metric(3)) %'Percentage of time on sub-app'
                indNonZeroNaN = (outputFreq.totalFreqPagePercent(indUser,i) ~= 0) & ~isnan(outputFreq.totalFreqPagePercent(indUser,i)); %Index of non zero inputs
                resultTimeFreqData{i,2} = 100 * nanmean(outputFreq.totalFreqPagePercent(indNonZeroNaN,i)); %Value = sum
                resultTimeFreqData{i,3} = 100 * nanstd(outputFreq.totalFreqPagePercent(indNonZeroNaN,i)); %Value = std
                resultTimeFreqData{i,4} = 100 * nanstd(outputFreq.totalFreqPagePercent(indNonZeroNaN,i))/sqrt(length(outputFreq.totalFreqPagePercent(indNonZeroNaN,i))); %Value = sem
                resultTimeFreqData{i,5} = sum(indNonZeroNaN); %Value = num of users
                resultTimeFreqData{i,6} = selectedUsers(indNonZeroNaN,1); %Value = users in data
                resultTimeFreqData{i,7} = selectedUsers(~indNonZeroNaN,1); %Value = users not in data 
            end

        end  

    end
else 
    resultTimeFreqData = [];
end
end