%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a sphere in fog under some spot lights.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'ScatteringVolume.dae';
mappingsFile = 'ScatteringVolumeMappings.txt';

%% Choose batch renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = mfilename();
ChangeToWorkingFolder(hints);

% show progress -- this probably takes a few minutes
hints.isCaptureCommandResults = false;

%% Render with Mitsuba and PBRT
toneMapFactor = 100;
isScale = true;
for renderer = {'PBRT'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('%s (%s)', hints.recipeName, hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
