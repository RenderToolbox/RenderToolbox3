function rootPath = rtbRoot()
%% Get the path to RenderToolbox3.
%
% rootPath = rtbRoot() returns the absolute path to RenderToolbox3, based
% on the location of this file, rtbRoot.m.
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

filePath = mfilename('fullpath');
lastSeps = find(filesep() == filePath, 2, 'last');
rootPath = filePath(1:(lastSeps(1) - 1));
