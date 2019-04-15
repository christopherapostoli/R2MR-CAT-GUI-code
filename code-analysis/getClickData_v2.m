function [userDataClick,userDataTrans,totDataUnique] = getClickData_v2(deviceEvents,uniqueUsers)

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

timeTrans = {};
userTransID = {};
currFromPage = {};
currToPage = {};
pageFromMain = {};
pageToMain = {};
hRef = {};
timeHRef = {};
totData = {};



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
                   totData = [totData; {timeFormatted},{fromPage},{toPage}];

               elseif strcmp(deviceEvents{i,1}{1,j}.type,desiredEvents{1,2})  % check if Click
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
                   %Check if user clicked on hyperlink to new page.
                   %Hyperlinks are not tracked as transitions so we need to
                   %manually keep track of them and add them to transitions
                   %variables when complete, then update by sorting
                   if contains(deviceEvents{i,1}{1,j}.details.target,'href')
                       %Keep track of time and when HRef occurs
                       try
                            totData = [totData; {timeFormatted},{''},{deviceEvents{i,1}{1,j}.details.target(end-30:end)}];
                       catch
                            totData = [totData; {timeFormatted},{''},{deviceEvents{i,1}{1,j}.details.target(end-15:end)}];
                       end
                   end
                   
               end 
            end
       end
    end     
end

%Sort clicks with time
totData = sortrows(cell2table(totData,'VariableNames',{'Time','FromPage','ToPage'}),1); %Sort by date
totDataUnique = unique(totData,'first'); %Remove any rows that were repeated due to files with same data
%Determine the previous 'to' page and fill it in as 'from' when determing
%href locations
indHRefFrom = find(strcmp(totDataUnique.FromPage(:),'') == 1);    
% totDataUnique.FromPage(indHRefFrom) = totDataUnique.ToPage(indHRefFrom - 1);

% eventLog: cell array containing timestamp, time, to and from for each event sorted in chronological order
T = table(time,type,posX,posY,target,userID,timeStr);
T = sortrows(T,1); 
[~,unqRows,~] = unique(T(:,5:7),'first');
T = T(unqRows,:); %Sort then take onl unique rows, remove duplicates
T = sortrows(T,1); 
userDataClick = table2struct(T); % Sort events by timestamp and convert to a cell structure
% userDataClick = table2struct(sortrows(T,1),'ToScalar',true); % Sort events by timestamp and convert to a cell structure
% userDataClick = table2struct(sortrows(T,1)); % Sort events by timestamp and convert to a cell structure

%Transition events match
time = timeTrans; %Change var name so it's easier for searching 
userID = userTransID; %Change var name so it's easier for searching
TT = table(time,currFromPage,pageFromMain,currToPage,pageToMain,userID);
% userDataTrans = table2struct(sortrows(TT,1),'ToScalar',true); % Sort events by timestamp and convert to a cell structure
userDataTrans = table2struct(sortrows(TT,1)); % Sort events by timestamp and convert to a cell structure


end