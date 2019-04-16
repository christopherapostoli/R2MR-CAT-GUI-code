function [userDataTime,mainRoutes] = getTimeData_v3(deviceEvents,uniqueUsers)

%% Prepare Data
%Seperate data based on time consideration
% Get details of transition, pause and resume events
desiredEvents = {'transition','pause','resume'};
time= {}; %Need to find starting time
timeStr = {};
type= {};
destination ={};
source = {};
userID = {};

for i = 1:size(deviceEvents,1) % for each device
    for j = 1:size(deviceEvents{i,1},2) % for each event
        if ismember(deviceEvents{i,1}{1,j}.type,desiredEvents) % Check if key 'type' matches desiredEvents 
           % dealing with 'resume' types in which the app started up, so related_user isn't even a field 
           if isfield(deviceEvents{i,1}{1,j},'related_user') 
               if ~isempty(deviceEvents{i,1}{1,j}.related_user) && any(strcmp(deviceEvents{i,1}{1,j}.related_user,uniqueUsers)) % only consider events with users - if it doesn't have one, it's probably startup  % only consider events with users - if it doesn't have one, it's probably startup
                   timeFormatted = format_time(deviceEvents{i,1}{1,j}.timestamp); % format the string timestamp into date and time
                   time = [time; timeFormatted]; %store time
                   timeStr = [timeStr; {datestr(timeFormatted)}]; %add time as string
                   type = [type; deviceEvents{i,1}{1,j}.type]; % store the type of event
                   if strcmp(type(end),'transition') % if it's a transition, log the to and from routeSubApp
                       destination = [destination;deviceEvents{i,1}{1,j}.details.to];
                       % If there is no 'from' (ex. on app startup)
                       try
                           source = [source;deviceEvents{i,1}{1,j}.details.from];
                       catch
                           source = [source;{'index'}];
                       end
                   elseif strcmp(type(end),'pause')
                       destination = [destination;{''}];      
                       source = [source;{''}];
                   elseif strcmp(type(end),'resume')
                       destination = [destination;{''}];
                       source = [source;{''}];
                   end

                   if isfield(deviceEvents{i,1}{1,j},'related_user') % some events (startup of app, or relaunch) don't have a related_user field so we have to make one and fill it in later                  
                       userID = [userID; deviceEvents{i,1}{1,j}.related_user];
                   else
                       deviceEvents{i,1}{1,j}.related_user = 'resumeUser';
                       userID = [userID; deviceEvents{i,1}{1,j}.related_user]; 
                   end
               end
           end
        end
    end     
end


% eventLog: cell array containing timestamp, time, to and from for each event sorted in chronological order
T = table(time,type,source,destination,userID,timeStr);
T = sortrows(T,1); 
[~,unqRows,~] = unique(T(:,2:6),'first');
T = T(unqRows,:); %Sort then take onl unique rows, remove duplicates
T = sortrows(T,1); 
%Find all 'pause' that are empty and enter previous 'transition' location 
%for  destination as source and destination 
%call again for instances where 'pause' and 'resume' repeat three times within a span of one second
for no = 1:4
    indPause = find(strcmp(T.type(:),'pause') == 1); %Enter all the missing data for 'resume' and 'pause' based on transition    
    T.source(indPause) = T.destination(indPause - 1);
    T.destination(indPause) = T.destination(indPause - 1);
    %Find all 'resume' that are empty and enter previous 'transition' or 'pause' location 
    %for  destination as source and destination 
    indResume = find(strcmp(T.type(:),'resume') == 1); %Enter all the missing data for 'resume' and 'pause' based on transition    
    T.source(indResume) = T.destination(indResume - 1);
    T.destination(indResume) = T.destination(indResume - 1);
end

% Sort events by timestamp and convert to a cell structure
userDataTime = table2struct(T); 
 
%% Find Routes entered by User

%Find all routes 
allRoutes = unique(cellfun(@num2str,{userDataTime.destination},'uni',0));

%Extract main route
mainRoutes = unique(cellfun(@num2str,regexp(allRoutes, '[^.]+(?<=.)', 'match', 'once'),'uni',0)); 


end