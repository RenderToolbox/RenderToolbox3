classdef RtbVersion3SampleRendererConverter < handle
    %% Implementation for how to make scene files with the RendererPluginAPI.
    %
    % This class is a bridge between the "old" way of finding renderers
    % using functions that have conventional names, and the "new" way of
    % subclassing an abstract renderer supertype.
    %
    
    methods
        
        function obj = RtbVersion3SampleRendererConverter(hints)
        end
        
        function defaultMappings = loadDefaultMappings(obj, varargin)
            defaultMappings = {};
        end
        
        function nativeScene = startImport(obj, parentScene, mappings, names, conditionValues, conditionNumber)
            nativeScene = [];
        end
        
        function nativeScene = applyMappings(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber)
            nativeScene = [];
        end
        
        function nativeScene = finishImport(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber)
            nativeScene = [];
        end
    end
end
