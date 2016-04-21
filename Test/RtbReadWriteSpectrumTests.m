classdef RtbReadWriteSpectrumTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testReadString(testCase)
            [wavelengths, magnitudes] = ReadSpectrum('300:0 800:1');
            testCase.assertEqual(wavelengths, [300 800]');
            testCase.assertEqual(magnitudes, [0 1]');
        end
        
        function testReadFile(testCase)
            spdFile = fullfile(RenderToolboxRoot(), 'Test', 'Fixture', 'D65.spd');
            [wavelengths, magnitudes] = ReadSpectrum(spdFile);
            testCase.assertEqual(wavelengths, [380:5:780]');
            testCase.assertEqual(min(magnitudes), 46.42, 'AbsTol', 1e-6);
            testCase.assertEqual(max(magnitudes), 117.81, 'AbsTol', 1e-6);
            testCase.assertTrue(all(magnitudes > 0));
        end
        
        function testWriteFile(testCase)
            wavelengths = (1:100)';
            magnitudes = rand(size(wavelengths));
            spdFile = fullfile(tempdir(), 'RtbReadWriteSpectrumTests', 'test-spectrum.spd');
            WriteSpectrumFile(wavelengths, magnitudes, spdFile);
            
            [wavelengthsAgain, magnitudesAgain] = ReadSpectrum(spdFile);
            testCase.assertEqual(wavelengths, wavelengthsAgain);
            testCase.assertEqual(magnitudes, magnitudesAgain, 'AbsTol', 1e-6);
        end
    end
end
