%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke Mitsuba.
%   @param scene struct description of the scene to be rendererd
%   @param hints struct of RenderToolbox3 options, see rtbDefaultHints()
%
% @details
% This function is the RenderToolbox3 "Render" function for Mitsuba.
%
% @details
% See RTB_Render_SampleRenderer() for more about Render functions.
%
% Usage:
%   [status, result, multispectralImage, S] = RTB_Render_Mitsuba(scene, hints)
function [status, result, multispectralImage, S] = RTB_Render_Mitsuba(scene, hints)

renderer = RtbMitsubaRenderer(hints);
[status, result, multispectralImage, S] = renderer.render(scene.mitsubaFile);
