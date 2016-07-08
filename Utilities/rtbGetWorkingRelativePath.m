function relativePath = rtbGetWorkingRelativePath(originalPath, varargin)
%% Convert a local absoute path to a relative working path.
%
% relativePath = rtbGetWorkingRelativePath(originalPath, 'hints', hints)
% Converts the given originalPath to a relative path, relative to the
% working folder specified by the given hints.  See rtbWorkingFolder().
%
% If originalPath can be found within the working folder specified by
% the given hints, returns the corresponding relative path, starting
% from the working folder.  Otherwise, returns ''.
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('originalPath', @ischar);
parser.addParameter('hints', rtbDefaultHints(), @isstruct);
parser.parse(originalPath, varargin{:});
originalPath = parser.Results.originalPath;
hints = rtbDefaultHints(parser.Results.hints);

relativePath = '';

workingFolder = rtbWorkingFolder('hints', hints);
info = rtbResolveFilePath(originalPath, workingFolder);
if info.isRootFolderMatch
    relativePath = info.resolvedPath;
end
