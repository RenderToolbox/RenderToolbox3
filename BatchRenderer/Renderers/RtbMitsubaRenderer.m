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
            if isempty(scenePath)
                fileInfo = rtbResolveFilePath(nativeScene, rtbWorkingFolder('hints', hints));
                nativeScene = fileInfo.absolutePath;
            end
            
            % choose output file
            [~, imageName] = fileparts(nativeScene);
            outFile = fullfile(obj.outputFolder, [imageName '.exr']);
            
            % build a mitsuba command
            executable = fullfile(obj.mitsuba.app, obj.mitsuba.executable);
            renderCommand = sprintf('%s="%s" "%s" -o "%s" "%s"', ...
                obj.mitsuba.libraryPathName, ...
                obj.mitsuba.libraryPath, ...
                executable, ...
                outFile, ...
                nativeScene);
            fprintf('%s\n', renderCommand);
            
            % invoke mitsuba
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
