classdef RtbBatchRenderStrategy < handle
    %% Abstract interface for how to do batch rendering.
    % We have at least two ways to do things with RenderToolbox3: the
    % original, deprecated way with Collada scenes and text mappings files,
    % and the new way with Assimp and JSON mappings files.  We
    % think the new way is better.  But we still want to be able to do
    % things the old way, at least for a while.
    %
    % So we define this idea of a batch render "strategy".  It's an outline
    % of what we need to get done when batch rendering.  We reimplement the
    % batch rendering functions to follow this outline.  Then we will
    % implement two or more concrete strategies: one for the old Collada
    % way of doing things, and one for the new Assimp and JSON.
    %
    % All of this deals with the basic scene representation.  When if comes
    % to the renderer, we delegate to an RtbConverter and an RtbRenderer.
    % The converter knows how to convert the basic scene representation to
    % a renderer-native format.  The renderer doesn't care about the basic
    % scene representation, and only deals with the renderer-native format.
    %
    
    properties
        % which RtbConverter to use
        converter;
        
        % which RtbRenderer to use
        renderer;
    end
    
    methods (Abstract)
        % load basic scene representation from file
        scene = loadScene(obj, sceneFile, imageName);
        
        % hook to alter the basic scene representation
        scene = remodelBeforeAll(obj, scene);
        
        % load variable names and values from file
        [names, values] = loadConditions(obj, conditionsFile);
        
        % load scene alteration instructions from file
        mappings = loadMappings(obj, mappingsFile);
        
        % modify mappings for the next condition
        mappings = applyVariablesToMappings(obj, scene, mappings, names, values);
        
        % modify mappings for locally available files
        mappings = resolveResources(obj, mappings);
        
        % hook to alter the basic scene representation
        scene = remodelBeforeCondition(obj, scene, mappings, varNames, varValues, conditionNumber);
        
        % alter the basich scene representation based on mappings
        scene = applyBasicMappings(obj, scene, mappings, groupName);
        
        % hook to alter the basic scene representation
        scene = remodelAfterCondition(obj, scene, mappings, varNames, varValues, conditionNumber);
    end
end
