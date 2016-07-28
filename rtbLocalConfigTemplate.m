%% Configure RenderToolbox3 system defaults.
%
% This script attempts to locate system resources and create Matlab
% preferences necessary to use RenderToolbox3.
%
% For vanilla installations, like when installing on a fresh virutal
% machine, this script should work out-of-the-box.  For custom
% installations, you may need to copy and modify this script.
%
% You should run this script whenever you want to make sure that
% RenderToolbox3 is all set up.  This could be once, when you first install
% RenderToolbox3, or as often as you like!
%
% This script is also intended as a "local hook template" for use with the
% Toolbox Toolbox.  This means that when you deploy RenderToolbox3 using
% the ToolboxToolbox, you will get a copy of this script in your local
% hooks folder.  You should modify that copy as you need.
%
% Use rtbTestInstallation() to test whether things are working.
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.


%% Matlab preferences for RenderToolbox3 default hints.
myFolder = fullfile(rtbGetUserFolder(), 'render_toolbox');
renderToolbox3.workingFolder = myFolder;
renderToolbox3.recipeName = '';
renderToolbox3.batchRenderStrategy = 'RtbVersion3Strategy';
renderToolbox3.renderer = 'SampleRenderer';
renderToolbox3.converter = '';
renderToolbox3.imageHeight = 240;
renderToolbox3.imageWidth = 320;
renderToolbox3.whichConditions = [];
renderToolbox3.isReuseSceneFiles = false;
renderToolbox3.isParallel = false;
renderToolbox3.isCaptureCommandResults = true;

setpref('RenderToolbox3', fieldnames(renderToolbox3), struct2cell(renderToolbox3));


%% Locate Mitsuba.
mitsuba.radiometricScaleFactor = 0.0795827427;

% use Docker, if present
mitsuba.dockerImage = 'ninjaben/mitsuba-spectral';

% or use local installation
if ismac()
    mitsuba.app = '/Applications/Mitsuba.app';
    mitsuba.executable = 'Contents/MacOS/mitsuba';
    mitsuba.importer = 'Contents/MacOS/mtsimport';
    mitsuba.libraryPathName = 'DYLD_LIBRARY_PATH';
    mitsuba.libraryPath = '';
else
    mitsuba.app = '';
    mitsuba.executable = 'mitusba';
    mitsuba.importer = 'mtsimport';
    mitsuba.libraryPathName = 'LD_LIBRARY_PATH';
    mitsuba.libraryPath = '';
end

% version 2 compatibility -- deprecated
mitsuba.adjustments = fullfile(rtbRoot(), ...
    'BatchRenderer', 'Version2Strategy', 'Deprecated', ...
    'RendererPlugins', 'Mitsuba', 'MitsubaDefaultAdjustments.xml');

setpref('Mitsuba', fieldnames(mitsuba), struct2cell(mitsuba));

%% Locate PBRT.
pbrt.radiometricScaleFactor = 0.0063831432;

% use Docker, if present
pbrt.dockerImage = 'ninjaben/pbrt-v2-spectral-docker';
pbrt.dockerCommand = 'pbrt';

% or use local install
pbrt.S = [400 10 31];
pbrt.executable = 'pbrt';

% version 2 compatibility -- deprecated
pbrt.adjustments = fullfile(rtbRoot(), ...
    'BatchRenderer', 'Version2Strategy', 'Deprecated', ...
    'RendererPlugins', 'PBRT', 'PBRTDefaultAdjustments.xml');

setpref('PBRT', fieldnames(pbrt), struct2cell(pbrt));
