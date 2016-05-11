classdef RtbVersion3MitsubaConverter < handle
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
            defaultMappings{mm}.broadType = 'integrator';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.specificType = 'direct';
            defaultMappings{mm}.operation = 'create';
            defaultMappings{mm}.destination = 'Mitsuba';
            defaultMappings{mm}.properties(1).name = 'shadingSamples';
            defaultMappings{mm}.properties(1).valueType = 'integer';
            defaultMappings{mm}.properties(1).value = 32;
            
            mm = mm + 1;
            defaultMappings{mm}.name = 'sampler';
            defaultMappings{mm}.broadType = 'sampler';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.specificType = 'ldsampler';
            defaultMappings{mm}.operation = 'update';
            defaultMappings{mm}.destination = 'Mitsuba';
            defaultMappings{mm}.properties(1).name = 'sampleCount';
            defaultMappings{mm}.properties(1).valueType = 'integer';
            defaultMappings{mm}.properties(1).value = 8;
            
            mm = mm + 1;
            defaultMappings{mm}.name = 'rfilter';
            defaultMappings{mm}.broadType = 'rfilter';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.specificType = 'gaussian';
            defaultMappings{mm}.operation = 'update';
            defaultMappings{mm}.destination = 'Mitsuba';
            defaultMappings{mm}.properties(1).name = 'stddev';
            defaultMappings{mm}.properties(1).valueType = 'float';
            defaultMappings{mm}.properties(1).value = 0.5;
            
            mm = mm + 1;
            defaultMappings{mm}.name = 'film';
            defaultMappings{mm}.broadType = 'film';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.specificType = 'hdrfilm';
            defaultMappings{mm}.operation = 'update';
            defaultMappings{mm}.destination = 'Mitsuba';
            defaultMappings{mm}.properties(1).name = 'width';
            defaultMappings{mm}.properties(1).valueType = 'integer';
            defaultMappings{mm}.properties(1).value = imageWidth;
            defaultMappings{mm}.properties(2).name = 'height';
            defaultMappings{mm}.properties(2).valueType = 'integer';
            defaultMappings{mm}.properties(2).value = imageHeight;
            defaultMappings{mm}.properties(3).name = 'banner';
            defaultMappings{mm}.properties(3).valueType = 'boolean';
            defaultMappings{mm}.properties(3).value = 'false';
            defaultMappings{mm}.properties(4).name = 'componentFormat';
            defaultMappings{mm}.properties(4).valueType = 'string';
            defaultMappings{mm}.properties(4).value = 'float16';
            defaultMappings{mm}.properties(5).name = 'fileFormat';
            defaultMappings{mm}.properties(5).valueType = 'string';
            defaultMappings{mm}.properties(5).value = 'openexr';
            defaultMappings{mm}.properties(6).name = 'pixelFormat';
            defaultMappings{mm}.properties(6).valueType = 'string';
            defaultMappings{mm}.properties(6).value = 'spectrum';
            
            mm = mm + 1;
            defaultMappings{mm}.name = '';
            defaultMappings{mm}.broadType = 'sensor';
            defaultMappings{mm}.index = [];
            defaultMappings{mm}.operation = 'update';
            defaultMappings{mm}.destination = 'Mitsuba';
            defaultMappings{mm}.properties(1).name = 'nearClip';
            defaultMappings{mm}.properties(1).valueType = 'float';
            defaultMappings{mm}.properties(1).value = 0.1;
            defaultMappings{mm}.properties(2).name = 'farClip';
            defaultMappings{mm}.properties(2).valueType = 'float';
            defaultMappings{mm}.properties(2).value = 100;
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
