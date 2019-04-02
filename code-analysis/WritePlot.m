function WritePlot (h, filename, option)
% WritePlot ([FigureHandle,] filename[, option])
% Write a PostScript, PDF, or EMF file for a Matlab figure.
% FigureHandle - Optional figure handle. If not specified, the
% current figure is used.
% filename - If the file extension is '.eps' or '.ps', write
% an encapsulated PostScript file.
% - If the file extension is '.pdf', write a PDF file
% - If the file extension is '.emf', write a Windows
% Metafile.
% $Id: WritePlot.m,v 1.16 2006/01/27 21:05:23 pkabal Exp $
% Resolve the arguments
if (nargin == 0)
    h = gcf;
    filename = [];
    option = [];
elseif (nargin == 1)
    if (ishandle (h))
        filename = [];
    else
        filename = h;
        h = gcf;
    end
    option = [];
elseif (nargin == 2)
    if (ishandle (h))
        option = [];
    else
        option = filename;
        filename = h;
        h = gcf;
    end
end
% Return if no file name
if (strcmp (filename, ''))
    return;
end
% Check for the type of file (PS, PDF, or EMF)
[pathstr, name, ext, versn] = fileparts (filename);
PDF = strcmpi (ext, '.pdf'); % Ignore case
EMF = strcmpi (ext, '.emf');
PS = (~PDF & ~EMF);
% Warning message 

figure (h);
Renderer = get (h, 'Renderer');
if (~ strcmpi (Renderer, 'painters'))
    fprintf (' Warning - "Renderer" property: "%s"\n', Renderer);
end

% - Set the figure color to transparent if it is the default
% (gray) color
% - Set figure and axis options so that the saved plot is the
% same size
% as the plot on the screen
% - Set the resolution (in case 'Renderer' is not 'painter') to
% 300 dpi
FColor = get (gcf, 'Color');
FColor_Default = [0.8 0.8 0.8];
if (~ strcmpi (FColor, 'none'))
    if (FColor == FColor_Default)
        set (h, 'Color', 'none'); % Transparent figure
    end
end
set (h, 'PaperPositionMode', 'auto', 'InvertHardCopy', 'off');
set (gca, 'XTickMode', 'manual', 'YTickMode', 'manual', ...
 'ZTickMode', 'manual');
% Print the plot
if (EMF)
    print ('-dmeta', '-r300', option, filename);
elseif (PS)
    print ('-depsc', '-r300', option, filename);
elseif (PDF)
    print ('-dpdf', '-r300', option, filename);
end


return