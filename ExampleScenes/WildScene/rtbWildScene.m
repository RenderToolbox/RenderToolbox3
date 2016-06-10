%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Start with a wild scene downloaded from the web.  Load it, clean it up,
% explor it in Matlab, and render it with Mitsuba.
%

clear;
clc;
pathHere = fileparts(which('rtbWildScene'));

%% Choose a scene format.
% Millenium Falcon
% http://tf3dm.com/3d-model/millenium-falcon-82947.html

% 3DS Max one seems messed up
%wildScene = fullfile(pathHere, 'millenium-falcon.3DS');

% Wavefront Object looks OK
wildScene = fullfile(pathHere, 'millenium-falcon.obj');

%% Load the scene and clean it up.
importArgs = {'ignoreRootTransform', true, 'flipUVs', true};
scene = mexximpCleanImport(wildScene, importArgs{:});

% look at the struct
disp(displayNicelyFormattedStruct(scene, 'scene', '', 50));

%% Add missing lights and camera.
scene = mexximpCentralizeCamera(scene);
scene = mexximpAddLanterns(scene);

% look at the struct, now with lights and camera
disp(displayNicelyFormattedStruct(scene, 'scene', '', 50));

%% Plot scene vertices.
mexximpSceneScatter(scene);

%% Choose batch processing options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.fov = 60 * pi() / 180;
hints.recipeName = 'rtbWildScene';
hints.renderer = 'Mitsuba';
hints.batchRenderStrategy = RtbVersion3Strategy(hints);

%% Render with Mitsuba.
nativeSceneFiles = MakeSceneFiles(scene, 'hints', hints);
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
