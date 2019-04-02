function [timeSpanMin,timeSpanMax,selectedData,criteriaUsers] = searchCritera(userData,uniqueUsers,selectedUsers,deviceData,paramTable,dateInclTable)
    
%{
    Inputs:
    - 

    Outputs:
    - Find max and min times of new data set

%}  

% disp(datetime(inpStartDateInput.String,'InputFormat','dd-MM-yyyy HH:mm:ss'));
% disp(datetime(inpEndDateInput.String,'InputFormat','dd-MM-yyyy HH:mm:ss'))
if (isempty(paramTable) || ~any([paramTable{:,end}] == 1)) && (isempty(dateInclTable) || ~any([dateInclTable{:,end-1}] == 1))
    %No criteria to evaluate
    %Set output - same as input
    selectedData = userData; 
    timeSpanMin = min([selectedData.time]);
    timeSpanMax = max([selectedData.time]);
    criteriaUsers = uniqueUsers([selectedUsers{:,1}]); %No Change
     
elseif (isempty(paramTable) || ~any([paramTable{:,end}] == 1)) && (~isempty(dateInclTable) || any([dateInclTable{:,end-1}] == 1)) %Param empty, Time Included not empty
    %Find time that is within time span 
    timeIndInclude = [];
    selDataInclTable = dateInclTable(ismember([dateInclTable{:,3}],1)',1:2);
    for i = 1:size(selDataInclTable,1)
        timeIndTemp = find([userData.time] > datetime(selDataInclTable(i,1),'TimeZone','local','InputFormat','dd-MM-yyyy HH:mm:ss') & ... 
            [userData(:).time] < datetime(selDataInclTable(i,2),'TimeZone','local','InputFormat','dd-MM-yyyy HH:mm:ss')); %Find min val of time 
        timeIndInclude = unique([timeIndInclude,timeIndTemp]); %Index of all time data to include, fits within included data time span 
    end
    %Set output
    selectedData = userData(timeIndInclude); 
    timeSpanMin = min([selectedData(:).time]);
    timeSpanMax = max([selectedData(:).time]);
    criteriaUsers = uniqueUsers([selectedUsers{:,1}]); %No Change
    
elseif (~isempty(paramTable) || any([paramTable{:,end}] == 1)) && (isempty(dateInclTable) || ~any([dateInclTable{:,end-1}] == 1)) %Parameter not empty, Time Included empty
    %Set all included criteria
    include.Param = paramTable(([paramTable{:,3}] == 1)',1);
    include.Criteria = paramTable(([paramTable{:,3}] == 1)',2);
    %Find Users that fit criteria
    indSame = zeros(size(deviceData,1),size(include.Param,1)); %initialize
    for i = 1:size(include.Param,1) 
        if strcmp(include.Criteria{i,1},'NaN') %NaN == No Response
            %The user didn't enter a value for this Parameter. Still want
            %to include search with these users
            indSame(:,i) = strcmp(cellfun(@num2str, deviceData.baseline_4d, 'UniformOutput', false),'NaN');
        elseif ~isnan(str2double(include.Criteria{i,1})) %Num
            %Means a number was converted into a string so that it could be
            %entered into the table. We need to switch is back to a num so
            %that we can find it in the Param table.
            tempNum = str2double(include.Criteria{i,1});
            indSame(:,i) = (str2double(deviceData.(include.Param{i,1}){:}) == tempNum || deviceData.(include.Param{i,1}) == tempNum)'; %Create list of users that meet the criteria     
        else %String
            %The criteria is a string, search for string in Param Table
            indSame(:,i) = strcmp(deviceData.(include.Param{i,1}),include.Criteria(i,1))'; %Create list of users that meet the criteria
        end
    end
    %Take all users that have a matrix value greater than zero. Means they
    %have met one or more of the criteria. 
    %Selection criteria is such that a user will be included if they match one of the
    %criteria.
    %Change selectedUsers
    criteriaUsers = uniqueUsers(sum(indSame,2) > 0 & [selectedUsers{:,1}]' > 0); %use to determine the users that are within the criteria 
    %Edit the data
    selectedData = userData(ismember({userData.userID},criteriaUsers)); 
    timeSpanMin = min([selectedData.time]);
    timeSpanMax = max([selectedData.time]); 
    
    
else 
    %Both param and data include tables are not empty
    %TIME Component
    timeIndInclude = [];
    selDataInclTable = dateInclTable(ismember([dateInclTable{:,3}],1)',1:2);
    for i = 1:size(selDataInclTable,1)
        timeIndTemp = find([userData.time] > datetime(selDataInclTable(i,1),'TimeZone','local','InputFormat','dd-MM-yyyy HH:mm:ss') & ... 
            [userData.time] < datetime(selDataInclTable(i,2),'TimeZone','local','InputFormat','dd-MM-yyyy HH:mm:ss')); %Find min val of time 
        timeIndInclude = unique([timeIndInclude,timeIndTemp]); %Index of all time data to include, fits within included data time span 
    end
    %Set output for TIME
    selectedData = userData(timeIndInclude);
    
    %PARAM Compenent
    %Set all included criteria
    include.Param = paramTable(([paramTable{:,3}] == 1)',1);
    include.Criteria = paramTable(([paramTable{:,3}] == 1)',2);
    %Find Users that fit criteria
    indSame = zeros(size(deviceData,1),size(include.Param,1)); %initialize
    for i = 1:size(include.Param,1) 
        if strcmp(include.Criteria{i,1},'NaN') %NaN == No Response %NaN == No Response
            %The user didn't enter a value for this Parameter. Still want
            %to include search with these users
            indSame(:,i) = strcmp(cellfun(@num2str, deviceData.baseline_4d, 'UniformOutput', false),'NaN');
        elseif ~isnan(str2double(include.Criteria{i,1})) %Num
            %Means a number was converted into a string so that it could be
            %entered into the table. We need to switch is back to a num so
            %that we can find it in the Param table.
            tempNum = str2double(include.Criteria{i,1});
            indSame(:,i) = ([deviceData.(include.Param{i,1}){:}] == tempNum)'; %Create list of users that meet the criteria     
        else %String
            %The criteria is a string, search for string in Param Table
            indSame(:,i) = strcmp(deviceData.(include.Param{i,1}),include.Criteria(i,1))'; %Create list of users that meet the criteria
        end
    end
    %Take all users that have a matrix value greater than zero. Means they
    %have met one or more of the criteria. 
    %Selection criteria is such that a user will be included if they match one of the
    %criteria.
    %Change selectedUsers
    criteriaUsers = uniqueUsers(sum(indSame,2) > 0 & [selectedUsers{:,1}]' > 0); %use to determine the users that are within the criteria 
    %Edit the data
    selectedData = selectedData(ismember({selectedData.userID},criteriaUsers)); 
    timeSpanMin = min([selectedData(:).time]);
    timeSpanMax = max([selectedData(:).time]); 
    
end

%Convert to string so it can be entered in text box
timeSpanMin = datestr(timeSpanMin); 
timeSpanMax = datestr(timeSpanMax);


end

