%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make a scene from scratch!  Use some utilities to build up a well-formed
% mexximp scene struct.  Pass this scene into the RenderToolbox3 pipeline
% for spectral rendering with Mitsuba.
%

%% Generate a scene in Matlab.
clear;
clc;

scene = rtbMakeTestScene();

%% Choose batch processing options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.fov = 60 * pi() / 180;
hints.recipeName = 'rtbSceneFromScratch';
hints.renderer = 'Mitsuba';
hints.batchRenderStrategy = RtbVersion3Strategy(hints);

%% Convert to Mitsuba-native scene file.
nativeSceneFiles = MakeSceneFiles(scene, 'hints', hints);

%% Render with Mitsuba.
radianceDataFiles = BatchRender(nativeSceneFiles, 'hints', hints);

%% Convert to sRGB for viewing.
toneMapFactor = 100;
isScale = true;

montageName = sprintf('rtbSceneFromScratch (%s)', hints.renderer);
montageFile = [montageName '.png'];
sRgb = MakeMontage(radianceDataFiles, ...
    'outFile', montageFile, ...
    'toneMapFactor', toneMapFactor, ...
    'isScale', isScale, ...
    'hints', hints);
ShowXYZAndSRGB([], sRgb, montageName);
