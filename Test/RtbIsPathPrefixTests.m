classdef RtbIsPathPrefixTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testPrefix(testCase)
            testCase.assertTrue(IsPathPrefix('/foo/bar/', '/foo/bar/baz'));
            testCase.assertTrue(IsPathPrefix('/foo/bar/fileA.txt', '/foo/bar/baz/fileB.png'));
            
            testCase.assertFalse(IsPathPrefix('/foo/bar/baz', '/foo/bar/'));
            testCase.assertFalse(IsPathPrefix('/foo/bar/baz/fileB.png', '/foo/bar/fileA.txt'));
        end
        
        function testEqual(testCase)
            testCase.assertTrue(IsPathPrefix('/foo/bar/', '/foo/bar/fileA.txt'));
            testCase.assertTrue(IsPathPrefix('/foo/bar/fileA.txt', '/foo/bar/'));
        end
        
        function testRemainder(testCase)
            pathA = '/foo/bar/';
            pathB = '/foo/bar/baz/thing.txt';
            [isPrefix, remainder] = IsPathPrefix(pathA, pathB);
            testCase.assertTrue(isPrefix);
            testCase.assertEqual(remainder, 'baz/thing.txt');
            
            reproduction = fullfile(pathA, remainder);
            testCase.assertEqual(reproduction, pathB);
        end
        
    end
end
