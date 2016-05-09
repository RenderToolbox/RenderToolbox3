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
        remodelBeforeAllFunction = [];
        remodelBeforeConditionFunction = [];
        remodelAfterConditionFunction = [];
    end
    
    methods
        function obj = RtbVersion3Strategy(hints, varargin)
            obj.hints = hints;
            obj.importArgs = cat(2, obj.importArgs, varargin);
            obj.converter = RtbVersion3Strategy.chooseConverter(hints);
            obj.renderer = RtbVersion3Strategy.chooseRenderer(hints);
        end
    end
    
    methods (Static, Access = private)
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
        end
        
        function mappings = loadMappings(obj, mappingsFile)
        end
        
        function [scene, mappings] = applyVariablesToMappings(obj, scene, mappings, names, conditionValues, conditionNumber)
        end
        
        function [scene, mappings] = resolveResources(obj, scene, mappings)
        end
        
        function [scene, mappings] = remodelBeforeCondition(obj, scene, mappings, names, conditionValues, conditionNumber)
            if isempty(obj.remodelBeforeConditionFunction)
                return;
            end
            [scene, mappings] = feval(obj.remodelBeforeConditionFunction, scene, mappings, names, conditionValues, conditionNumber);
        end
        
        function [scene, mappings] = applyBasicMappings(obj, scene, mappings, names, conditionValues, conditionNumber)
        end
        
        function [scene, mappings] = remodelAfterCondition(obj, scene, mappings, names, conditionValues, conditionNumber)
            if isempty(obj.remodelAfterConditionFunction)
                return;
            end
            [scene, mappings] = feval(obj.remodelAfterConditionFunction, scene, mappings, names, conditionValues, conditionNumber);
        end
    end
end
