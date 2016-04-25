%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get version information about the Sample Renderer.
%
% @details
% This function is a template for a RenderToolbox3 "VersionInfo" function.
%
% @details
% The name of a VersionInfo function must match a specific pattern: it must
% begin with "RTB_VersionInfo_", and it must end with the name of the
% renderer, for example, "SampleRenderer".  This pattern allows
% RenderToolbox3 to automatically locate the VersionInfo function for each
% renderer.  VersionInfo functions should be included in the Matlab path.
%
% @details
% A VersionInfo function must return information about a renderer's
% version.  This may have any form, including string or struct.  The may
% have any content, including a software revision or version name or
% number, a renderer executable file creation date, etc.  RenderToolbox3
% uses VersionInfo functions to save renderer version information along
% with rendering data.
%
% Usage:
%   versionInfo = RTB_VersionInfo_SampleRenderer()
%
% @ingroup RendererPlugins
function versionInfo = RTB_VersionInfo_SampleRenderer()

disp('SampleRenderer VersionInfo function.')

versionInfo = 'SampleRenderer version information';
