%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render example scene files that were generated previously.
%
% This script is intended as an example for rendering in a production
% setting, like a computer cluster.  It's not intened as a general-purpose
% demo.
%
% GenerateAllExampleSceneFiles.m and RenderAllExampleSceneFiles.m work as a
% pair.  You should run GenerateAllExampleSceneFiles.m first, then run
% RenderAllExampleSceneFiles.m.
%
% This script is useful for rendering lots and lots of scene files that
% were generated previously with  GenerateAllExampleSceneFiles.  In some
% production settings, like  computer clusters, it's useful to have a
% top-level script that takes no arguments, like this one.  You should copy
% this script and edit variables to agree with your system.
%
% It should be possible to run this script from any machine, including one
% that does not have OpenGL support, or one that delegates to worker nodes
% that don't have OpenGL support.
%
% See
% https://github.com/DavidBrainard/RenderToolbox3/wiki/Generate-and-RenderAllExampleSceneFiles.
%

%% Choose global RenderToolbox3 behavior.
setpref('RenderToolbox3', 'isParallel', true);
setpref('RenderToolbox3', 'isDryRun', false);
setpref('RenderToolbox3', 'isReuseSceneFiles', true);

%% Invoke executive scripts.
% choose where to put output files
%   for example '/Users/myName/epic-scene-test'
%   or empty '' for default folders (see rtbDefaultHints())
outputRoot = '/home2/brainard/render-toolbox-3/epic-scene-test';
makeFunctions = { ...
    'MakeCheckerShadowScene.m', ...', ...
    'MakeCheckerboard.m', ...
    'MakeCoordinatesTest.m', ...
    'MakeCubanSphere.m', ...
    'MakeCubanSphereTextured.m', ...
    'MakeDice.m', ...
    'MakeDiceTransformations.m', ...
    'MakeDragon.m', ...
    'MakeDragonColorChecker.m', ...
    'MakeDragonGraded.m', ...
    'MakeDragonMaterials.m', ...
    'MakeInterior.m', ...
    'MakeInteriorDragon.m', ...
    'MakeInterreflection.m', ...
    'MakeMaterialSphere.m', ...
    'MakeMaterialSphereBumps.m', ...
    'MakeMaterialSpherePortable.m', ...
    'MakeMaterialSphereRemodeled.m', ...
    'MakeRadianceTestMitsuba.m', ...
    'MakeRadianceTestPBRT.m', ...
    'MakeScalingTest.m', ...
    'MakeSimpleSphere.m', ...
    'MakeSimpleSquare.m', ...
    'MakeSpectralIllusion.m', ...
    'MakeTableSphere.m'};
results = TestAllExampleScenes(outputRoot, makeFunctions);
