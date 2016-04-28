classdef RtbVersion2Strategy < RtbBatchRenderStrategy
    %% Implementation for how batch process with Collada.
    %
    % This implements a batch rendering strategy for the "old" way of doing
    % things with Collada and plain text mappings files.  This is intended
    % to reproduce functionality from RenderToolbox3, version 2, including
    % the functions MakeSceneFiles and BatchRender, the RemodelerPluginAPI.
    %
    % Here are some conventions -- how the Collada way of doing things fits
    % into the Strategy outline:
    %   - the basic scene representation is the name of the Collada file
    %   - conditoins are the usual tabular text file
    %   - mappings are the "old" plain text syntax
    %   - the native scene representation has two parts:
    %       - nativeScene.scene is info about the native scene file
    %       - nativeScene.adjustments holds data from mappings
    %   - resolveResources is a no-op because the work is already done by
    %   ResolveMappingsValues(), in applyVariablesToMappings
    %   - don't try to pass the "adjustmetns" file to
    %   ResolveMappingsValues().  We never use it.
    %
    
    properties
        hints = [];
    end
    
    methods
        function obj = RtbVersion2Strategy(hints)
            obj.hints = hints;
            obj.converter = RtbPluginConverter(hints);
            obj.renderer = RtbPluginRenderer(hints);
        end
    end
    
    methods
        function scene = loadScene(obj, sceneFile, imageName)
            % look carefully for the file
            [scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
            if isempty(scenePath) && exist(sceneFile, 'file')
                fileInfo = ResolveFilePath(sceneFile, GetWorkingFolder('', false, obj.hints));
                sceneFile = fileInfo.absolutePath;
            end
            
            % strip out non-ascii 7-bit characters
            tempFolder = GetWorkingFolder('temp', true, obj.hints);
            collada7Bit = fullfile(tempFolder, [sceneBase '-' imageName '-7bit' sceneExt]);
            WriteASCII7BitOnly(sceneFile, collada7Bit);
            
            % clean up Collada elements and resource paths
            colladaDoc = ReadSceneDOM(collada7Bit);
            workingFolder = GetWorkingFolder('', false, obj.hints);
            cleanDoc = CleanUpColladaDocument(colladaDoc, workingFolder);
            sceneCopy = fullfile(tempFolder, [sceneBase '-' imageName '-7bit-clean' sceneExt]);
            WriteSceneDOM(sceneCopy, cleanDoc);
            
            % call out the original Collada authoring tool (Blender, etc.)
            authoringTool = GetColladaAuthorInfo(sceneFile);
            fprintf('Original Collada scene authored with %s.\n\n', authoringTool);
            
            % the basic scene is just the file name
            scene = sceneCopy;
        end
        
        function scene = remodelBeforeAll(obj, scene)
            scene = obj.remodelCollada(scene, obj.hints, 'BeforeAll');
        end
        
        function [names, values] = loadConditions(obj, conditionsFile)
            if isempty(conditionsFile)
                % no conditions, do a single rendering
                names = {};
                values = {};
                
            else
                % read variables and values for each condition
                [names, values] = ParseConditions(conditionsFile);
            end
        end
        
        function mappings = loadMappings(obj, mappingsFile)
            if isempty(mappingsFile)
                mappingsFile = fullfile(RenderToolboxRoot(), ...
                    'Deprecated', 'RenderData', 'DefaultMappings.txt');
            end
            mappings = ParseMappings(mappingsFile);
        end
        
        function mappings = applyVariablesToMappings(obj, scene, mappings, names, values)
            mappings = ResolveMappingsValues(mappings, names, values, scene, [], obj.hints);
        end
        
        function mappings = resolveResources(obj, mappings)
            % no-op, handled in applyVariablesToMappings
        end
        
        function scene = remodelBeforeCondition(obj, scene, mappings, varNames, varValues, conditionNumber)
            scene = obj.remodelCollada(scene, obj.hints, 'BeforeCondition', ...
                mappings, varNames, varValues, conditionNumber);
        end
        
        function scene = applyBasicMappings(obj, scene, mappings, groupName)
            % apply Collada mappings to the scene
            if ~isempty(mappings)
                
                blockNums = [mappings.blockNumber];
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
                                [colladaDoc, colladaIDMap] = ReadSceneDOM(scene);
                                ApplySceneDOMPaths(colladaIDMap, blockMappings);
                                WriteSceneDOM(scene, colladaDoc);
                        end
                    end
                end
            end
        end
        
        function scene = remodelAfterCondition(obj, scene, mappings, varNames, varValues, conditionNumber)
            scene = obj.remodelCollada(scene, obj.hints, 'AfterCondition', ...
                mappings, varNames, varValues, conditionNumber);
        end
    end
    
    methods (Access = private)
        %% Locate a remodeler API funciton and call it.
        function colladaCopy = remodelCollada(obj, colladaFile, functionName, varargin)
            
            if isempty(colladaFile) || isempty(obj.hints.remodeler)
                colladaCopy = colladaFile;
                return;
            end
            
            remodelerFunction = GetRemodelerAPIFunction(functionName, obj.hints);
            if isempty(remodelerFunction)
                return;
            end
            
            % read original Collada document into memory
            [scenePath, sceneBase, sceneExt] = fileparts(colladaFile);
            if isempty(scenePath) && 2 == exist(colladaFile, 'file')
                info = ResolveFilePath(colladaFile, GetWorkingFolder('', false, obj.hints));
                colladaFile = info.absolutePath;
            end
            colladaDoc = ReadSceneDOM(colladaFile);
            
            % apply the remodeler function
            colladaDoc = feval(remodelerFunction, colladaDoc, varargin{:}, obj.hints);
            
            % write modified document to new file
            tempFolder = fullfile(GetWorkingFolder('temp', true, obj.hints));
            colladaCopy = fullfile(tempFolder, [sceneBase '-' functionName sceneExt]);
            WriteSceneDOM(colladaCopy, colladaDoc);
        end
    end
end
