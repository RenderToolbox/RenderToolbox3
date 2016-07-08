function recipe = rtbCurrentRecipe(recipe)
%% Get or set the RenderToolbox3 "current recipe".
%
% rtbCurrentRecipe() controls acceses to a Matlab persistent variable that
% holds the RenderToolbox3 "current recipe".  There can be only one current
% recipe at a time.  The current recipe is a central point of contact
% allowing various scripts that make up a recipe to interact.
%
% In general it's better to work with functions, where we can pass the
% current recipe as an explicit argument.  This function is available in
% case it's not possible to work with functions for some reason.
%
% rtbCurrentRecipe(recipe) sets the current recipe to the given recipe.
%
% recipe = rtbCurrentRecipe() gets the current recipe.
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

persistent CURRENT_RECIPE

if nargin > 0
    CURRENT_RECIPE = recipe;
end
recipe = CURRENT_RECIPE;
