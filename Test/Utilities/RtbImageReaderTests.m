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
        
        function testReadDatMaxPlanes(testCase)
            pathHere = fileparts(which('RtbImageReaderTests'));
            datFile = fullfile(pathHere, 'CoordinatesTest.dat');
            [imageData, imageSize] = ReadDAT(datFile, ...
                'maxPlanes', 11);
            
            testCase.assertSize(imageData, [240 320 11]);
            testCase.assertTrue(max(imageData(:)) > 0);
            testCase.assertEqual(imageSize, [240 320 11]);
        end
        
        function testReadExrBadFileNoCrash(testCase)
            try
                [channelInfo, imageData] = ReadMultichannelEXR('no-good.exr');
            catch
                channelInfo = [];
                imageData = [];
            end
            testCase.assertEmpty(channelInfo);
            testCase.assertEmpty(imageData);
        end
        
        function testReadExr(testCase)
            pathHere = fileparts(which('RtbImageReaderTests'));
            datFile = fullfile(pathHere, 'CoordinatesTest.exr');
            [channelInfo, imageData] = ReadMultichannelEXR(datFile);
            
            testCase.assertInstanceOf(channelInfo, 'struct');
            testCase.assertNumElements(channelInfo, 31);
            testCase.assertTrue(max(imageData(:)) > 0);
            testCase.assertSize(imageData, [240 320 31]);
        end
        
    end
end
