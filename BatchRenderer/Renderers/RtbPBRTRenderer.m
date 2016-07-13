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
            if 7 ~= exist(scenePath, 'dir')
                fileInfo = rtbResolveFilePath(nativeScene, obj.workingFolder);
                nativeScene = fileInfo.absolutePath;
            end
            
            % choose output file
            [~, imageName] = fileparts(nativeScene);
            outFile = fullfile(obj.outputFolder, [imageName '.dat']);
            
            % run in docker or locally with configured lib path
            %   docker must be installed
            %   user must have docker-level privileges (root or docker group)
            [dockerStatus, ~] = system('docker ps');
            if ~dockerStatus
                commandPrefix = sprintf('docker run -ti --rm -v "%s":"%s" -v "%s":"%s" %s pbrt', ...
                    obj.workingFolder, obj.workingFolder, ...
                    rtbRoot(), rtbRoot(), ...
                    obj.pbrt.dockerImage);
            else
                commandPrefix = sprintf('%s', obj.pbrt.executable);
            end
            
            % build a pbrt command
            renderCommand = sprintf('%s --outfile %s %s', ...
                commandPrefix, ...
                outFile, ...
                nativeScene);
            fprintf('%s\n', renderCommand);
            
            % invoke pbrt
            [status, result] = rtbRunCommand(renderCommand, 'hints', obj.hints);
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
