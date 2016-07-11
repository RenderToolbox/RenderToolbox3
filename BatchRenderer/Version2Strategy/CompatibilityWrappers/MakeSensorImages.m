function outFiles = MakeSensorImages(inFiles, matchingFunctions, matchingS, matchingNames, hints)
%% Compatibility wrapper for code written using version 2.
%
% This function is a wrapper that can be called by "old" RenderToolbox3
% examples and user code, written before the Version 3.  Its job is to
% "look like" the old code, but internally it calls new code.
%
% To encourage users to update to Versoin 3 code, this wrapper will display
% an irritating warning.
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

rtbWarnDeprecated();

if nargin < 4 || isempty(matchingNames)
    matchingNames = cell(size(matchingFunctions));
end

if nargin < 5
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

outFiles = rtbMakeSensorImages(inFiles, matchingFunctions, ...
    'matchingS', matchingS, ...
    'names', matchingNames, ...
    'hints', hints);
