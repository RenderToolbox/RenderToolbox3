classdef RtbImageReaderTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testReadDatBadFileNoCrash(testCase)
            try
                [imageData, imageSize, lens] = ReadDAT('no-good.dat');
            catch
                imageData = [];
                imageSize = [];
                lens = [];
            end
            testCase.assertEmpty(imageData);
            testCase.assertEmpty(imageSize);
            testCase.assertEmpty(lens);
        end
        
        function testReadDat(testCase)
            pathHere = fileparts(which('RtbImageReaderTests'));
            datFile = fullfile(pathHere, 'CoordinatesTest.dat');
            [imageData, imageSize] = ReadDAT(datFile);
            
            testCase.assertSize(imageData, [240 320 32]);
            testCase.assertTrue(max(imageData(:)) > 0);
            testCase.assertEqual(imageSize, [240 320 32]);
        end
    end
end
