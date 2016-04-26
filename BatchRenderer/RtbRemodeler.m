classdef RtbRemodeler < handle
    %% Abstract interface for how to remodel scenes.
    % Defines the outline for how to remodel a scene at different times
    % during batch rendering.  We can implement various remodelers for that
    % do different things based on this outline.
    %
    % This is an alternative to the "old" way of doing things based on
    % functions that have specific names.  See GetRemodelerAPIFunction().
    %
    % Each method is optional for subclasses to override.  So the required
    % methods are no-ops instead of abstract.
    
    methods
        % Modify the scene once, before all other processing.
        function scene = beforeAll(obj, scene)
        end
        
        % Modify the scene once per condition, before mappings are applied.
        function scene = beforeCondition(obj, scene, mappings, varNames, varValues, conditionNumber)
        end
        
        % Modify the scene once per condition, after mappings are applied.
        function scene = afterCondition(obj, scene, mappings, varNames, varValues, conditionNumber)
        end
    end
end
