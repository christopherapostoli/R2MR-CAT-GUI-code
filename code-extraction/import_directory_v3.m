function [fileList,currentAppValue] = import_directory_v3
    % This version has the UI for getting file and the CAT/R2MR user option
    % IMPORT_DIRECTORY prompts user to select the raw analytics and data files to be imported.
    % It then prompts the user to stipulate which app to analyze.
    % It then parses the name of each file into a cell array where each row
    % is a set of files with unique identifiers (events vs data files).
    %     
    % Parameters:
    %     File directory prompt: Select folder. Each set of analytics data must
    %     have a unique identifier associated 
    %
    % Return Values:
    %     fileList = 2D cell array containing the names of the files to
    %     be analyzed. Files from the same device are grouped in the same row.
    %       fileList{:,1} = analytics files 
    %       fileList{:,2} = data files
    
    apps = {'CAT','R2MR'};
    currentAppValue = apps{1}; %'Cat'
    fileList = {};
    
    % asks user to select files they want analyzed - opens explorer dialog
    [analFiles,analPath] = uigetfile('*.txt','Select Analytics Files to Open','MultiSelect','on'); % for analytics files
    
    [datFiles,dataPath] = uigetfile('*.txt','Select Data Files to Open','MultiSelect','on'); % for data files

    
    if ischar(analFiles) || ischar(datFiles) % checks if there is only one file, and if so, convert from char to cell
        analFiles = {analFiles};
        datFiles = {datFiles};
    end

    %Show user
    fprintf('ANALYSIS file chosen: %s\n',analFiles{:});
    fprintf('DATA files chosen: %s\n',datFiles{:});
    
    % checks if the user pressed cancel, or made an incorrect selection    
    if isequal(analFiles,0) || isequal(datFiles,0)
        error('You must select at least one file to analyze.')
    elseif ~isempty(analFiles) || ~isempty(datFiles)
        u = figure('Name','Analysis GUI','Position',[50,150,450,300],'Units','normalized'); % open a GUI
        whichAppText = uicontrol('Style','text','String','Select Which Application to Analyze:',...
            'Position',[90,200,300,20],'Units','normalized','FontSize',12,'FontWeight','bold'); % write text
        appOptionsSelection = uicontrol('Style','popupmenu','String',apps,...
            'Position',[160,180,125,12],...
            'Callback',@app_popup_menu_Callback,...
            'Units','Normalized'); % implement a drop down
        goButton = uicontrol('Style','pushbutton','String','Go',...
            'Position',[200,50,30,30],...
            'Callback',@gobutton_Callback,...
            'Units','normalized'); % implement a Go button
    end

    movegui(u,'center');
    uiwait(u); % wait for the user to press go before continuing
    
    % Determine desired app currently displayed
    function app_popup_menu_Callback(source,eventdata)
        str = source.String;
        val = source.Value;
        currentAppValue = str{val};
    end

    % allow user to press Go which effectively sorts the files added and
    % adds to fileList which goes back to main workspace
    function gobutton_Callback(source,eventdata)
        uiresume(u); % continue with program, 'Go' was pressed
        fileList = cell(length(analFiles),2); %Analysis | Data
        for i = 1:length(analFiles)
            fileList(i,1:2) = {fullfile(analPath,analFiles{i}) fullfile(dataPath,datFiles{i})}; % combine all files into one cell array
        end
        close(u); % close the GUI
    end 
end