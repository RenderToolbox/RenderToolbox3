function outFiles = BatchRender(scenes, varargin)
% Render multiple scenes at once.
%
% outFiles = BatchRender(scenes)
% Renders multiple renderer-native scene files in one batch.  scenes
% must be a cell array of renderer-native scene descriptions or scene
% files, such as those produced by MakeSceneFiles().  All renderer-native
% files should be intended for the same renderer.
%
% outFiles = BatchRender(... 'hints', hints)
% Specify a hints struct with with options that affect the rendering
% process, as returned from GetDefaultHints().  If hints is omitted,
% default options are used.  For example:
%   - hints.renderer specifies which renderer to use
%   - hints.isParallel specifies whether to render in a "parfor" loop
%   - hints.workingFolder specefies where to store multi-spectral
%   radiance data files.
%   - hints.isDryRun specefies whether or not to skip actual rendering.
%   .
%
% Renders each renderer-native scene in scenes, and writes a new mat-file
% for each one.  Each mat-file will contain several variables including:
%   - multispectralImage - matrix of multi-spectral radiance data with size
%   [height width n]
%   - S - spectral band description for the rendering with elements [start
%   delta n]
%
% height and width are pixel image dimensions and n is the number of
% spectral bands in the image.  See the RenderToolbox3 wiki for more about
% spectrum bands:
%  https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands
%
% The each mat-file will also contain variables with metadata about how the
% scene was made and rendererd:
%   - scene - the renderer-native scene description (e.g. file name,
%   Collada author info)
%   - hints - the given hints struct, or default hints struct
%   - versionInfo - struct of version information about RenderToolbox3,
%   its dependencies, and the current renderer
%   - commandResult - text output from the the current renderer
%   - radiometricScaleFactor - scale factor that was used to bring renderer
%   ouput into physical radiance units
%
% This function uses RenderToolbox3 renderer API functions "Render",
% "DataToRadiance", and "VersionInfo".  These functions, for the renderer
% specified in hints.renderer, must be on the Matlab path.
%
% Returns a cell array of output mat-file names, with the same dimensions
% as the given scenes.
%
% outFiles = BatchRender(scenes, varargin)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('scenes', @iscell);
parser.addParameter('hints', GetDefaultHints(), @isstruct);
parser.parse(scenes, varargin{:});
scenes = parser.Results.scenes;
hints = GetDefaultHints(parser.Results.hints);

InitializeRenderToolbox();

%% Render each scene file.
% save toolbox version info with renderings
versionInfo = GetRenderToolbox3VersionInfo();

% render with local "for" or distributed "parfor" loop
nScenes = numel(scenes);
outFiles = cell(size(scenes));
fprintf('\nBatchRender started with isParallel=%d at %s.\n\n', ...
    hints.isParallel, datestr(now(), 0));
renderTick = tic();
err = [];
try
    if hints.isParallel
        % distributed "parfor" loop, don't time individual iterations
        parfor ii = 1:nScenes
            outFiles{ii} = ...
                renderScene(scenes{ii}, versionInfo, hints);
        end
    else
        % local "for" loop, makes sense to time each iteration
        for ii = 1:nScenes
            fprintf('\nStarting scene %d of %d at %s (%.1fs elapsed).\n\n', ...
                ii, nScenes, datestr(now(), 0), toc(renderTick));
            
            outFiles{ii} = ...
                renderScene(scenes{ii}, versionInfo, hints);
            
            fprintf('\nFinished scene %d of %d at %s (%.1fs elapsed).\n\n', ...
                ii, nScenes, datestr(now(), 0), toc(renderTick));
        end
    end
catch err
    disp('Rendering error!')
end

fprintf('\nBatchRender finished at %s (%.1fs elapsed).\n\n', ...
    datestr(now(), 0), toc(renderTick));

% report the error, if any
if ~isempty(err)
    rethrow(err)
end

% Render a scene and save a .mat data file.
function outFile = renderScene(scene, versionInfo, hints)

outFile = '';

% if this is a dry run, skip the rendering
if hints.isDryRun
    disp(['Dry run of ' hints.renderer ' scene:'])
    disp(scene)
    drawnow();
    return;
end

% record renderer version info
versionInfoFunction = GetRendererAPIFunction('VersionInfo', hints);
if ~isempty(versionInfoFunction)
    versionInfo.rendererVersionInfo = feval(versionInfoFunction);
end

% render the scene
renderFunction = GetRendererAPIFunction('Render', hints);
if isempty(renderFunction)
    return
end

% renderer plugin need not preview results
hints.isPlot = false;
[status, commandResult, multispectralImage, S] = ...
    feval(renderFunction, scene, hints);
if 0 ~= status
    return
end

% convert rendered image to radiance units
dataToRadianceFunction = ...
    GetRendererAPIFunction('DataToRadiance', hints);
if isempty(dataToRadianceFunction)
    return
end
[multispectralImage, radiometricScaleFactor] = ...
    feval(dataToRadianceFunction, multispectralImage, scene, hints);

% save a .mat file with multispectral data and metadata
outPath = GetWorkingFolder('renderings', true, hints);
outFile = fullfile(outPath, [scene(1).imageName '.mat']);
save(outFile, 'multispectralImage', 'S', 'radiometricScaleFactor', ...
    'hints', 'scene', 'versionInfo', 'commandResult');
