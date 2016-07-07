function rtbCleanMatlabPath()
% Remove '.svn' and '.git' folders from the Matlab path.
%
% rtbCleanMatlabPath() Modifies the Matlab path, removing path entries that
% contain '.git' or '.svn'.  You might want to call savepath() afterwards.
%
% You can use this function while the Matlab "Set Path" dialog is open!
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

% get the Matlab path
pathString = path();

% remove .svn and .git folders
pathString = RemoveMatchingPaths(pathString, '.svn');
pathString = RemoveMatchingPaths(pathString, '.git');

% set the cleaned-up path
path(pathString);