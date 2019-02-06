function allUserData = format_raw_data_v2(userData)
    %FORMAT_RAW_DATA consolidates raw userData and events into a cell arrays
    % sorted by user. Column 1 {:,1} contains the user id and column 2 {:,2}
    % contain all user analytics and data. 
    %
    % Parameters:
    %   userData = Cell array containing user data (from data*.txt file)
    %   events = Cell array containing analytics data (from analytics*.txt file) 
    %
    % Return values:
    %   allUserData = Cell array containing the user data for each user
    %   allEvents = Cell array containing the events data for each user

    allUserData = {};
    addedUsers = {};
    eventsAdded = {};
    % HIRA'S STUFF COMMENTED OUT 
    % Currently I have only accounted for the following types. Will proabably
    % have to adjust for R2MR to account for more information
%     dataTypes = {'user','sectionFeedback','preference'};
    % Keep track on number of rows in master_list
    n = 1;
    for i = 1:length(userData)
        if isfield(userData{1,i},'type') % if there is a field 'type'
            % Determine user associated with data set
            if strcmp(userData{1,i}.type,'user') % if the value of 'type' is 'user'
                user = userData{1,i}.x_id;
                userI = strfind(userData{1,i}.x_id,'_'); % finds the character position of the pattern match
                currentUser = user(userI(2)+1:end);
                % Get elements (specifically, the datatype and the data proper)
                data = userData{1,i}.data;
            else
                currentUser = 99999; % quick and dirty way of handling empty contents of a cell array - if the datatype wasn't 'user', give currentUser a high value and before adding it to the list, check to see if it's NOT a number
%                 data = {};
            end
            
            % HIRA loves this stuff - I don't get its true purpose
            % Check if current_user has aleady been created in master list
            % Find index of cell in master_list containing current_user
            indexC = strfind(addedUsers,currentUser);
            index = find(~cellfun('isempty',indexC));
            
            if isempty(index) && ischar(currentUser) % make sure that whatever Hira did above isempty and that the currentUser is a character (and not 99999)
                % User has not been created
                addedUsers{n} = currentUser;
                eventsAdded{n} = false;
                allUserData{n,1} = currentUser;
                allUserData{n,2}=data;
                n = n + 1;
%             else
%                 % User has been created
%                 % Add to existing row (master_list{index})
%                 allUserData{index,2} = [allUserData{index,2};data];
            end
        end
    end
end

