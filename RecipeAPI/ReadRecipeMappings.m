function recipe = ReadRecipeMappings(recipe)
%% Parse mappings from file and save in recipe struct
%
% recipe = ReadRecipeMappings(recipe) reads RenderToolbox3 mappings from
% recipe.input.mappingsFile and saves the results in
% recipe.rendering.mappings.
%
% Returns the given recipe, with parsed mappings.
%
% recipe = ReadRecipeMappings(recipe)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('recipe', @isstruct);
parser.parse(recipe);
recipe = parser.Results.recipe;

recipe.rendering.mappings = [];
if IsStructFieldPresent(recipe.input, 'mappingsFile')
    recipe.rendering.mappings = ...
        ParseMappings(recipe.input.mappingsFile);
end
