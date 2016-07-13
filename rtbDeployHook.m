%% Configure RenderToolbox3 system defaults.
%
% This script attempts to locate system resources and create Matlab
% preferences necessary to use RenderToolbox3.%
%
% For vanilla installations, like when installing on a fresh virutal
% machine, this script should work out-of-the-box.  For custom
% installations, you may need to copy and modify this script.
%
% You should run this script whenever you want to make sure that
% RenderToolbox3 is all set up.  This could be once, when you first install
% RenderToolbox3, or as often as you like!
%
% This script is also intended as a deploy "hook" for use with the Toolbox
% Toolbox.  This should make deploying and configuring RenderToolbox 3
% totally automatic.
%
% Use rtbTestInstallation() to test whether things are working.
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.


%% Matlab preferences for RenderToolbox3 default hints.
rtbInitialize('force', true);

%% User folder where we can write outputs.
myFolder = fullfile(rtbGetUserFolder(), 'render_toolbox');
setpref('RenderToolbox3', 'workingFolder', myFolder);

%% Locate Mitsuba.
mitsuba.radiometricScaleFactor = 0.0795827427;

if ismac()
    mitsuba.app = '/Applications/Mitsuba.app';
    mitsuba.executable = 'Contents/MacOS/mitsuba';
    mitsuba.importer = 'Contents/MacOS/mtsimport';
    mitsuba.libraryPathName = 'DYLD_LIBRARY_PATH';
    mitsuba.libraryPath = '';
else
    mitsuba.app = '';
    [~, m] = system('which mitsuba');
    mitsuba.executable = strtrim(m);
    [~, m] = system('which mtsimport');
    mitsuba.importer = strtrim(m);
    mitsuba.libraryPathName = 'LD_LIBRARY_PATH';
    mitsuba.libraryPath = '';
end

% version 2 compatibility
mitsuba.adjustments = fullfile(rtbRoot(), ...
    'BatchRenderer', 'Version2Strategy', 'Deprecated', ...
    'RendererPlugins', 'Mitsuba', 'MitsubaDefaultAdjustments.xml');

% use Docker, if present
mitsuba.dockerImage = 'ninjaben/mitsuba-docker';

setpref('Mitsuba', fieldnames(mitsuba), struct2cell(mitsuba));

%% Locate PBRT.
pbrt.radiometricScaleFactor = 0.0063831432;
pbrt.S = [400 10 31];
[~, p] = system('which pbrt');
pbrt.executable = strtrim(p);

% version 2 compatibility
pbrt.adjustments = fullfile(rtbRoot(), ...
    'BatchRenderer', 'Version2Strategy', 'Deprecated', ...
    'RendererPlugins', 'PBRT', 'PBRTDefaultAdjustments.xml');

% use Docker, if present
pbrt.dockerImage = 'ninjaben/pbrt-v2-spectral-docker';
pbrt.dockerCommand = 'pbrt';

setpref('PBRT', fieldnames(pbrt), struct2cell(pbrt));
