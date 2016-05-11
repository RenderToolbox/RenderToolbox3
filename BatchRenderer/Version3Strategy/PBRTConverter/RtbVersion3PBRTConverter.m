classdef RtbVersion3PBRTConverter < handle
    %% Implementation for how to make scene files with the RendererPluginAPI.
    %
    % This class is a bridge between the "old" way of finding renderers
    % using functions that have conventional names, and the "new" way of
    % subclassing an abstract renderer supertype.
    %
        
    methods
        
        function defaultMappings = loadDefaultMappings(obj, varargin)
            parser = inputParser();
            parser.KeepUnmatched = true;
            parser.addParameter('imageWidth', 320, @isnumeric);
            parser.addParameter('imageHeight', 240, @isnumeric);
            parser.parse(varargin{:});
            imageWidth = parser.Results.imageWidth;
            imageHeight = parser.Results.imageHeight;
            
            mm = 1;
            defaultMappings{mm}.name = 'integrator';
            defaultMappings{mm}.broadType = 'SurfaceIntegrator';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.specificType = 'directlighting';
            defaultMappings{mm}.operation = 'create';
            defaultMappings{mm}.destination = 'PBRT';
            
            mm = mm + 1;
            defaultMappings{mm}.name = 'sampler';
            defaultMappings{mm}.broadType = 'Sampler';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.specificType = 'lowdiscrepancy';
            defaultMappings{mm}.operation = 'create';
            defaultMappings{mm}.destination = 'PBRT';
            defaultMappings{mm}.properties(1).name = 'pixelsamples';
            defaultMappings{mm}.properties(1).valueType = 'integer';
            defaultMappings{mm}.properties(1).value = 8;
            
            mm = mm + 1;
            defaultMappings{mm}.name = 'filter';
            defaultMappings{mm}.broadType = 'PixelFilter';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.specificType = 'gaussian';
            defaultMappings{mm}.operation = 'create';
            defaultMappings{mm}.destination = 'PBRT';
            defaultMappings{mm}.properties(1).name = 'alpha';
            defaultMappings{mm}.properties(1).valueType = 'float';
            defaultMappings{mm}.properties(1).value = 2;
            defaultMappings{mm}.properties(2).name = 'xwidth';
            defaultMappings{mm}.properties(2).valueType = 'float';
            defaultMappings{mm}.properties(2).value = 2;
            defaultMappings{mm}.properties(3).name = 'ywidth';
            defaultMappings{mm}.properties(3).valueType = 'float';
            defaultMappings{mm}.properties(3).value = 2;
            
            mm = mm + 1;
            defaultMappings{mm}.name = 'film';
            defaultMappings{mm}.broadType = 'Film';
            defaultMappings{mm}.specificType = 'image';
            defaultMappings{mm}.operation = 'create';
            defaultMappings{mm}.destination = 'PBRT';
            defaultMappings{mm}.properties(1).name = 'xresolution';
            defaultMappings{mm}.properties(1).valueType = 'integer';
            defaultMappings{mm}.properties(1).value = imageWidth;
            defaultMappings{mm}.properties(2).name = 'yresolution';
            defaultMappings{mm}.properties(2).valueType = 'integer';
            defaultMappings{mm}.properties(2).value = imageHeight;
        end
        
        function nativeScene = startConversion(obj, parentScene, mappings, names, conditionValues, conditionNumber)
            nativeScene = [];
        end
        
        function nativeScene = applyMappings(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber)
            nativeScene = [];
        end
        
        function nativeScene = finishConversion(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber)
            nativeScene = [];
        end
    end
end
