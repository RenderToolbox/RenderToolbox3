function [renderResults, comparison] = RenderToolbox3InstallationTest(varargin)
% Make sure a new RenderToolbox3 installation is working.
%
% RenderToolbox3InstallationTest() Initializes RenderToolbox3 after
% installation and then put it through some basic tests.  If this function
% runs properly, you're off to the races.
%
% RenderToolbox3InstallationTest( ... 'referenceRoot', referenceRoot)
% provide the path to a set of RenderToolbox3 reference data.  Rendering
% produced locally will be compared to renderings in the reference data
% set.
%
% RenderToolbox3InstallationTest( ... 'doAll', doAll) specify whether to to
% all available test renderings (true), or just a few (false). The default
% is false, do just a few test renderings.
%
% Returns a struct of results from rendering test scenes.  If
% referenceRoot is provided, also returns a struct of comparisons between
% local renderings and reference renderings.
%
% [renderResults, comparison] = RenderToolbox3InstallationTest(varargin)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addParameter('referenceRoot', '', @ischar);
parser.addParameter('doAll', false, @islogical);
parser.parse(varargin{:});
referenceRoot = parser.Results.referenceRoot;
doAll = parser.Results.doAll;

renderResults = [];
comparison = [];

%% Check working folder for write permission.
workingFolder = rtbWorkingFolder();
fprintf('\nChecking working folder:\n');

% make sure the folder exists
if exist(workingFolder, 'dir')
    fprintf('  folder exists: %s\n', workingFolder);
    fprintf('  OK.\n');
else
    fprintf('  creating folder: %s\n', workingFolder);
    [status, message] = mkdir(workingFolder);
    if 1 == status
        fprintf('  OK.\n');
    else
        error('Could not create folder %s:\n  %s\n', ...
            workingFolder, message);
    end
end

% make sure Matlab can write to the folder
testFile = fullfile(workingFolder, 'test.txt');
fprintf('Trying to write: %s\n', testFile);
[fid, message] = fopen(testFile, 'w');
if fid < 0
    error('Could not write to folder %s:\n  %s\n', ...
        workingFolder, message);
end
fclose(fid);
delete(testFile);
fprintf('  OK.\n');

%% Locate Mitsuba and pbrt executables.
if ismac()
    % locate Mitsuba.app
    execPrefs(1).prefGroup = 'Mitsuba';
    execPrefs(1).prefName = 'app';
    
    % locate pbrt
    execPrefs(2).prefGroup = 'PBRT';
    execPrefs(2).prefName = 'executable';
    
else
    % locate Mitsuba executable
    execPrefs(1).prefGroup = 'Mitsuba';
    execPrefs(1).prefName = 'executable';
    
    % locate Mitsuba importer
    execPrefs(2).prefGroup = 'Mitsuba';
    execPrefs(2).prefName = 'importer';
    
    % locate pbrt
    execPrefs(3).prefGroup = 'PBRT';
    execPrefs(3).prefName = 'executable';
end

% locate each executable or let the user choose
for ii = 1:numel(execPrefs)
    % get the default executable path from preferences
    execFile = getpref(execPrefs(ii).prefGroup, execPrefs(ii).prefName);
    
    fprintf('\nChecking %s %s:\n', ...
        execPrefs(ii).prefGroup, execPrefs(ii).prefName);
    
    % make sure the executable exists
    if exist(execFile, 'file')
        fprintf('  %s exists: %s\n', execPrefs(ii).prefName, execFile);
        fprintf('  OK.\n');
    else
        error('Could not find %s %s:\n  %s\n', ...
            execPrefs(ii).prefGroup, execPrefs(ii).prefName, execFile);
    end
end

%% Render some example scenes.
if doAll
    fprintf('\nTesting rendering with all example scripts.\n');
    fprintf('This might take a while.\n');
    renderResults = TestAllExampleScenes([], []);
    
else
    testScenes = { ...
        'MakeCoordinatesTest.m', ...
        'MakeDragon.m', ...
        'MakeMaterialSphereBumps.m', ...
        'MakeMaterialSphereRemodeled.m'};
    
    fprintf('\nTesting rendering with %d example scripts.\n', numel(testScenes));
    fprintf('You should see several figures with rendered images.\n\n');
    renderResults = TestAllExampleScenes([], testScenes);
    
end

if all([renderResults.isSuccess])
    fprintf('\nYour RenderToolbox3 installation seems to be working!\n');
end

%% Compare renderings to reference renderings?
if ~isempty(referenceRoot)
    localRoot = rtbWorkingFolder();
    fprintf('\nComparing local renderings\n  %s\n', localRoot);
    fprintf('with reference renderings\n  %s\n', referenceRoot);
    fprintf('You should see several more figures.\n\n');
    comparison = CompareAllExampleScenes(localRoot, referenceRoot, '', 2);
else
    fprintf('\nNo referenceRoot provided.  Local renderings\n');
    fprintf('will not be compared with reference renderings.\n');
end
