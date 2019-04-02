function addimage = img2xlsx(imagcell, varargin)
% This function adds one or multiple image(s) automatically to a new or 
% existing Excel file. Firstly, this function is based on the tutorial of 
% the MathWorks Support Team. see: http://tinyurl.com/imgtoxls. 
% This method works via ActiveX.
%
% The following parameter has to be filled in to execute this function 
% succesfully:
%
% - imagecell = a cell array with the name(s) of the image(s) e.g.
% exampleOne = {image.eps}; or examplemulti = {'image1.eps';'image2.eps'};
%
% varargin input:
%
% 1. img2xlsx(imagcell, name)
% varargin{1} = name). If you have an existing xlsx-file, 
% give the the name of the xlsx-file. Default = 'myfile.xlsx' thus creating a
% new xlsx-file.   
%
% 2. img2xlsx(imagcell, name, DIR)
% varargin{2} = DIR. Directory where the exising xlsx-file and/or image(s) 
% is/are situated. Default = pwd
% IMPORTANT: the image(s), which has to be transfered, should be in this
% directory! Otherwise this function cannot find the image(s). See lines
% 115/116.
%
% 3. img2xlsx(imagcell, name, DIR, sheet)
% varargin{3} = sheet. Select the sheet-number in which the image(s) has to
% be transfered too. If you want to add a sheet, fill in 'Add'. Default = 1.
%
% 4. imgxlsx(imagcell, name, DIR, sheet, dimensions)
% varargin{4} = dimensions. Provide the dimensions of the image(s) in a
% matrix like [LinkToFile,...           (The file to link to.)
%               SaveWithDocument,...    (To save the picture with the document.)
%               Left,...                (The position (in points) of the upper-left corner of the picture relative to the upper-left corner of the document.)
%               Top,...                 (The position (in points) of the upper-left corner of the picture relative to the top of the document.)
%               Width,...               (The width of the picture, in points.)
%               Height]                 (The height of the picture, in points.)
% Default = [0,1,1,1,450,352]
% see: https://msdn.microsoft.com/en-us/library/bb209605(v=office.12).aspx
%    
% Version 1.0 06/13/2015 ? H.K.Berg 2015
% -------------------------------------------------------------------------
% If this function errors somewhere and you re-run it, a common error will 
% be: READ-ONLY ERROR excel: (e.g. with existing xlsx-file: 'Test.xlsx'
% in directory 'di')
%
% img2xlsx(cell, 'Test.xlsx',di)
% Error using Interface.Microsoft_Excel_14.0_Object_Library._Workbook/SaveAs
% Invoke Error, Dispatch Exception:
% Source: Microsoft Excel
% Description: Cannot access read-only document 'Test.xlsx'.
% Help File: xlmain11.chm
% Help Context ID: 0
% Error in img2xlsx (line 113)
% invoke(Workbook, 'SaveAs', [DIR '\' name]);
%
% SOLUTION: End all Excel processes via the Task Manager and execute this
% function again.
% -------------------------------------------------------------------------
% Default varargin:
name = 'myfile.xlsx'; 
DIR = pwd;  
sheet = 1;
dimensions = [0,1,1,1,450,352];
if nargin > 1
    name = varargin{1};
    if nargin > 2
        DIR = varargin{2};
        if nargin > 3
            sheet = varargin{3};
            if nargin > 4
                dimensions = varargin{4};
                if nargin > 5
                    error('myfuns:somefun2Alt:TooManyInputs', ...
                    'function img2xlsx requires at most 4 optional inputs');
                end
            end
        end
    end
end
                                                                
% Get handle to Excel COM Server
Excel = actxserver('Excel.Application');
% Add a Workbook to a new excel-file
if strcmp(name,'myfile.xlsx')
    Workbook = invoke(Excel.Workbooks, 'Add');
else % Add a Workbook to existing excel-file
    ResultFile = strcat(DIR, '\', name); 
    Workbook = invoke(Excel.Workbooks,'Add', ResultFile);
end
% Add a sheet if sheet = 'Add'
if strcmp(sheet, 'Add')
    Workbook.Worksheets.Add([], Workbook.Worksheets.Item(Workbook.Worksheets.Count));
    sheet = Excel.Sheets.Count;
else
end
% Get a handle to Sheets and select Sheet No
Sheets = Excel.ActiveWorkBook.Sheets;
SheetNo = get(Sheets, 'Item', sheet);
SheetNo.Activate;
% Get a handle to Shapes for Sheet No n
Shapes = SheetNo.Shapes;
% Add image(s - adjacent to each other)
for i = 1:length(imagcell)
    image = char(imagcell(i));
    if i == 1
       dimensions(3) = i;
    else
       dimensions(3) = ((i-1)*dimensions(5)); 
    end
    Shapes.AddPicture([DIR '\' image] ,dimensions(1), dimensions(2),...
        dimensions(3), dimensions(4), dimensions(5), dimensions(6));    
end
%Save and Quite Excel file    
invoke(Workbook, 'SaveAs', [DIR '\' name]);
invoke(Excel,'Quit');
delete(Excel);
addimage = 'image(s) added succesfully';
end