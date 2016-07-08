function recipe = rtbCleanRecipe(recipe)
%% Clear out recipe derived data fileds.
%
% recipe = rtbCleanRecipe(recipe) clears out derived data fields from the
% given recupe and returns the updated recupe.
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('recipe', @isstruct);
parser.parse(recipe);
recipe = parser.Results.recipe;

% Clear all derived data fields
recipe.rendering = [];
recipe.processing = [];
recipe.dependencies = [];
recipe.log = [];