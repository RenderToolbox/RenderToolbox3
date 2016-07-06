function recipe = rtbReadRecipeConditions(recipe)
%% Parse conditions from file and save in recipe struct
%
% recipe = rtbReadRecipeConditions(recipe) reads RenderToolbox3 conditions
% from recipe.input.conditionsFile and saves the results in
% recipe.rendering.conditions.
%
% Returns the given recipe, with parsed conditions.
%
% recipe = rtbReadRecipeConditions(recipe)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('recipe', @isstruct);
parser.parse(recipe);
recipe = parser.Results.recipe;

recipe.rendering.conditions = [];
if IsStructFieldPresent(recipe.input, 'conditionsFile')
    [recipe.rendering.conditions.names, ...
        recipe.rendering.conditions.values] = ...
        rtbParseConditions(recipe.input.conditionsFile);
end
