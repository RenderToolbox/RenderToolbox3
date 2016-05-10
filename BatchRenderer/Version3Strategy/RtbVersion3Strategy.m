classdef RtbVersion3Strategy < RtbBatchRenderStrategy
    %% Implementation for how batch process with mexximp and JSON.
    %
    % This implements a batch rendering strategy for the Version 3
    % way of doing batch rendering, with mexximp and JSON mappings files.
    %
    % We choose a scene file converter and renderer based on the
    % hints.renderer passed to the constructor.
    %
    % TODO: we want a way to customize scene loading based on the input
    % format and various hacky things required for taming wild scenes.  We
    % would like to start with some sensible defaults.  We would like to
    % provide the user a way to override these on a per-scene basis.  Maybe
    % choose defaults here, and accept a varargin from MakeSceneFiles, in
    % addition to the hints.
    %
    % TODO: we want to let the user supply 0-3 remodeling functions.  Is
    % each of these yet another vararg from MakeSceneFiles?
    %
    
    properties
        hints = [];
        importArgs = {'ignoreRootTransform', false, 'flipUVs', true};
        mappingsArgs = {};
        remodelBeforeAllFunction = [];
        remodelBeforeConditionFunction = [];
        remodelAfterConditionFunction = [];
    end
    
    methods
        function obj = RtbVersion3Strategy(hints, varargin)
            obj.hints = hints;
            obj.importArgs = cat(2, obj.importArgs, varargin);
            obj.mappingsArgs = cat(2, {hints}, varargin);
            obj.converter = RtbVersion3Strategy.chooseConverter(hints);
            obj.renderer = RtbVersion3Strategy.chooseRenderer(hints);
        end
    end
    
    methods (Static)
        function converter = chooseConverter(hints)
            rendererName = hints.renderer;
            constructorName = ['RtbVersion3' rendererName 'Converter'];
            if 2 == exist(constructorName, 'file')
                converter = feval(constructorName);
            else
                converter = [];
            end
        end
        
        function renderer = chooseRenderer(hints)
            rendererName = hints.renderer;
            constructorName = ['Rtb' rendererName 'Renderer'];
            if 2 == exist(constructorName, 'file')
                renderer = feval(constructorName);
            else
                renderer = [];
            end
        end
        
        function defaultMappings = loadDefaultMappings(varargin)
            parser = inputParser();
            parser.KeepUnmatched = true;
            parser.addParameter('fov', pi()/3, @isnumeric);
            parser.addParameter('imageWidth', 320, @isnumeric);
            parser.addParameter('imageHeight', 240, @isnumeric);
            parser.addParameter('lookAtDirection', [0 0 -1]', @isnumeric);
            parser.addParameter('upDirection', [0 1 0]', @isnumeric);
            parser.parse(varargin{:});
            fov = parser.Results.fov;
            imageWidth = parser.Results.imageWidth;
            imageHeight = parser.Results.imageHeight;
            lookAtDirection = parser.Results.lookAtDirection;
            upDirection = parser.Results.upDirection;
            
            mm = 1;
            defaultMappings{mm}.name = 'Camera';
            defaultMappings{mm}.broadType = 'nodes';
            defaultMappings{mm}.operation = 'update';
            defaultMappings{mm}.destination = 'mexximp';
            defaultMappings{mm}.properties(1).name = 'transformation';
            defaultMappings{mm}.properties(1).valueType = 'matrix';
            defaultMappings{mm}.properties(1).value = mexximpScale([-1 1 1]);
            defaultMappings{mm}.properties(1).operation = 'value * oldValue';
            
            mm = mm + 1;
            defaultMappings{mm}.name = 'Camera';
            defaultMappings{mm}.broadType = 'cameras';
            defaultMappings{mm}.operation = 'update';
            defaultMappings{mm}.destination = 'mexximp';
            defaultMappings{mm}.properties(1).name = 'lookAtDirection';
            defaultMappings{mm}.properties(1).valueType = 'lookAt';
            defaultMappings{mm}.properties(1).value = lookAtDirection;
            defaultMappings{mm}.properties(2).name = 'upDirection';
            defaultMappings{mm}.properties(2).valueType = 'lookAt';
            defaultMappings{mm}.properties(2).value = upDirection;
            defaultMappings{mm}.properties(3).name = 'horizontalFov';
            defaultMappings{mm}.properties(3).valueType = 'float';
            defaultMappings{mm}.properties(3).value = fov;
            defaultMappings{mm}.properties(4).name = 'aspectRatio';
            defaultMappings{mm}.properties(4).valueType = 'float';
            defaultMappings{mm}.properties(4).value = imageWidth / imageHeight;
        end
    end
    
    methods
        function scene = loadScene(obj, sceneFile)
            scene = mexximpCleanImport(sceneFile, obj.importArgs{:});
        end
        
        function scene = remodelBeforeAll(obj, scene)
            if isempty(obj.remodelBeforeAllFunction)
                return;
            end
            scene = feval(obj.remodelBeforeAllFunction, scene);
        end
        
        function [names, allValues] = loadConditions(obj, conditionsFile)
            [names, allValues] = ParseConditions(conditionsFile);
        end
        
        function mappings = loadMappings(obj, mappingsFile)
            defaultBasicMappings = RtbVersion3Strategy.loadDefaultMappings(obj.mappingsArgs{:});
            defaultConverterMappings = obj.converter.loadDefaultMappings(obj.mappingsArgs{:});
            sceneMappings = rtbLoadJsonMappings(mappingsFile);
            rawMappings = cat(2, defaultBasicMappings, defaultConverterMappings, sceneMappings);
            mappings = rtbValidateMappings(rawMappings);
        end
        
        function [scene, mappings] = applyVariablesToMappings(obj, scene, mappings, names, conditionValues, conditionNumber)
            mappings = rtbVisitStructFields(mappings, @rtbSubstituteStringVariables, ...
                names, conditionValues);
        end
        
        function [scene, mappings] = resolveResources(obj, scene, mappings)
            % locate files and fix up names
            resourceFolder = GetWorkingFolder('resources', false, obj.hints);
            mappings = rtbVisitStructFields(mappings, @rtbLocateResource, ...
                'resourceFolder', resourceFolder, ...
                'writeFullPaths', false, ...
                'relativePath', 'resources', ...
                'toReplace', ':-', ...
                'copyOnReplace', true);
            scene = rtbVisitStructFields(scene, @rtbLocateResource, ...
                'resourceFolder', resourceFolder, ...
                'writeFullPaths', false, ...
                'relativePath', 'resources', ...
                'toReplace', ':-', ...
                'copyOnReplace', true);
            
            mappings = rtbVisitStructFields(mappings, @rtbRecodeImage, ...
                'toReplace', {'gif'}, ...
                'targetFormat', 'png');
            scene = rtbVisitStructFields(scene, @rtbRecodeImage, ...
                'toReplace', {'gif'}, ...
                'targetFormat', 'png');
        end
        
        function [scene, mappings] = remodelBeforeCondition(obj, scene, mappings, names, conditionValues, conditionNumber)
            if isempty(obj.remodelBeforeConditionFunction)
                return;
            end
            [scene, mappings] = feval(obj.remodelBeforeConditionFunction, scene, mappings, names, conditionValues, conditionNumber);
        end
        
        function [scene, mappings] = applyBasicMappings(obj, scene, mappings, names, conditionValues, conditionNumber)
            scene = applyMexximpMappings(scene, mappings);
        end
        
        function [scene, mappings] = remodelAfterCondition(obj, scene, mappings, names, conditionValues, conditionNumber)
            if isempty(obj.remodelAfterConditionFunction)
                return;
            end
            [scene, mappings] = feval(obj.remodelAfterConditionFunction, scene, mappings, names, conditionValues, conditionNumber);
        end
    end
end
