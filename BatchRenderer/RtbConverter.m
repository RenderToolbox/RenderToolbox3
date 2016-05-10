classdef RtbConverter < handle
    %% Abstract interface for how to make scene files.
    % Defines the outline for how to convert a basic scene representation
    % into a renderer-native format.
    %
    
    methods (Abstract)
        % Build the default mappings for this renderer.
        defaultMappings = loadDefaultMappings(obj, varargin);
        
        % Convert the scene to native format, or return a placeholder.
        nativeScene = startImport(obj, parentScene, mappings, names, conditionValues, conditionNumber);
        
        % Apply mappings to adjust the native scene in progress.
        nativeScene = applyMappings(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber);
        
        % Convert the scene to native format, if not done yet.
        nativeScene = finishImport(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber);
    end
end
