function [userDataClick] = getClickData_v3(deviceEvents,uniqueUsers)

%% Prepare Data
%Seperate data based on click consideration
% Get details of clicks
desiredEvents = {'transition','click'};
time={};
timeStr = {}; 
type={};
posX={};
posY = {};
target = {};
userID = {}; 

for i = 1:size(deviceEvents,1) % for each device
    for j = 1:size(deviceEvents{i,1},2) % for each event  
       if isfield(deviceEvents{i,1}{1,j},'related_user') 
           if ~isempty(deviceEvents{i,1}{1,j}.related_user) && any(strcmp(deviceEvents{i,1}{1,j}.related_user,uniqueUsers)) % only consider events with users - if it doesn't have one, it's probably startup
               %Defines when the user transitions to a new page. Use this
               %variable to know what subroute the user is at when they click
               if strcmp(deviceEvents{i,1}{1,j}.type,desiredEvents{1,2})  % check if Click
                   timeFormatted = format_time(deviceEvents{i,1}{1,j}.timestamp); % format the string timestamp into date and time
                   time = [time; timeFormatted]; %store time
                   timeStr = [timeStr; {datestr(timeFormatted)}]; %string of date
                   type = [type; deviceEvents{i,1}{1,j}.type]; % store the type of event == click
                   posX = [posX; deviceEvents{i,1}{1,j}.details.x]; % store x position
                   posY = [posY; deviceEvents{i,1}{1,j}.details.y]; % store y position
                   target = [target; deviceEvents{i,1}{1,j}.details.target]; % store target (was clicked by user)
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

%Sort clicks with time
% eventLog: cell array containing timestamp, time, to and from for each event sorted in chronological order
T = table(time,type,posX,posY,target,userID,timeStr);
T = sortrows(T,1); 
[~,unqRows,~] = unique(T(:,5:7),'first');
T = T(unqRows,:); %Sort then take onl unique rows, remove duplicates
T = sortrows(T,1); 
userDataClick = table2struct(T); % Sort events by timestamp and convert to a cell structure
% userDataClick = table2struct(sortrows(T,1),'ToScalar',true); % Sort events by timestamp and convert to a cell structure
% userDataClick = table2struct(sortrows(T,1)); % Sort events by timestamp and convert to a cell structure



end