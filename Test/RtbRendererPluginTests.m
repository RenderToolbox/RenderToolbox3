classdef RtbRendererPluginTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testNonexistentRenderer(testCase)
            hints = rtbDefaultHints();
            hints.renderer = 'notARenderer';
            try
                [remodelerFunction, functionPath] = GetRendererAPIFunction('ApplyMappings', hints);
            catch
                remodelerFunction = [];
                functionPath = '';
            end
            testCase.assertEmpty(remodelerFunction);
            testCase.assertEmpty(functionPath);
        end
        
        function testNonexistentFunction(testCase)
            hints = rtbDefaultHints();
            hints.remodeler = 'SampleRenderer';
            try
                [remodelerFunction, functionPath] = GetRemodelerAPIFunction('notAFunction', hints);
            catch
                remodelerFunction = [];
                functionPath = '';
            end
            testCase.assertEmpty(remodelerFunction);
            testCase.assertEmpty(functionPath);
        end
        
        function testSampleRenderer(testCase)
            hints = rtbDefaultHints();
            hints.remodeler = 'SampleRenderer';
            
            [remodelerFunction, functionPath] = GetRendererAPIFunction('ApplyMappings', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            feval(remodelerFunction, [], []);
            
            [remodelerFunction, functionPath] = GetRendererAPIFunction('ImportCollada', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            scene = feval(remodelerFunction, '', [], '', hints);
            
            [remodelerFunction, functionPath] = GetRendererAPIFunction('Render', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            [~, ~, multispectralImage] = feval(remodelerFunction, scene, hints);
            
            [remodelerFunction, functionPath] = GetRendererAPIFunction('DataToRadiance', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            feval(remodelerFunction, multispectralImage, scene, hints);
            
            [remodelerFunction, functionPath] = GetRendererAPIFunction('VersionInfo', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            feval(remodelerFunction);
        end
    end
end
