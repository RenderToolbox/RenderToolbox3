function [imageFile, isRecoded, info] = rtbRecodeImage(imageFile, varargin)
%% Rewrite an image of an unwanted format to a preferred format.
%
% The idea here is to re-write an image file to some useful type, and
% return info about the new file.  This uses Matlab's built-in imread() and
% imwrite().
%
% [imageFile, info] = rtbRecodeImage(imageFile) checks the given
% imageFile of to see if it's of an unwanted type.  If so, re-codes the
% image to a desirable type.
%
% rtbRecodeImage( ... 'toReplace', toReplace) specifies a cell array
% of file extensions (see imformats()) for unwanted images types that
% should be re-coded.  The default is {'gif'}, replace only GIF images.
%
% rtbRecodeImage( ... 'targetFormat', targetFormat) specifies the
% file extension of the desirable image format that should be used when
% re-coding the given image.  The default is 'png', recode the image as a
% PNG.
%
% Returns the given imageFile name, scene, which may have been changed to a
% new name.  Also returns a logical flag true when the given imageFile was
% recoded. Also returns a struct with info about the recoding process.
%
% See also imformats
%
% [imageFile, isRecoded, info] = rtbRecodeImage(imageFile, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = inputParser();
parser.addRequired('imageFile', @ischar);
parser.addParameter('toReplace', {'gif'}, @iscellstr);
parser.addParameter('targetFormat', 'png', @ischar);
parser.parse(imageFile, varargin{:});
imageFile = parser.Results.imageFile;
toReplace = parser.Results.toReplace;
targetFormat = parser.Results.targetFormat;

isRecoded = false;

%% Do we need to recode this image?
[imagePath, imageBase, imageExt] = fileparts(imageFile);
if ~any(strcmp(toReplace, imageExt(2:end)))
    info.verbatimName = imageFile;
    info.writtenName = imageFile;
    info.isRead = false;
    info.isWritten = false;
    info.error = [];
    return;
end

%% Try to read the image.
try
    [imageData, colorMap] = imread(imageFile);
catch ex
    % report an unreadable file
    info.verbatimName = imageFile;
    info.writtenName = imageFile;
    info.isRead = false;
    info.isWritten = false;
    info.error = ex;
    return;
end

%% Try to re-code the image.
try
    writtenName = fullfile(imagePath, [imageBase '.' targetFormat]);
    imwrite(imageData, colorMap, writtenName, targetFormat);
catch ex
    % report an unwritten file
    info.verbatimName = imageFile;
    info.writtenName = imageFile;
    info.isRead = true;
    info.isWritten = false;
    info.error = ex;
    return;
end

%% Report success.
isRecoded = true;
info.verbatimName = imageFile;
info.writtenName = imageFile;
info.isRead = true;
info.isWritten = true;
info.error = [];

