function [userDataTime,mainRoutes] = getTimeData_v2(deviceEvents,uniqueUsers)

%% Prepare Data
%Seperate data based on time consideration
% Get details of transition, pause and resume events
desiredEvents = {'transition','pause','resume'};
time= {}; %Need to find starting time
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
                   type = [type; deviceEvents{i,1}{1,j}.type]; % store the type of event
                   if strcmp(type(end),'transition') % if it's a transition, log the to and from routeSubApp
                       destination = [destination;deviceEvents{i,1}{1,j}.details.to];
                       % If there is no 'from' (ex. on app startup)
                       try
                           source = [source;deviceEvents{i,1}{1,j}.details.from];
                       catch
                           source = [source;'NaN'];
                       end
                   elseif strcmp(type(end),'pause')
                       destination = [destination;'NaN'];      
                       source = [source;NaN];
                   elseif strcmp(type(end),'resume')
                       destination = [destination;'NaN'];
                       source = [source;'NaN'];
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
T = table(time,type,source,destination,userID);
userDataTime = table2struct(sortrows(T,1)); % Sort events by timestamp and convert to a cell structure


%% Find Routes entered by User

%Find all routes 
allRoutes = unique(cellfun(@num2str,{userDataTime.destination},'uni',0));

%Extract main route
mainRoutes = unique(cellfun(@num2str,regexp(allRoutes, '[^.]+(?<=.)', 'match', 'once'),'uni',0)); 


end