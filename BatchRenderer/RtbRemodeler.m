classdef RtbRemodeler < handle
    %% Abstract interface for how to remodel scenes.
    % Defines the outline for how to remodel a scene at different times
    % during batch rendering.  We can implement various remodelers for that
    % do different things based on this outline.
    %
    % This is an alternative to the "old" way of doing things based on
    % functions that have specific names.  See GetRemodelerAPIFunction().
    
    methods (Abstract)
        % Modify the scene once, before all other processing.
        scene = beforeAll(obj, scene, hints);
        
        % Modify the scene once per condition, before mappings are applied.
        scene = beforeCondition(obj, scene, hints);
        
        % Modify the scene once per condition, after mappings are applied.
        scene = afterCondition(obj, scene, hints);
    end
end
