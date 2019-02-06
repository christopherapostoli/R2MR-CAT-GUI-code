function [userDataClick,userDataTrans] = getClickData_v2(deviceEvents,uniqueUsers)

%% Prepare Data
%Seperate data based on click consideration
% Get details of clicks
desiredEvents = {'transition','click'};
time={};
type={};
posX={};
posY = {};
target = {};
userID = {}; 

timeTrans = {};
userTransID = {};
currFromPage = {};
currToPage = {};
pageFromMain = {};
pageToMain = {};


for i = 1:size(deviceEvents,1) % for each device
    for j = 1:size(deviceEvents{i,1},2) % for each event  
       if isfield(deviceEvents{i,1}{1,j},'related_user') 
           if ~isempty(deviceEvents{i,1}{1,j}.related_user) && any(strcmp(deviceEvents{i,1}{1,j}.related_user,uniqueUsers)) % only consider events with users - if it doesn't have one, it's probably startup
               %Defines when the user transitions to a new page. Use this
               %variable to know what subroute the user is at when they click
               if strcmp(deviceEvents{i,1}{1,j}.type,desiredEvents{1,1}) % check if Transition
                   try
                       fromPage = deviceEvents{i,1}{1,j}.details.from; %page just at
                   catch
                       fromPage = 'index'; %For first entry of app there is no 'from' field 
                   end
                   toPage = deviceEvents{i,1}{1,j}.details.to; %page going to
                   mainFromPage = regexp(fromPage, '[^.]+(?<=.)', 'match', 'once'); %need userClick to be scalar so that we can search page names
                   mainToPage = regexp(toPage, '[^.]+(?<=.)', 'match', 'once'); %need userClick to be scalar so that we can search page names 
                   currFromPage = [currFromPage; fromPage]; % store the current page
                   currToPage = [currToPage; toPage]; % store the current page 
                   pageFromMain = [pageFromMain; mainFromPage]; %Main page user is at
                   pageToMain = [pageToMain; mainToPage]; %Main page user is at
                   timeFormatted = format_time(deviceEvents{i,1}{1,j}.timestamp); % format the string timestamp into date and time
                   timeTrans = [timeTrans; timeFormatted]; %store time
                   if isfield(deviceEvents{i,1}{1,j},'related_user') % some events (startup of app, or relaunch) don't have a related_user field so we have to make one and fill it in later                  
                       userTransID = [userTransID; deviceEvents{i,1}{1,j}.related_user];
                   else
                       deviceEvents{i,1}{1,j}.related_user = 'resumeUser';
                       userTransID = [userTransID; deviceEvents{i,1}{1,j}.related_user]; 
                   end 

               elseif strcmp(deviceEvents{i,1}{1,j}.type,desiredEvents{1,2})  % check if Click
                   timeFormatted = format_time(deviceEvents{i,1}{1,j}.timestamp); % format the string timestamp into date and time
                   time = [time; timeFormatted]; %store time
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

% eventLog: cell array containing timestamp, time, to and from for each event sorted in chronological order
T = table(time,type,posX,posY,target,userID);
% userDataClick = table2struct(sortrows(T,1),'ToScalar',true); % Sort events by timestamp and convert to a cell structure
userDataClick = table2struct(sortrows(T,1)); % Sort events by timestamp and convert to a cell structure

%Transition events match
time = timeTrans; %Change var name so it's easier for searching 
userID = userTransID; %Change var name so it's easier for searching
TT = table(time,currFromPage,pageFromMain,currToPage,pageToMain,userID);
% userDataTrans = table2struct(sortrows(TT,1),'ToScalar',true); % Sort events by timestamp and convert to a cell structure
userDataTrans = table2struct(sortrows(TT,1)); % Sort events by timestamp and convert to a cell structure


end