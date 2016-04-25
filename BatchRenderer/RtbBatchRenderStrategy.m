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
    
    properties
        % which RtbRenderer to use
        renderer;
        
        % which RtbRemodeler to use
        remodeler;
    end
    
    methods (Abstract)
        scene = loadScene(obj, sceneFile);
        
        [names, values] = loadConditions(obj, conditionsFile);
        
        mappings = loadMappings(obj, mappingsFile);
        
        mappings = applyVariablesToMappings(obj, mappings, names, values);
        
        mappings = resolveResources(obj, mappings);
        
        scene = applyMappings(obj, scene, mappings);
        
    end
end
