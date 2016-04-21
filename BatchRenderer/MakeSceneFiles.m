function scenes = MakeSceneFiles(colladaFile, varargin)
%% Make a family of renderer-native scenes based on a Collada parent scene.
%
% scenes = MakeSceneFiles(colladaFile)
% Creates a family of renderer-native scenes, based on the given
% colladaFile.  colladaFile must be a Collada XML parent scene file.
%
% scenes = MakeSceneFiles(... 'conditionsFile', conditionsFile)
% Specify the conditionsFile which specifies how many scenes to generate
% and parameters for each scene.  See the RenderToolbox3 wiki for more
% about the conditions file format:
%   https://github.com/RenderToolbox3/RenderToolbox3/wiki/Conditions-File-Format
%
% scenes = MakeSceneFiles(... 'mappingsFile', mappingsFile)
% Specify the mappingsFile which specifies how to map conditions file
% variables and other constants to the parent scene.  See the
% RenderToolbox3 wiki for more  about the mappings file format:
%   https://github.com/RenderToolbox3/RenderToolbox3/wiki/Mappings-File-Format
%
% scenes = MakeSceneFiles(... 'hints', hints)
% Specify a struct of options that affect the process of generating
% renderer-native scene files.  If hints is omitted, values are taken
% from GetDefaultHints().
%   - hints.renderer specifies which renderer to target
%   - hints.tempFolder is the default location for new renderer-native
%   scene files
%   - hints.filmType is a renderer-specific film type to specify for the
%   scene
%   - hints.imageHeight and @a hints.imageWidth specify the image pixel
%   dimensions to specify for the scene
%   - hints.whichConditions is an array of condition numbers used to
%   select rows from the @a conditionsFile.
%   - hints.isReuseSceneFiles specefies whether or not renderer
%   ImportCollada functions should attempt to to skip actual scene file
%   creation, and use existing files instead.
%
% This function uses RenderToolbox3 renderer API functions "ApplyMappings"
% and "ImportCollada".  These functions, for the renderer specified in
% hints.renderer, must be on the Matlab path.
%
% Returns a cell array of new renderer-native scene descriptions.  By
% default, each scene file will have the same base name as the given
% colladaFile, plus a numeric suffix.  If conditionsFile contains an
% 'imageName' variable, each scene file be named with the value of
% 'imageName'.
%
% scenes = MakeSceneFiles(colladaFile, varargin)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('colladaFile', @ischar);
parser.addParameter('conditionsFile', '', @ischar);
parser.addParameter('mappingsFile', fullfile(RenderToolboxRoot(), 'RenderData', 'DefaultMappings.txt'), @ischar);
parser.addParameter('hints', GetDefaultHints(), @isstruct);
parser.parse(colladaFile, varargin{:});
colladaFile = parser.Results.colladaFile;
conditionsFile = parser.Results.conditionsFile;
mappingsFile = parser.Results.mappingsFile;
hints = GetDefaultHints(parser.Results.hints);

InitializeRenderToolbox();

fprintf('\nMakeSceneFiles started at %s.\n\n', datestr(now(), 0));

%% Read conditions file into memory.
if isempty(conditionsFile)
    % no conditions, do a single rendering
    nConditions = 1;
    varNames = {};
    varValues = {};
    
else
    % read variables and values for each condition
    [varNames, varValues] = ParseConditions(conditionsFile);
    
    % choose which conditions to render
    if isempty(hints.whichConditions)
        hints.whichConditions = 1:size(varValues, 1);
    end
    nConditions = numel(hints.whichConditions);
    varValues = varValues(hints.whichConditions,:);
end

%% Call out the original Collada authoring tool (Blender, etc.)
%   any remodelling function might have modified the authoring info
authoringTool = GetColladaAuthorInfo(colladaFile);
fprintf('Original Collada scene authored with %s.\n\n', authoringTool);

%% Allow remodeler to modify Collada document before all else.
colladaFile = remodelCollada(colladaFile, hints, 'BeforeAll');

%% Make a scene file for each condition.
scenes = cell(1, nConditions);

err = [];
try
    fprintf('\nMakeSceneFiles started with isParallel=%d at %s.\n\n', ...
        hints.isParallel, datestr(now(), 0));
    renderTick = tic();
    
    if hints.isParallel
        % distributed "parfor" loop
        parfor cc = 1:nConditions
            % choose variable values for this condition
            if isempty(varValues)
                conditionVarValues = {};
            else
                conditionVarValues = varValues(cc,:);
            end
            
            % make a the scene file for this condition
            scenes{cc} = makeSceneForCondition( ...
                colladaFile, mappingsFile, cc, ...
                varNames, conditionVarValues, hints);
        end
    else
        % local "for" loop
        for cc = 1:nConditions
            % choose variable values for this condition
            if isempty(varValues)
                conditionVarValues = {};
            else
                conditionVarValues = varValues(cc,:);
            end
            
            % make a the scene file for this condition
            scenes{cc} = makeSceneForCondition( ...
                colladaFile, mappingsFile, cc, ...
                varNames, conditionVarValues, hints);
        end
    end
    
    fprintf('\nMakeSceneFiles finished at %s (%.1fs elapsed).\n\n', ...
        datestr(now(), 0), toc(renderTick));
    
catch err
    disp('Scene conversion error!');
end

% report any error
if ~isempty(err)
    rethrow(err)
end


%% Remodel the Collada file into a new file.
function colladaCopy = remodelCollada(colladaFile, hints, functionName, varargin)
colladaCopy = colladaFile;
if ~isempty(colladaFile) && ~isempty(hints.remodeler)
    % get the user-defined remodeler function
    remodelerFunction = GetRemodelerAPIFunction(functionName, hints);
    if ~isempty(remodelerFunction)
        % read original Collada document into memory
        [scenePath, sceneBase, sceneExt] = fileparts(colladaFile);
        if isempty(scenePath) && exist(colladaFile, 'file')
            info = ResolveFilePath(colladaFile, GetWorkingFolder('', false, hints));
            colladaFile = info.absolutePath;
        end
        colladaDoc = ReadSceneDOM(colladaFile);
        
        % apply the remodeler function with given arguments
        colladaDoc = feval(remodelerFunction, colladaDoc, varargin{:}, hints);
        
        % write modified document to new file
        tempFolder = fullfile(GetWorkingFolder('temp', true, hints));
        colladaCopy = fullfile(tempFolder, [sceneBase '-' functionName sceneExt]);
        WriteSceneDOM(colladaCopy, colladaDoc);
    end
end


%% Create a renderer-native scene description for one condition.
function scene = makeSceneForCondition(colladaFile, mappingsFile, ...
    conditionNumber, varNames, varValues, hints)

scene = [];

%% Choose parameter values from conditions file or hints.
isMatch = strcmp('renderer', varNames);
if any(isMatch)
    hints.renderer = varValues{find(isMatch, 1, 'first')};
end

isMatch = strcmp('colladaFile', varNames);
if any(isMatch)
    colladaFile = varValues{find(isMatch, 1, 'first')};
end
[scenePath, sceneBase, sceneExt] = fileparts(colladaFile);
if isempty(scenePath) && exist(colladaFile, 'file')
    fileInfo = ResolveFilePath(colladaFile, GetWorkingFolder('', false, hints));
    colladaFile = fileInfo.absolutePath;
end

if isempty(colladaFile)
    return;
end

isMatch = strcmp('mappingsFile', varNames);
if any(isMatch)
    mappingsFile = varValues{find(isMatch, 1, 'first')};
end
mappings = ParseMappings(mappingsFile);

isMatch = strcmp('imageName', varNames);
if any(isMatch)
    imageName = varValues{find(isMatch, 1, 'first')};
else
    imageName = sprintf('%s-%03d', sceneBase, conditionNumber);
end

isMatch = strcmp('imageHeight', varNames);
if any(isMatch)
    num = StringToVector(varValues{find(isMatch, 1, 'first')});
    hints.imageHeight = num;
end
isMatch = strcmp('imageWidth', varNames);
if any(isMatch)
    num = StringToVector(varValues{find(isMatch, 1, 'first')});
    hints.imageWidth = num;
end

isMatch = strcmp('groupName', varNames);
if any(isMatch)
    groupName = varValues(find(isMatch, 1, 'first'));
else
    groupName = '';
end


%% Copy the collada file and reduce to known characters and elements.

% strip out non-ascii 7-bit characters
tempFolder = GetWorkingFolder('temp', true, hints);
collada7Bit = fullfile(tempFolder, [sceneBase '-' imageName '-7bit' sceneExt]);
WriteASCII7BitOnly(colladaFile, collada7Bit);

% clean up Collada elements and resource paths
colladaDoc = ReadSceneDOM(collada7Bit);
workingFolder = GetWorkingFolder('', false, hints);
cleanDoc = CleanUpColladaDocument(colladaDoc, workingFolder);
colladaCopy = fullfile(tempFolder, [sceneBase '-' imageName '-7bit-clean' sceneExt]);
WriteSceneDOM(colladaCopy, cleanDoc);

%% Initialize renderer-native adjustments to receive mappings data.
applyMappingsFunction = ...
    GetRendererAPIFunction('ApplyMappings', hints);
if isempty(applyMappingsFunction)
    return;
end
adjustments = feval(applyMappingsFunction, [], []);

%% Apply mappings to the renderer-native adjustments.
% replace various mappings file expressions with concrete values
mappings = ResolveMappingsValues( ...
    mappings, varNames, varValues, colladaCopy, adjustments, hints);

%% Allow remodeler to modify Collada document before each condition.
colladaCopy = remodelCollada(colladaCopy, hints, 'BeforeCondition', ...
    mappings, varNames, varValues, conditionNumber);

%% Update the renderer-native adjustments to for each block of mappings.
blockNums = [mappings.blockNumber];
rendererName = hints.renderer;
rendererPathName = [rendererName '-path'];
if ~isempty(mappings)
    for bb = unique(blockNums)
        
        % get all mappings from one block
        blockMappings = mappings(bb == blockNums);
        blockGroup = blockMappings(1).group;
        blockType = blockMappings(1).blockType;
        
        % choose mappings for an active groupName
        isInGroup = isempty(groupName) ...
            || isempty(blockGroup) || strcmp(groupName, blockGroup);
        
        if any(isInGroup)
            switch blockType
                case 'Collada'
                    % DOM paths apply directly to Collada
                    [colladaDoc, colladaIDMap] = ReadSceneDOM(colladaCopy);
                    ApplySceneDOMPaths(colladaIDMap, blockMappings);
                    WriteSceneDOM(colladaCopy, colladaDoc);
                    
                case 'Generic'
                    % scene targets apply to adjustments
                    objects = MappingsToObjects(blockMappings);
                    objects = SupplementGenericObjects(objects);
                    adjustments = ...
                        feval(applyMappingsFunction, objects, adjustments);
                    
                case rendererName
                    % scene targets to apply to adjustments
                    objects = MappingsToObjects(blockMappings);
                    adjustments = ...
                        feval(applyMappingsFunction, objects, adjustments);
                    
                case rendererPathName
                    adjustments = ...
                        feval(applyMappingsFunction, blockMappings, adjustments);
            end
        end
    end
end

%% Allow remodeler to modify Collada document after each condition.
colladaCopy = remodelCollada(colladaCopy, hints, 'AfterCondition', ...
    mappings, varNames, varValues, conditionNumber);

%% Produce a renderer-native scene from Collada and adjustments.
importColladaFunction = ...
    GetRendererAPIFunction('ImportCollada', hints);
if isempty(importColladaFunction)
    return;
end
scene = feval( ...
    importColladaFunction, colladaCopy, adjustments, imageName, hints);
[scene.imageName] = deal(imageName);

% store Collada authoring info along with the scene description
%   authoring info may have been set by a remodeler!
[authoringTool, asset] = GetColladaAuthorInfo(colladaCopy);
authorInfo.authoringTool = authoringTool;
authorInfo.asset = asset;
[scene.authorInfo] = deal(authorInfo);
