classdef RtbBatchRenderTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testRenderNoScenes(testCase)
            scenes = {};
            hints.workingFolder = fullfile(tempdir(), 'RtbBatchRenderTests');
            outputFiles = BatchRender(scenes, 'hints', hints);
            testCase.assertEmpty(outputFiles);
        end
        
        function testRenderSampleRenderer(testCase)
            hints.workingFolder = fullfile(tempdir(), 'RtbBatchRenderTests');
            hints.renderer = 'SampleRenderer';
            hints = GetDefaultHints(hints);
            
            scene = RTB_ImportCollada_SampleRenderer('', '', 'sample', hints);
            scenes = {scene, scene};
            outputFiles = BatchRender(scenes, 'hints', hints);
            testCase.assertNumElements(outputFiles, numel(scenes));
        end
        
    end
end
