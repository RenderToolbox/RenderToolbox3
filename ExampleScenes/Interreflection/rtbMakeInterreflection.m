%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

%% Render two panels with light reflecting betwen them.

%% Choose example files.
parentSceneFile = 'Interreflection.blend';
mappingsFile = 'InterreflectionMappings.json';
conditionsFile = 'InterreflectionConditions.txt';

%% Choose batch renderer options.
hints.imageHeight = 100;
hints.imageWidth = 160;
hints.fov = 49.13434 * pi() / 180;
hints.recipeName = 'rtbMakeInterreflection';

%% Render with Mitsuba and PBRT.
% make an sRGB montage with each renderer
toneMapFactor = 10;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    
    nativeSceneFiles = rtbMakeSceneFiles(parentSceneFile, ...
        'conditionsFile', conditionsFile, ...
        'mappingsFile', mappingsFile, ...
        'hints', hints);
    radianceDataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);
    
    [SRGBMontage, XYZMontage] = ...
        rtbMakeMontage(radianceDataFiles, ...
        'toneMapFactor', toneMapFactor, ...
        'isScale', isScale, ...
        'hints', hints);
    rtbShowXYZAndSRGB([], SRGBMontage, sprintf('%s (%s)', hints.recipeName, hints.renderer));
end
