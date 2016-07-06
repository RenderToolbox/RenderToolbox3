%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Load a recipe and its file dependencies from an archive file.
%   @param archiveName name of the archive file to unpack
%   @param hints struct of RenderToolbox3 options, see rtbDefaultHints()
%
% @details
% Creates a new recipe struct based on the given @a archiveName, as
% produced by rtbPackUpRecipe().  Also unpacks recipe file dependencies that
% were saved in the archive, to the current working folder.
%
% @details
% Returns a new recipe struct that was contained in the given @a
% archiveName.
%
% @details
% Usage:
%   recipe = rtbUnpackRecipe(archiveName, hints)
%
% @ingroup RecipeAPI
function recipe = rtbUnpackRecipe(archiveName, hints)

if nargin < 1 || ~exist(archiveName, 'file')
    error('You must suplpy the name of an archive file');
end
[archivePath, archiveBase] = fileparts(archiveName);

if nargin < 2
    hints = rtbDefaultHints();
else
    hints = rtbDefaultHints(hints);
end

%% Set up a clean, temporary folder.
hints.recipeName = mfilename();
tempFolder = rtbWorkingFolder('', false, hints);
if exist(tempFolder, 'dir')
    rmdir(tempFolder, 's');
end
ChangeToFolder(tempFolder);

%% Unpack the archive to the temporary folder.
unzip(archiveName, tempFolder);

% extract the recipe struct
recipeFiles = FindFiles('root', tempFolder, 'filter', 'recipe\.mat');
if 1 == numel(recipeFiles)
    recipeFileName = recipeFiles{1};
else
    error('RenderToolbox3:UnpackRecipeNotFound', ...
        ['Could not find recipe.mat in the given archive ' archiveName]);
end
matData = load(recipeFileName);
recipe = matData.recipe;

%% Update recipe hints with local configuration.
recipe.input.hints.workingFolder = hints.workingFolder;

%% Copy dependencies from the temp folder to the local working folder.
unpackedFolder = fullfile(tempFolder, archiveBase);
dependencies = FindFiles('root', unpackedFolder);
for ii = 1:numel(dependencies)
    tempPath = dependencies{ii};
    if strfind(tempPath, 'recipe.mat')
        continue;
    end
    
    [isPrefix, relativePath] = IsPathPrefix(unpackedFolder, tempPath);
    localPath = rtbWorkingAbsolutePath(relativePath, recipe.input.hints);
    
    localPrefix = fileparts(localPath);
    if ~exist(localPrefix, 'dir')
        mkdir(localPrefix);
    end
    
    [isSuccess, message] = copyfile(tempPath, localPath);
    if ~isSuccess
        warning('RenderToolbox3:UnpackRecipeCopyError', ...
            ['Error unpacking recipe file: ' message]);
    end
end

%% Clean up.
rmdir(tempFolder, 's');
