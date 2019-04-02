function xlsPasteTo(f,filename,sheetname,width, height,varargin)
%Paste current figure to selected Excel sheet and cell
%
%
% xlsPasteTo(filename,sheetname,width, height,range)
%Example:
%xlsPasteTo('File.xls','Sheet1',200, 200,'A1')
% this will paset into A1 at Sheet1 at File.xls the current figure with
% width and height of 200
%
% tal.shir@hotmail.com

% Dimension, where to put figure in excel
options = varargin;
    range = varargin{1};
    
%open Excel workbook
[fpath,file,ext] = fileparts(char(filename));
if isempty(fpath)
    fpath = pwd;
end
Excel = actxserver('Excel.Application');
set(Excel,'Visible',0);
Workbook = invoke(Excel.Workbooks, 'open', [fpath filesep file ext]);
sheet = get(Excel.Worksheets, 'Item',sheetname);
invoke(sheet,'Activate');
ExAct = Excel.Activesheet;
ExActRange = get(ExAct,'Range',range); %Get Range
ExActRange.Select;
   
%   ExActRange = get(ExAct,'Range',range);
%     ExActRange.Select;
%     pos=get(gcf,'Position');
%     set(gcf,'Position',[ pos(1:2) width height])
%     print -dmeta

%Export Graph

f.Units = 'pixels'; 
pos = f.Position;   
%For entire figure
set(f,'Position',[ pos(1:2) width height]);
print(f,'-dmeta','-painters','-r1000'); %add to clipboard
f.Units = 'normalized';

invoke(Excel.Selection,'PasteSpecial');
invoke(Workbook, 'Save');
invoke(Excel, 'Quit');
delete(Excel);