classdef RtbRemodelerPluginTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testNonexistentRemodeler(testCase)
            hints = GetDefaultHints();
            hints.remodeler = 'notARemodeler';
            try
                [remodelerFunction, functionPath] = GetRemodelerAPIFunction('BeforeAll', hints);
            catch
                remodelerFunction = [];
                functionPath = '';
            end
            testCase.assertEmpty(remodelerFunction);
            testCase.assertEmpty(functionPath);
        end
        
        function testNonexistentFunction(testCase)
            hints = GetDefaultHints();
            hints.remodeler = 'SampleRemodeler';
            try
                [remodelerFunction, functionPath] = GetRemodelerAPIFunction('notAFunction', hints);
            catch
                remodelerFunction = [];
                functionPath = '';
            end
            testCase.assertEmpty(remodelerFunction);
            testCase.assertEmpty(functionPath);
        end
        
        function testSampleRemodeler(testCase)
            hints = GetDefaultHints();
            hints.remodeler = 'SampleRemodeler';
            
            [remodelerFunction, functionPath] = GetRemodelerAPIFunction('BeforeAll', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            feval(remodelerFunction, [], hints);
            
            [remodelerFunction, functionPath] = GetRemodelerAPIFunction('BeforeCondition', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            feval(remodelerFunction, [], [], {}, {}, [], hints);
            
            [remodelerFunction, functionPath] = GetRemodelerAPIFunction('AfterCondition', hints);
            testCase.assertInstanceOf(remodelerFunction, 'function_handle');
            testCase.assertEqual(exist(functionPath, 'file'), 2);
            feval(remodelerFunction, [], [], {}, {}, [], hints);
        end
    end
end
