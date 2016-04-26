classdef RtbRenderer < handle
    %% Abstract interface for how to make and render scenes.
    % Defines the outline for how to make scenes for a given renderer,
    % and how to invoke the renderer on the scene.
    %
    % This is an alternative to the "old" way of doing things based on
    % functions that have specific names.  See GetRendererAPIFunction().
    
    methods (Abstract)
        % Convert the scene to native format, or return a placeholder.
        nativeScene = startImport(obj, parentScene, imageName);
        
        % Apply mappings to adjust the native scene in progress.
        nativeScene = applyMappings(obj, nativeScene, mappings);
        
        % Convert the scene to native format, if not done yet.
        nativeScene = finishImport(obj, parentScene, nativeScene, imageName);
        
        % Invoke the renderer with the native scene.
        [status, result, image, sampling] = render(obj, nativeScene);
        
        % Convert a rendering to radiance units.
        [radianceImage, scaleFactor] = toRadiance(obj, image, sampling, nativeScene);
        
        % Get renderer version info.
        info = versionInfo(obj);
    end
end
