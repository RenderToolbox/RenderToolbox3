function [wavelengths, magnitudes] = ReadSpectrum(spectrum)
% Get wavelengths and magnitudes from a spectrum string or text file.
%
% [wavelengths, magnitudes] = ReadSpectrum(spectrum)
% Scans the given spectrum for wavelength-magnitude pairs.  spectrum
% may be a string or a spectrum data text file.
%
% If spectrum is a string, it must contain wavelength:magnitude pairs,
% with spaces between pairs.  For example:
%   300:0.1 550:0.5 800:0.9
% where 300, 550, and 800 are wavelengths in namometers, and 0.1, 0.5, and
% 0.9 are arbitrary magnutudes for each wavelength.
%
% If spectrum is a file name, the file must contain wavelength-magnitude
% pairs, with new lines between paris.  For example:
%   300 0.1
%   550 0.5
%   800 0.9
% where 300, 550, and 800 are wavelengths in namometers, and 0.1, 0.5, and
% 0.9 are arbitrary magnutudes for each wavelength.
%
% Returns a 1 x n matrix of n wavelengths, and a corresponding 1 x n matrix
% of magnitudes.
%
% [wavelengths, magnitudes] = ReadSpectrum(spectrum)
%
%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('spectrum', @ischar);
parser.parse(spectrum);
spectrum = parser.Results.spectrum;

wavelengths = [];
magnitudes = [];

%% Scan the file or string.
if exist(spectrum, 'file')
    % open the file
    [fid, message] = fopen(spectrum, 'r');
    if fid < 0
        warning(message);
        return;
    end
    
    % scan the file for all numbers
    numbers = fscanf(fid, '%f');
    fclose(fid);
    
else
    % scan the string for colon-separated numbers
    numbers = sscanf(spectrum, '%f:%f');
end


%% Deal out wavelength-magnitude pairs.
wavelengths = numbers(1:2:end);
magnitudes = numbers(2:2:end);
