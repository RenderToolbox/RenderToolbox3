function [dockerExists, status, result] = rtbDockerExists()
% Check whether we can find and use Docker.
%
% dockerExists = rtbDockerExists() returns true if Docker can be found on
% the host system, and if the current user has permission to invoke Docker
% commands.
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

%% Can we use Docker?
[status, result] = system('docker ps');
dockerExists = 0 == status;
