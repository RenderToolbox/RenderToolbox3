function recipe = NewRecipe(varargin)
%% Start a new recipe from scratch.
%
% recipe = NewRecipe()
% Create a brand new RenderToolbo3 recipe struct with standard fields and
% default values. The default recipe will be not-vert-useful, but will have
% the correct form.
%
% recipe = NewRecipe( ... 'configureScript', configureScript) specify the
% the name of a RenderToolbox3 system configuration script to run before
% executing the recipe.  This might be a locally modified copy of
% RenderToolbox3ConfigurationTemplate.m.
%
% recipe = NewRecipe( ... 'executive', executive) specify a cell array of
% function_handles or string script names to be executed for this recipe.
% All function_handles must refer to functions that expect a recipe as the
% first argument return the recipe as the first output.  All strings must
% refer to m-files that use CurrentRecipe() to access and modify the
% current recipe.
%
% recipe = NewRecipe( ... 'parentSceneFile', parentSceneFile) specify the
% recipe's parent scene file, such as a Collada file.
%
% recipe = NewRecipe( ... 'conditionsFile', conditionsFile) specify the
% name of a RenderToolbox3 conditions file used to control the number of
% and variables used when generating variations on the parent scene file.
%
% recipe = NewRecipe( ... 'mappingsFile', mappingsFile) specify the name of
% a RenderToolbox3 mappings file used to map constants and conditions file
% variables to the parent scene.
%
% recipe = NewRecipe( ... 'hints', hints) specify a a struct of hints as
% from GetDefaultHints(), which controls aspects of recuipe execution, like
% where to find and write files and which renderer to use.
%
% recipe = NewRecipe(varargin)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%

parser = inputParser();
parser.addParameter('configureScript', '', @ischar);
parser.addParameter('executive', {}, @iscell);
parser.addParameter('parentSceneFile', '', @ischar);
parser.addParameter('conditionsFile', '', @ischar);
parser.addParameter('mappingsFile', '', @ischar);
parser.addParameter('hints', GetDefaultHints(), @isstruct);
parser.parse(varargin{:});
configureScript = parser.Results.configureScript;
executive = parser.Results.executive;
parentSceneFile = parser.Results.parentSceneFile;
conditionsFile = parser.Results.conditionsFile;
mappingsFile = parser.Results.mappingsFile;
hints = GetDefaultHints(parser.Results.hints);

%% Brand new recipe struct with basic fields filled in.
% note: struct() needs executive cell array to be wrapped in another cell
basic = struct( ...
    'configureScript', configureScript, ...
    'executive', {executive}, ...
    'parentSceneFile', parentSceneFile, ...
    'conditionsFile', conditionsFile, ...
    'mappingsFile', mappingsFile, ...
    'hints', hints);
recipe.input = basic;

%% Derive conditions and mappings from respective files.
recipe = ReadRecipeConditions(recipe);
recipe = ReadRecipeMappings(recipe);

%% "CleanRecipe" is the origin of all other derived field names.
recipe = CleanRecipe(recipe);
