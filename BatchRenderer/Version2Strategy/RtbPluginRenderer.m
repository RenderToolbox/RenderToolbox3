classdef RtbPluginRenderer < RtbRenderer
    %% Implementation for how to render with the RendererPluginAPI.
    %
    % This class is a bridge between the "old" way of finding renderers
    % using functions that have conventional names, and the "new" way of
    % subclassing an abstract renderer supertype.
    %
    
    properties
        hints = [];
    end
    
    methods
        function obj = RtbPluginRenderer(hints)
            obj.hints = hints;
        end
        
        function info = versionInfo(obj)
            versionInfoFunction = GetRendererAPIFunction('VersionInfo', obj.hints);
            if isempty(versionInfoFunction)
                info = [];
                return;
            end
            info = feval(versionInfoFunction);
        end
        
        function [status, result, image, sampling] = render(obj, nativeScene)
            renderFunction = GetRendererAPIFunction('Render', obj.hints);
            if isempty(renderFunction)
                status = [];
                result = [];
                image = [];
                sampling = [];
                return;
            end
            [status, result, image, sampling] = feval(renderFunction, nativeScene, obj.hints);
        end
        
        function [radianceImage, scaleFactor] = toRadiance(obj, image, sampling, nativeScene)
            dataToRadianceFunction = ...
                GetRendererAPIFunction('DataToRadiance', obj.hints);
            if isempty(dataToRadianceFunction)
                radianceImage = [];
                scaleFactor = [];
                return;
            end
            [radianceImage, scaleFactor] = feval(dataToRadianceFunction, image, nativeScene, obj.hints);
        end
    end
end
