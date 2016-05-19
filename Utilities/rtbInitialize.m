function rtbInitialize(varargin)
%% Create Matlab preferences for RenderToolbox3.
%
% rtbInitialize() chooses paths and other constants for
% RenderToolbox3, and makes these available with Matlab's setpref() and
% getpref() functions.
%
% rtbInitialize( ... 'force', force) specifies whether to leave
% existing RenderToolbox3 preferences in place (false), or to replace
% existing preferences with default values (true).  The default is false,
% leave existing values alone.
%
% See RenderToolbox3ConfigurationTemplate.m for examples of how to set up
% custom RenderToolbox3 preferences.
%
% To see all the RenderToolbox3 default preferences, try:
%   rtbInitialize(true);
%   RenderToolbox3Prefs = getpref('RenderToolbox3')
%
% You can also set the folder where RenderToolbox3 will look for files and
% write new files.
%   setpref('RenderToolbox3', 'workingFolder', path-to-tempFolder);
%
% You can also set other defaults that RenderToolbox3 will use when no
% "hints" are provided.  For example,
%   % default ouput image dimensions
%   setpref('RenderToolbox3', 'imageHeight', 480);
%   setpref('RenderToolbox3', 'imageWidth', 640);
%
% Setting these values with setpref() makes the changes persistent.
% Normally you can set the same values in a temporary way, using a "hints"
% struct.  See GetDefaultHints().
%
% rtbInitialize(varargin)
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addParameter('force', false, @islogical);
parser.parse(varargin{:});
force = parser.Results.force;


%% Choose "out of the box" configuration.

% default input and output location
defaultConfig.workingFolder = fullfile(GetUserFolder(), 'render-toolbox');
defaultConfig.recipeName = '';

% default scene file and rendering options
defaultConfig.batchRenderStrategy = 'RtbVersion2Strategy';
defaultConfig.renderer = 'SampleRenderer';
defaultConfig.imageHeight = 240;
defaultConfig.imageWidth = 320;
defaultConfig.whichConditions = [];
defaultConfig.isReuseSceneFiles = false;
defaultConfig.isParallel = false;
defaultConfig.isCaptureCommandResults = true;

%% Replace or update current preferences.
RENDER_TOOLBOX_3 = 'RenderToolbox3';
if force && ispref(RENDER_TOOLBOX_3)
    % start config from scratch
    rmpref(RENDER_TOOLBOX_3);
end

configFields = fieldnames(defaultConfig);
for ii = 1:numel(configFields)
    field = configFields{ii};
    if ~ispref(RENDER_TOOLBOX_3, field)
        setpref(RENDER_TOOLBOX_3, field, defaultConfig.(field));
    end
end
