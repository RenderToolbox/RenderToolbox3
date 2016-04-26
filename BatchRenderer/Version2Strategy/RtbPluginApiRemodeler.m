classdef RtbPluginApiRemodeler < RtbRemodeler
    %% Delegate to old RemodelerAPIFunction functions.
    %
    % This class is a bridge between the "old" way of remodeling scenes
    % using specially-named "plugin" functions, and the "new" way of using
    % OOP and inheritance to encapsulate the same functionality.
    %

    properties
        hints = [];
    end
    
    methods
        function obj = RtbPluginApiRemodeler(hints)
            obj.hints = hints;
        end
        
        % Modify the scene once, before all other processing.
        function scene = beforeAll(obj, scene)
            scene = remodelCollada(scene, obj.hints, functionName);
        end
        
        % Modify the scene once per condition, before mappings are applied.
        function scene = beforeCondition(obj, scene, mappings, varNames, varValues, conditionNumber)
            scene = remodelCollada(scene, obj.hints, functionName, ...
                mappings, varNames, varValues, conditionNumber);
        end
        
        % Modify the scene once per condition, after mappings are applied.
        function scene = afterCondition(obj, scene, mappings, varNames, varValues, conditionNumber)
            scene = remodelCollada(scene, obj.hints, functionName, ...
                mappings, varNames, varValues, conditionNumber);
        end
    end
    
    methods (Access = private)
        %% Locate a remodeler API funciton and call it.
        function colladaCopy = remodelCollada(obj, colladaFile, functionName, varargin)
            
            if isempty(colladaFile) || isempty(obj.hints.remodeler)
                colladaCopy = colladaFile;
                return;
            end
            
            remodelerFunction = GetRemodelerAPIFunction(functionName, obj.hints);
            if isempty(remodelerFunction)
                return;
            end
            
            % read original Collada document into memory
            [scenePath, sceneBase, sceneExt] = fileparts(colladaFile);
            if isempty(scenePath) && 2 == exist(colladaFile, 'file')
                info = ResolveFilePath(colladaFile, GetWorkingFolder('', false, obj.hints));
                colladaFile = info.absolutePath;
            end
            colladaDoc = ReadSceneDOM(colladaFile);
            
            % apply the remodeler function
            colladaDoc = feval(remodelerFunction, colladaDoc, varargin{:}, obj.hints);
            
            % write modified document to new file
            tempFolder = fullfile(GetWorkingFolder('temp', true, obj.hints));
            colladaCopy = fullfile(tempFolder, [sceneBase '-' functionName sceneExt]);
            WriteSceneDOM(colladaCopy, colladaDoc);
        end
    end
end
