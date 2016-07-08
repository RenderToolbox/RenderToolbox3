%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada parent scene file the Mitsuba native format
%   @param colladaFile input Collada parent scene file name or path
%   @param adjustments native adjustments data, or file name or path
%   @param imageName the name to use for this scene and new files
%   @param hints struct of RenderToolbox3 options
%
% @details
% This is the RenderToolbox3 "ImportCollada" function for Mitsuba.
%
% @details
% For more about ImportCollada functions see
% RTB_ImportCollada_SampleRenderer().
%
% @details
% Usage:
%   scene = RTB_ImportCollada_Mitsuba(colladaFile, adjustments, imageName, hints)
function scene = RTB_ImportCollada_Mitsuba(colladaFile, adjustments, imageName, hints)

% choose new files to create
scenesFolder = rtbWorkingFolder( ...
    'folderName', 'scenes', ...
    'rendererSpecific', true, ...
    'hints', hints);
tempFolder = rtbWorkingFolder( ...
    'folderName', 'temp', ...
    'rendererSpecific', true, ...
    'hints', hints);
mitsubaFile = fullfile(scenesFolder, [imageName '.xml']);
unadjustedMitsubaFile = fullfile(tempFolder, [imageName 'Unadjusted.xml']);
geometryFile = fullfile(tempFolder, [imageName 'Unadjusted.serialized']);
adjustmentsFile = fullfile(tempFolder, [imageName 'Adjustments.xml']);

% report new files as relative paths
scene.colladaFile = rtbGetWorkingRelativePath(colladaFile, 'hints', hints);
scene.mitsubaFile = rtbGetWorkingRelativePath(mitsubaFile, 'hints', hints);
scene.unadjustedMitsubaFile = rtbGetWorkingRelativePath(unadjustedMitsubaFile, 'hints', hints);
scene.geometryFile = rtbGetWorkingRelativePath(geometryFile, 'hints', hints);
scene.adjustmentsFile = rtbGetWorkingRelativePath(adjustmentsFile, 'hints', hints);

% high-dynamic-range is a good default film for Mitsuba
if isempty(hints.filmType)
    hints.filmType = 'hdrfilm';
end

if hints.isReuseSceneFiles
    % locate exsiting scene files, but don't produce new ones
    disp('Reusing scene files for Mitsuba scene:')
    disp(scene)
    drawnow();
    
else
    
    %% Invoke the Mitsuba importer.
    
    % invoke the Mitsuba importer
    libPathName = getpref('Mitsuba', 'libraryPathName');
    libPath = getpref('Mitsuba', 'libraryPath');
    importer = fullfile( ...
        getpref('Mitsuba', 'app'), ...
        getpref('Mitsuba', 'importer'));
    fprintf('Converting %s\n  to %s.\n', colladaFile, mitsubaFile);
    importCommand = sprintf('%s="%s" "%s" -r %dx%d -l %s "%s" "%s"', ...
        libPathName, ...
        libPath, ...
        importer, ...
        hints.imageWidth, hints.imageHeight, ...
        hints.filmType, ...
        colladaFile, ...
        unadjustedMitsubaFile);
    
    [status, result] = unix(importCommand);
    if status ~= 0
        error('Mitsuba file conversion failed\n  %s\n  %s\n', ...
            colladaFile, result);
    end
    
    %% Copy Mitsuba's serialized geometry from temp to scene folder.
    if exist(geometryFile, 'file')
        movefile(geometryFile, scenesFolder);
    end
    
    %% Apply adjustments using the RenderToolbox3 custom mechanism.
    %   Mitsuba nodes named "ref" have "id" attrubutes, but are not "id" nodes
    excludePattern = '^ref$';
    mitsubaDoc = ReadSceneDOM(unadjustedMitsubaFile, excludePattern);
    MergeAdjustments(mitsubaDoc, adjustments.docNode, excludePattern);
    WriteSceneDOM(mitsubaFile, mitsubaDoc);
    WriteSceneDOM(adjustmentsFile, adjustments.docNode);
end
