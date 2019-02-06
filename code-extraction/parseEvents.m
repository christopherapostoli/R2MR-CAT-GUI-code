function deviceData = parseEvents(file)
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
    counter = 1;
    fid = fopen(file); % opens the file for binary read access
    
    if strcmp(file,'analytics_CAT_User2.txt') || strcmp(file,'analytics_CAT_User4.txt') % these file was formatted weirdly and is handled differently (a very specific instance)
        fileContents = fscanf(fid,'%s');
        fileContents = fileContents(4:end); % there are some weird characters before the JSON proper starts
        value = jsondecode(fileContents);
        deviceData = extractfield(value,'doc'); % only extract the 4th field - the rest is useless info
    else    
        tline = fgetl(fid); % read line from file, removing newline characters
        while ischar(tline) % while input is a character array...
            % Add files beginning with "docs" to JSON (get rid of the
            % database information and the "docs" breaks). Breaks it into cells
            % each containing 50 'sequences' of information
            if strfind(tline,'"docs"')
                JSON{i} = tline;
                i = i + 1;
            end
            tline = fgetl(fid);
        end
        fclose(fid); % Close the file
        
        for i = 1:length(JSON)
           value = jsondecode(JSON{i});
            for j = 1:length(value.docs)
                if isstruct(value.docs) % sometimes value takes on the form of a struct (instead of a cell) so it has to be treated differently
                    deviceData{counter} = value.docs(j);
                else
                    deviceData{counter} = value.docs{j};
                end
                counter = counter + 1;
            end
        end
    end
end