% Sandbox to export the test scene from makeTestScene

%% Make and export the scene.
clear;
clc;

pathHere = fileparts(which('exportTestScene.m'));

scene = makeTestScene();
format = 'collada';
colladaFile = fullfile(pathHere, 'test-export.dae');
status = mexximpExport(scene, format, colladaFile, []);

%% Try to render with RenderToolbox3!
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.recipeName = 'mexximpExportTest';
ChangeToWorkingFolder(hints);

setpref('Mitsuba', 'adjustments', which('scratch-mitsuba-adjustments.xml'));
setpref('PBRT', 'adjustments', which('scratch-pbrt-adjustments.xml'));
mappingsFile = which('scratch-mappings.txt');

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'PBRT', 'Mitsuba'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(colladaFile, '', mappingsFile, hints);
    
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('%s (%s)', hints.recipeName, hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
