function folder = rtbWorkingFolder(varargin)
%% Get a complete RenderToolbox3 working folder folder.
%
% folder = rtbWorkingFolder('hints', hints) returns the full path to a
% RenderToolbox3 recipe folder.  This will
% include the given hints.workingFolder and hints.recipeName.  If the
% returned folder does not exist yet, creates it.
%
% rtbWorkingFolder( ... 'folderName', folderName) specifies a standard
% subfolder name within the working folder.  Valid subfolder names include:
%   - 'resources' - where to look for input resources like spectra and textures
%   - 'scenes' - where to put generated scene files
%   - 'renderings' - where to put renderer output data files
%   - 'images' - where to put processed image files
%   - 'temp' - where to put temporary files like intermediate copies of scene files
% The default is not to include any of these subfolders.
%
% rtbWorkingFolder( ... 'rendererSpecific', rendererSpecific) specifies a
% whether to include a subfolder with the name of the given hints.renderer.
% The default is not to include any renderer-specific subfolder.
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addParameter('hints', rtbDefaultHints(), @isstruct);
parser.addParameter('folderName', '', @ischar);
parser.addParameter('rendererSpecific', false, @islogical);
parser.parse(varargin{:});
hints = rtbDefaultHints(parser.Results.hints);
folderName = parser.Results.folderName;
rendererSpecific = parser.Results.rendererSpecific;

if rendererSpecific
    renderer = hints.renderer;
else
    renderer = '';
end

% working folder root should not be empty
if isempty(hints.workingFolder)
    warning('RenderToolbox3:EmptyWorkingFolder', ...
        ['Your working folder is empty!  ' ...
        'Please setpref(''RenderToolbox3'', ''workingFolder'', ...)  ' ...
        'or supply hints.workingFolder.']);
end

% just the base folder if no named folder given
if nargin < 1 || isempty(folderName)
    folder = fullfile(hints.workingFolder, hints.recipeName, renderer);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    return;
end

% only allow certain named subfolders
folderNames = {'resources', 'scenes', 'renderings', 'images', 'temp'};
if ~any(strcmp(folderName, folderNames))
    pathNamesString = evalc('disp(folderNames)');
    error('RenderToolbox3:UnknownWorkingFolder', ...
        'folderName <%s> must be one of the following: \n  %s', ...
        folderName, pathNamesString);
end

folder = fullfile(hints.workingFolder, hints.recipeName, folderName, renderer);
if ~exist(folder, 'dir')
    mkdir(folder);
end
