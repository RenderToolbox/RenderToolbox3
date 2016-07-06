function recipe = rtbMakeRecipeSceneFiles(recipe)
%% Generate native scene files for the given recipe.
%
% recipe = rtbMakeRecipeSceneFiles(recipe) Uses the given recipe's parent
% scene file, conditions file, and mappings file to generate
% renderer-native scene files for the renderer
% specified in recipe.input.hints.renderer.
%
% Returns the given @a recipe, with @a recipe.rendering.scenes filled in.
%
% recipe = rtbMakeRecipeSceneFiles(recipe)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('recipe', @isstruct);
parser.parse(recipe);
recipe = parser.Results.recipe;

recipe = rtbChangeToRecipeFolder(recipe);
workingFolder = pwd();

recipe.rendering.scenes = {};
errorData = [];
try
    recipe.rendering.scenes = rtbMakeSceneFiles( ...
        locateWorkingResource(recipe.input.parentSceneFile, workingFolder), ...
        'conditionsFile', locateWorkingResource(recipe.input.conditionsFile, workingFolder), ...
        'mappingsFile', locateWorkingResource(recipe.input.mappingsFile, workingFolder), ...
        'hints', recipe.input.hints);
    
catch errorData
    % fills in placeholder above, log it below
end

% put this execution in the log with any error data
recipe = rtbAppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    @MakeSceneFiles, errorData, 0);

%% Locate input files, possibly from relative paths
function resourcePath = locateWorkingResource(resourceName, workingFolder)
resourceInfo = ResolveFilePath(resourceName, workingFolder);
if ~isempty(resourceInfo.absolutePath)
    resourcePath = resourceInfo.absolutePath;
    return;
end
resourcePath = resourceInfo.verbatimName;
