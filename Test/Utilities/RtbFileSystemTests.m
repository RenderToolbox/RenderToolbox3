classdef RtbFileSystemTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testFindThisFolder(testCase)
            thisFile = which('RtbFileSystemTests');
            pathHere = fileparts(thisFile);
            fileList = FindFiles('root', pathHere, 'allowFolders', true);
            testCase.assertTrue(any(strcmp(fileList, pathHere)));
        end
        
        function testFindThisFile(testCase)
            thisFile = which('RtbFileSystemTests');
            pathHere = fileparts(thisFile);
            fileList = FindFiles('root', pathHere);
            testCase.assertTrue(any(strcmp(fileList, thisFile)));
        end
        
        function testFindThisFileOnly(testCase)
            thisFile = which('RtbFileSystemTests');
            pathHere = fileparts(thisFile);
            fileList = FindFiles('root', pathHere, ...
                'filter', thisFile, ...
                'exactMatch', true);
            testCase.assertNumElements(fileList, 1);
            testCase.assertEqual(fileList{1}, thisFile);
        end
        
        function testFindTestFiles(testCase)
            toolboxRoot = RenderToolboxRoot();
            fileList = FindFiles('root', toolboxRoot, ...
                'filter', 'Tests.m$');
            testCase.assertNotEmpty(fileList);
            nFiles = numel(fileList);
            for ff = 1:nFiles
                fileName = fileList{ff};
                testCase.assertEqual(fileName(end-6:end), 'Tests.m');
            end
        end
        
        function testFindNotAFolder(testCase)
            fileList = FindFiles('root', 'not-a-folder');
            testCase.assertEmpty(fileList);
        end
        
        function testFindImpossibleFilter(testCase)
            toolboxRoot = RenderToolboxRoot();
            fileList = FindFiles('root', toolboxRoot, 'filter', 'nononono');
            testCase.assertEmpty(fileList);
        end
    end
end
