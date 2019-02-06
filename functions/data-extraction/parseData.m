function [allUserData] = parseData(file,currentAppValue)
    % This version includes jsondecode - a simpler way of parsing JSON
    % PARSE_FILE imports a specified file, extracts the information from that
    % file and outputs it in the form of a cell array. If the file is in a
    % subdirectory, ensure that the path has been added.
    % 
    % Note: Previously, this was very specific to the file format of the analytics and 
    % data files, but after the update to 2016, we had access to a function called
    % jsondecode which took care of all the parsing. 
    % 
    % Parameters: 
    %   file = string value containg the name of the files to be read
    %
    % Return Values:
    %   deviceData =  Cell array containing content of read JSON object. All
    %               intended datatypes are preserved

    % This version includes jsondecode - a simpler way of parsing JSON
    % PARSE_FILE imports a specified file, extracts the information from that
    % file and outputs it in the form of a cell array. If the file is in a
    % subdirectory, ensure that the path has been added.
    % 
    % Note: Previously, this was very specific to the file format of the analytics and 
    % data files, but after the update to 2016, we had access to a function called
    % jsondecode which took care of all the parsing. 
    % 
    % Parameters: 
    %   file = string value containg the name of the files to be read
    %
    % Return Values:
    %   deviceData =  Cell array containing content of read JSON object. All
    %               intended datatypes are preserved

    i = 1;
    JSON = {};
    deviceData = {};
    fid = fopen(file); % opens the file for binary read access
    
    if strcmp(currentAppValue,'CAT')
        %Set CAT field names
        fieldStructNames = {'name';'placeholder_name';'hasProvidedName'; ...
            'hasGrantedInformedConsent';'lastAppIndex';'age';'sex';'rank';'seniority'; ...
            'education';'trade';'deployments';'has_apple_product';'has_used_iphone'; ...
            'has_touch_device';'has_dnd_blackberry';'baseline_4a';'baseline_4b'; ...
            'baseline_4c';'baseline_4d';'impressions_5a';'impressions_5a_description';...
            'impressions_5b';'impressions_5b_description';'cat_impressions_a';...
            'cat_impressions_b';'active';'language';'isFirstLaunch'};
        
    else %Set R2MR field names
        fieldStructNames = {'type';'active';'language';'isFirstLaunch'; ... 
            'didAcceptTerms';'continuum_period_start';'audio_gender'; ... 
            'hasGrantedInformedConsent';'hasGrantedLocationConsent'; ... 
            'age';'sex';'rank';'seniority';'education';'trade'; ... 
            'deployments';'has_apple_product';'has_used_iphone';... 
            'has_touch_device';'has_dnd_blackberry';'baseline_4a'; ... 
            'baseline_4b';'baseline_4c';'baseline_4d';'impressions_5a'; ... 
            'impressions_5a_description';'impressions_5b'; ... 
            'impressions_5b_description';'r2mr_impressions_a';'r2mr_impressions_b'};          
    end
    
    if strcmp(file,'data_CAT_User2.txt') || strcmp(file,'data_CAT_User4.txt') % these file was formatted weirdly and is handled differently (a very specific instance)
        fileContents = fscanf(fid,'%s');
        value = jsondecode(fileContents);
        deviceData = extractfield(value,'doc'); % only extract the 4th field - the rest is useless info
    else    
        tline = fgetl(fid); % read line from file, removing newline characters
        while ischar(tline) % while input is a character array...
            % Add files beginning with {"docs" to JSON (get rid of the
            % database information and the "docs" breaks). Breaks it into cells
            % each containing 50 'sequences' of information
            if contains(tline,'"docs"')
                JSON{i} = tline;
                i = i + 1;
            end
            tline = fgetl(fid);
        end
        fclose(fid); % Close the file
        
        deviceData = cell(length(JSON),50); %Initialize
        for i = 1:length(JSON)
            value = jsondecode(JSON{i}); 
            for j = 1:length(value.docs)
                if isstruct(value.docs) % sometimes value takes on the form of a struct (instead of a cell) so it has to be treated differently
                    deviceData{i,j} = value.docs(j);
                else
                    deviceData{i,j} = value.docs{j};
                end
            end
        end
    end
    
    allUserData = {}; %Initialize
    count = 1;
    for i = 1:size(deviceData,1)
        for j = 1:sum(~cellfun(@isempty,deviceData(i,:)),2)
            if contains(deviceData{i,j}.x_id,'user') % if there is a field with 'user'
                if ~isfield(deviceData{i,j},'x_deleted')
                    allUserData.user{count,1} = deviceData{i,j}.x_id;
                    indUser = strfind(deviceData{i,j}.x_id,'_'); % finds the character position of the pattern match
                    allUserData.currentUser{count,1} = deviceData{i,j}.x_id(indUser(end)+1:end); 
                    % Get elements (specifically, the datatype and the data proper)
                    for k = 1:size(fieldStructNames,1)
                        if isfield(deviceData{i,j}.data,fieldStructNames{k})
                            if ~isempty(deviceData{i,j}.data.(fieldStructNames{k}))
                                %User has entered info into param
                                allUserData.(fieldStructNames{k}){count,1} = deviceData{i,j}.data.(fieldStructNames{k});
                            else
                                %User hasn't entered value or left blank
                                allUserData.(fieldStructNames{k}){count,1} = nan; 
                            end
                        else
                            allUserData.(fieldStructNames{k}){count,1} = nan; %empty value
                        end
                    end
                    count = count + 1; %increment
                end
            end
        end  
    end
end