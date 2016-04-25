classdef RtbRenderer < handle
    %% Abstract interface for how to make and render scenes.
    % Defines the outline for how to make scene files for a given renderer,
    % and how to invoke the renderer on the scene.
    %
    % This is an alternative to the "old" way of doing things based on
    % functions that have specific names.  See GetRendererAPIFunction().
    
    methods (Abstract)
        % Convert the parent scene to renderer-native format.
        nativeScene = import(obj, parentScene, imageName, hints);
        
        % Apply mappings to adjust the native scene.
        nativeScene = applyMappings(obj, nativeScene, mappings, hints);
        
        % Invoke the renderer with the native scene.
        [status, result, image, sampling] = render(obj, nativeScene, hints);
        
        % Convert a rendering to radiance units.
        [radianceImage, scaleFactor] = toRadiance(obj, image, sampling, nativeScene, hints);
        
        % Get renderer version info
        info = versionInfo(object);
    end
end
