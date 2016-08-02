classdef RtbMitsubaRenderer < RtbRenderer
    %% Implementation for rendering with Mitsuba.
    
    properties
        % RenderToolbox3 options struct, see rtbDefaultHints()
        hints = [];
        
        % Mitsuba info struct
        mitsuba;
        
        % where to write output files
        outputFolder;
    end
    
    methods
        function obj = RtbMitsubaRenderer(hints)
            obj.hints = rtbDefaultHints(hints);
            obj.mitsuba = getpref('Mitsuba');
            obj.outputFolder = rtbWorkingFolder( ...
                'folderName', 'renderings', ...
                'rendererSpecific', true, ...
                'hints', obj.hints);
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
            % look carefully for the file
            scenePath = fileparts(nativeScene);
            if 7 ~= exist(scenePath, 'dir')
                workingFolder = rtbWorkingFolder('hints', obj.hints);
                fileInfo = rtbResolveFilePath(nativeScene, workingFolder);
                nativeScene = fileInfo.absolutePath;
            end
            
            % choose output file
            [~, imageName] = fileparts(nativeScene);
            outFile = fullfile(obj.outputFolder, [imageName '.exr']);
            
            % run in docker or locally with configured lib path
            %   docker must be installed
            %   user must have docker-level privileges (root or docker group)
            [dockerStatus, ~] = system('docker ps');
            if ~dockerStatus
                [~, uid] = system('id -u `whoami`');
                commandPrefix = sprintf('docker run -ti --rm -u %s:%s -v "%s":"%s" -v "%s":"%s" %s mitsuba', ...
                    strtrim(uid), strtrim(uid), ...
                    workingFolder, workingFolder, ...
                    rtbRoot(), rtbRoot(), ...
                    obj.mitsuba.dockerImage);
            else
                executable = fullfile(obj.mitsuba.app, obj.mitsuba.executable);
                commandPrefix = sprintf('%s="%s" "%s"', ...
                    obj.mitsuba.libraryPathName, ...
                    obj.mitsuba.libraryPath, ...
                    executable);
            end
            
            % build a mitsuba command
            renderCommand = sprintf('%s -o "%s" "%s"', ...
                commandPrefix, ...
                outFile, ...
                nativeScene);
            
            % invoke mitsuba
            fprintf('%s\n', renderCommand);
            [status, result] = rtbRunCommand(renderCommand, 'hints', obj.hints);
            if status ~= 0
                error('RtbMitsubaRenderer:mitsubaError', result);
            end
            
            % read the rendering into memory
            [image, ~, sampling] = rtbReadMultispectralEXR(outFile);
        end
        
        function [radianceImage, scaleFactor] = toRadiance(obj, image, sampling, nativeScene)
            scaleFactor = obj.mitsuba.radiometricScaleFactor;
            radianceImage = image .* scaleFactor;
        end
    end
end
