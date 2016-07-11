%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the Dragon scene with 24 ColorChecker colors.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'Dragon.dae';
conditionsFile = 'DragonColorCheckerConditions.txt';
mappingsFile = 'DragonColorCheckerMappings.txt';

%% Choose batch renderer options.
hints.imageWidth = 150;
hints.imageHeight = 120;
hints.recipeName = mfilename();

hints.batchRenderStrategy = 'RtbVersion2Strategy';
hints.remodeler = '';
hints.filmType = '';

%% Make a fresh conditions file.
% choose spectrum file names and output image names
nSpectra = 24;
imageNames = cell(nSpectra, 1);
fileNames = cell(nSpectra, 1);
for ii = 1:nSpectra
    imageNames{ii} = sprintf('macbethDragon-%d', ii);
    fileNames{ii} = sprintf('mccBabel-%d.spd', ii);
end

% write file names and image names to a conditions file
varNames = {'imageName', 'dragonColor'};
varValues = cat(2, imageNames, fileNames);
conditionsFile = rtbWriteConditionsFile( ...
    fullfile(rtbWorkingFolder( ...
    'folderName', 'resources', ...
    'rendererSpecific', false, ...
    'hints', hints), conditionsFile), ...
    varNames, ...
    varValues);

%% Render with Mitsuba and PBRT.

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;

% make a montage with each renderer
for renderer = {'Mitsuba', 'PBRT'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 24 multi-spectral renderings, saved in .mat files
    nativeSceneFiles = rtbMakeSceneFiles(parentSceneFile, ...
        'conditionsFile', conditionsFile, ...
        'mappingsFile', mappingsFile, ...
        'hints', hints);
    radianceDataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);
    
    % condense multi-spectral renderings into one sRGB montage
    [SRGBMontage, XYZMontage] = ...
        rtbMakeMontage(radianceDataFiles, ...
        'toneMapfactor', toneMapFactor, ...
        'isScale', isScaleGamma, ...
        'hints', hints);
    
    % display the sRGB montage
    rtbShowXYZAndSRGB([], SRGBMontage, sprintf('%s (%s)', hints.recipeName, hints.renderer));
end
