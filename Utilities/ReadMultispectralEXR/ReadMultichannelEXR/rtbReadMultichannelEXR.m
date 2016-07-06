function [channelInfo, imageData] = rtbReadMultichannelEXR(exrFile)
% Read an OpenEXR image with multiple channels.
%
% [channelInfo, imageData] = rtbReadMultichannelEXR(exrFile) reads the
% given OpenEXR image with an arbitrary number of channels, aka "image
% planes", aka "slices'.
%
% Returns a struct array n elements, one for each image channel.  Each
% element describes the channel, including its name, pixelType, xSampling,
% ySampling, and isLinear.  You might only care about the channel name!
%
% Also returns a double array with size [height width n] containing the
% full image.  height and width refer to image spatial dimenstions.  n
% refers to the number of channels in the image.
%
% [channelInfo, imageData] = rtbReadMultichannelEXR(exrFile)
%
%%% RenderToolbox3 Copyright (c) 2012-2015 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

% delegate to the mex-function with a slightly different name
[channelInfo, imageData] = ReadMultichannelEXR(exrFile);