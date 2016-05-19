classdef RtbMitsubaRenderer < RtbRenderer
    %% Implementation for rendering with Mitsuba.
    
    properties
        % RenderToolbox3 options struct, see rtbDefaultHints()
        hints = [];
        
        % Mitsuba info struct.
        mitsuba;
        
        % Where to write output files.
        outputFolder;
    end
    
    methods
        function obj = RtbMitsubaRenderer(hints)
            obj.hints = hints;
            obj.mitsuba = getpref('Mitsuba');
            obj.outputFolder = rtbWorkingFolder('renderings', true, hints);
        end
        
        function info = versionInfo(obj)
            try
                executable = fullfile(obj.mitsuba.app, obj.mitsuba.executable);
                info = dir(executable);
            catch err
                info = err;
            end
        end
        
        function [status, result, image, sampling, imageName] = render(obj, nativeScene)
            renderFunction = GetRendererAPIFunction('Render', obj.hints);
            if isempty(renderFunction)
                status = [];
                result = [];
                image = [];
                sampling = [];
                imageName = '';
                return;
            end
            [status, result, image, sampling] = feval(renderFunction, nativeScene.scene, obj.hints);
            imageName = nativeScene.scene.imageName;
        end
        
        function [radianceImage, scaleFactor] = toRadiance(obj, image, sampling, nativeScene)
            dataToRadianceFunction = ...
                GetRendererAPIFunction('DataToRadiance', obj.hints);
            if isempty(dataToRadianceFunction)
                radianceImage = [];
                scaleFactor = [];
                return;
            end
            [radianceImage, scaleFactor] = feval(dataToRadianceFunction, image, nativeScene.scene, obj.hints);
        end
    end
end
