classdef RtbMappingsFileTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testRead(testCase)
            mappingsFile = fullfile(RenderToolboxRoot(), 'Test', 'Fixture', 'DragonColorCheckerMappings.txt');
            mappings = ParseMappings(mappingsFile);
            testCase.assertInstanceOf(mappings, 'struct');
            testCase.assertNumElements(mappings, 11);
        end
        
        function testRoundTrip(testCase)
            colladaFile = fullfile(RenderToolboxRoot(), 'Test', 'Fixture', 'CoordinatesTest.dae');
            mappingsFile = fullfile(tempdir(), 'RtbMappingsFileTests', 'testMappings.txt');
            lightSpectrum = '300:1 800:1';
            WriteDefaultMappingsFile(colladaFile, ...
                'mappingsFile', mappingsFile, ...
                'lightSpectra', {lightSpectrum});
            
            mappings = ParseMappings(mappingsFile);
            testCase.assertInstanceOf(mappings, 'struct');
            testCase.assertNumElements(mappings, 23);
            testCase.assertEqual(mappings(end).right.value, lightSpectrum);
        end
    end
end
