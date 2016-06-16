classdef RtbVersion3PBRTConverter < handle
    %% Implementation for rendering converting mexximp to Pbrt.
    %
    
    properties
        % RenderToolbox3 options struct, see rtbDefaultHints()
        hints;
        
        % default material for mexximp conversion
        material;
        
        % material parameter to receive diffuse reflectance data
        diffuseParameter;
        
        % material parameter to receive specular reflectance data
        specularParameter;
        
        % where to write output files, like scene or geometry
        outputFolder;
        
        % subfolder for geometry within the workingFolder
        meshSubfolder;
        
        % whether to overwrite/update existing mesh files
        rewriteMeshData;
    end
    
    methods (Static)
        function material = defaultMaterial()
            material = MPbrtElement.makeNamedMaterial('', 'anisoward');
            material.setParameter('Kd', 'spectrum', '300:0 800:0');
            material.setParameter('Ks', 'rgb', [0.5 0.5 0.5]);
            material.setParameter('alphaU', 'float', 0.15);
            material.setParameter('alphaV', 'float', 0.15);
        end
    end
    
    methods
        
        function obj = RtbVersion3PBRTConverter(hints)
            obj.hints = rtbDefaultHints(hints);
            obj.material = RtbVersion3PBRTConverter.defaultMaterial();
            obj.diffuseParameter = 'Kd';
            obj.specularParameter = '';
            obj.outputFolder = rtbWorkingFolder('', false, obj.hints);
            obj.meshSubfolder = 'scenes/PBRT/pbrt-geometry';
            obj.rewriteMeshData = true;
        end
        
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
            nativeScene = mPbrtImportMexximp(parentScene, ...
                'materialDefault', obj.material, ...
                'materialDiffuseParameter', obj.diffuseParameter, ...
                'materialSpecularParameter', obj.specularParameter, ...
                'workingFolder', obj.outputFolder, ...
                'meshSubfolder', obj.meshSubfolder, ...
                'rewriteMeshData', obj.rewriteMeshData);
        end
        
        function nativeScene = applyMappings(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber)
            groupName = rtbGetNamedValue(names, conditionValues, 'groupName', '');
            if isempty(groupName)
                groupMappings = mappings;
            else
                isInGroup = strcmp(groupName, {mappings.group});
                groupMappings = mappings(isInGroup);
            end
            nativeScene = rtbApplyMPbrtMappings(nativeScene, groupMappings);
            nativeScene = rtbApplyMPbrtGenericMappings(nativeScene, groupMappings);
        end
        
        % transition in-memory nativeScene to on-disk pbrtFile
        function pbrtFile = finishConversion(obj, parentScene, nativeScene, mappings, names, conditionValues, conditionNumber)
            imageName = rtbGetNamedValue(names, conditionValues, 'imageName', ...
                sprintf('scene-%03d', conditionNumber));
            pbrtFile = fullfile(obj.outputFolder, [imageName '.pbrt']);
            nativeScene.printToFile(pbrtFile);
        end
    end
end
