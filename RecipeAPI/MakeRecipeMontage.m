function recipe = MakeRecipeMontage(recipe, varargin)
%% Make an sRGB montage from a recipe's radianceDataFiles.
%
% recipe = MakeRecipeMontage(recipe) Uses the given recipe's radiance data
% files to make an sRGB montage.
%
% recipe = MakeRecipeMontage( ... 'toneMapFactor', toneMapFactor) specify a
% simple tone mapping threshold -- luminances above this factor times the
% mean luminance will be truncated.  The default is 0, don't truncate
% luminances.
%
% recipe = MakeRecipeMontage( ... 'isScale', isScale) specify whether to
% scale the output image so that the image maxiumum is the display maximum.
% The default is false, don't scale the image.
%
% Returns the given recipe, with recipe.processing.xyzMontage and
% recipe.processing.srgbMontage and filled in.
%
% recipe = MakeRecipeMontage(recipe, varargin)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('recipe', @isstruct);
parser.addParameter('toneMapFactor', 0, @isnumeric);
parser.addParameter('isScale', false, @islogical);
parser.parse(recipe);
recipe = parser.Results.recipe;
toneMapFactor = parser.Results.toneMapFactor;
isScale = parser.Results.isScale;

recipe = ChangeToRecipeFolder(recipe);

recipe.processing.xyzMontage = [];
recipe.processing.srgbMontage = [];
errorData = [];
try
    montageName = recipe.input.hints.recipeName;
    montageFile = [montageName '.png'];
    
    [recipe.processing.srgbMontage, recipe.processing.xyzMontage] = ...
        MakeMontage(recipe.rendering.radianceDataFiles, ...
        'outFile', montageFile, ...
        'toneMapFactor', toneMapFactor, ...
        'isScale', isScale, ...
        'hints', recipe.input.hints);
    
    if IsStructFieldPresent(recipe.processing, 'images')
        recipe.processing.images{end+1} = montageFile;
    else
        recipe.processing.images = {montageFile};
    end
    
catch errorData
    % fills in placeholder above, log it below
end

% put this execution in the log with any error data
recipe = AppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    @MakeMontage, errorData, 0);
