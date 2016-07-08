classdef RtbPBRTRenderer < RtbRenderer
    %% Implementation for rendering with Mitsuba.
    
    properties
        % RenderToolbox3 options struct, see rtbDefaultHints()
        hints = [];
        
        % pbrt info struct
        pbrt;
        
        % where to write output files
        outputFolder;
        
        % where to put scenes before rendering
        workingFolder;
    end
    
    methods
        function obj = RtbPBRTRenderer(hints)
            obj.hints = rtbDefaultHints(hints);
            obj.pbrt = getpref('PBRT');
            obj.outputFolder = rtbWorkingFolder( ...
                'folderName', 'renderings', ...
                'rendererSpecific', true, ...
                'hints', obj.hints);
            obj.workingFolder = rtbWorkingFolder('hints', obj.hints);
        end
        
        function info = versionInfo(obj)
            try
                info = dir(obj.pbrt.executable);
            catch err
                info = err;
            end
        end
        
        function [status, result, image, sampling, imageName] = render(obj, nativeScene)
            % look carefully for the file
            [scenePath, sceneBase, sceneExt] = fileparts(nativeScene);
            if isempty(scenePath)
                fileInfo = rtbResolveFilePath(nativeScene, obj.workingFolder);
                nativeScene = fileInfo.absolutePath;
            end
            
            % choose output file
            [~, imageName] = fileparts(nativeScene);
            outFile = fullfile(obj.outputFolder, [imageName '.dat']);
            
            % build a pbrt command
            renderCommand = sprintf('%s --outfile %s %s', ...
                obj.pbrt.executable, ...
                outFile, ...
                nativeScene);
            fprintf('%s\n', renderCommand);
            
            % invoke pbrt
            [status, result] = rtbRunCommand(renderCommand, obj.hints);
            if status ~= 0
                error('RtbPbrtRenderer:pbrtError', result);
            end
            
            sampling = obj.pbrt.S;
            image = rtbReadDAT(outFile, 'maxPlanes', sampling(3));
        end
        
        function [radianceImage, scaleFactor] = toRadiance(obj, image, sampling, nativeScene)
            scaleFactor = obj.pbrt.radiometricScaleFactor;
            radianceImage = image .* scaleFactor;
        end
    end
end
