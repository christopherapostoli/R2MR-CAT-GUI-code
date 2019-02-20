%{
R2MR and CAT Data Extractor Main Code

This code will extract data from selected files and export data to excel
file. 

There are many subfunctions utilized

%}


% this version isn't too different; has an additional input paramater for
% create_time_UI and calls a later version of import_directory
close all;
clearvars % clear variables
addpath('code-extraction','code-analysis','data'); % add all (sub)folders to search path
% savepath; % save current search path to an existing pathdef.m file 

[fileList,currentAppValue] = import_directory_v3; % get all files from directory thru a gui
% after this function, you have a cell array containing the NAMES of the
% files you wish to analyze, and the selection of which app you want to
% analyze should be in the main workspace
% outputDir = 'C:\Users\christopher.apostoli\Documents\Josh Granek\MATLAB Script Package_Chris\MatLAB Scripts_V6\MatLAB Scripts_V5\R2MR_CAT_Output.xlsx'; %Master File
% outputDir = 'C:\Users\apostoli\Documents\GitHub\R2MR-CAT-GUI-code\data\R2MR_CAT_Output.xlsx'; %At home - Master spreadsheet;
outputDir = 'C:\Users\christopher.apostoli\Documents\GitHub\R2MR-CAT-GUI-code\code-analysis'; %At work computer - Master spreadsheet;

%Use as default
% fileList =     [{'analytics_CAT_User2.txt'}    {'data_CAT_User2.txt'}
%     {'analytics_CAT_User3.txt'}    {'data_CAT_User3.txt'};
%     {'analytics_CAT_User4.txt'}    {'data_CAT_User4.txt'}];
% currentAppValue = 'CAT';

% at this point, we have the sorted file names of those we wish to analyze
deviceEvents = cell(size(fileList,1),1); %Initialize 
deviceData = []; %initialize
for i = 1:size(fileList,1)
    deviceEvents{i,1} = parseEvents(fileList{i,1}); % imports file, extracts relevant info, puts into cell array
    deviceData = [deviceData; struct2table(parseData(fileList{i,2},currentAppValue))]; %#ok<AGROW>
%     allUserData{i,1} = userData;
%     allUserData{i,2} = deviceData;
end
%Take unique user data for deviceData
[~,indData] = unique(deviceData.currentUser,'last');
deviceDataUnique = deviceData(indData,:); 

% save('exports/allUserData.mat','allUserData');
% save('exports/allUserEvents.mat','deviceEvents');
% disp('allUsers saved in exports folder');

% at this point, you've picked your files, you've parsed them to get a cell
% array full of events, and now you're ready to create the GUI and perform analyses
%create_time_UI_v4(deviceEvents,currentAppValue);
GUI_Analysis_v2(deviceEvents,deviceDataUnique,currentAppValue,outputDir);


