function wasCreated = rtbChangeToWorkingFolder(varargin)
%% Change to the working folder for a recipe, create it if necessary.
%
% wasCreated = rtbChangeToWorkingFolder('hints', hints) will cd() to the
% working folder for the given hints, used by a recipe, creating the
% working folder if it doesn't exist yet.
%
% Returns true if @a folder had to be created.
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addParameter('hints', rtbDefaultHints(), @isstruct);
parser.parse(varargin{:});
hints = rtbDefaultHints(parser.Results.hints);

workingFolder = rtbWorkingFolder('hints', hints);
wasCreated = rtbChangeToFolder(workingFolder);
