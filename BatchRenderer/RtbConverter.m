classdef RtbConverter < handle
    %% Abstract interface for how to make scene files.
    % Defines the outline for how to convert a basic scene representation
    % into a renderer-native format.
    %
    
    methods (Abstract)
        % Convert the scene to native format, or return a placeholder.
        nativeScene = startImport(obj, parentScene, imageName);
        
        % Apply mappings to adjust the native scene in progress.
        nativeScene = applyMappings(obj, nativeScene, mappings, groupName);
        
        % Convert the scene to native format, if not done yet.
        nativeScene = finishImport(obj, parentScene, nativeScene, imageName);        
    end
end
