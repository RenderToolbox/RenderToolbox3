classdef RtbMakeSceneFilesTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testMakeNoSceneFiles(testCase)
            colladaFile = '';
            hints.workingFolder = fullfile(tempdir(), 'RtbMakeSceneFilesTests');
            scenes = MakeSceneFiles(colladaFile, 'hints', hints);
            testCase.assertNumElements(scenes, 1);
            testCase.assertEmpty(scenes{1});
        end
        
        function testMakeSceneFilesSampleRemodelerSampleRenderer(testCase)
            hints.workingFolder = fullfile(tempdir(), 'RtbBatchRenderTests');
            hints.renderer = 'SampleRenderer';
            hints.remodeler = 'SampleRemodeler';
            hints = GetDefaultHints(hints);
            
            colladaFile = fullfile(RenderToolboxRoot(), 'Test', 'Fixture', 'CoordinatesTest.dae');
            hints.workingFolder = fullfile(tempdir(), 'RtbMakeSceneFilesTests');
            scenes = MakeSceneFiles(colladaFile, 'hints', hints);
            testCase.assertNumElements(scenes, 1);
        end
        
    end
end
