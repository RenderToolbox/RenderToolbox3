%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke PBRT.
%   @param scene struct description of the scene to be rendererd
%   @param hints struct of RenderToolbox3 options, see rtbDefaultHints()
%
% @details
% This function is the RenderToolbox3 "Render" function for PBRT.
%
% @details
% See RTB_Render_SampleRenderer() for more about Render functions.
%
% Usage:
%   [status, result, multispectralImage, S] = RTB_Render_PBRT(scene, hints)
function [status, result, multispectralImage, S] = RTB_Render_PBRT(scene, hints)

% copy the scene file to working folder base
%   so that relative paths in scene file will work
sceneFile = scene.pbrtFile;
[~, sceneBase, sceneExt] = fileparts(sceneFile);
copyDir = rtbWorkingFolder('hints', hints);
sceneCopy = fullfile(copyDir, [sceneBase, sceneExt]);
copyfile(sceneFile, sceneCopy, 'f');

renderer = RtbPBRTRenderer(hints);
[status, result, multispectralImage, S] = renderer.render(sceneCopy);
