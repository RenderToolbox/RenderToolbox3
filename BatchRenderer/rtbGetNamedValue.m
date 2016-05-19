function value = rtbGetNamedValue(names, values, name, defaultValue)
%% Find a value by name, or use a default.
%
% value = rtbGetNamedValue(names, values, name, defaultValue)
% Locates the given name among the cell array of given names, and returns
% the corresponding value from the cell array of given values.  If no such
% name is found, returns the given defaultValue.
%
% This is a convenience function to make it a one-liner to access names and
% values from parallel cell arrays.
%
% value = rtbGetNamedValue(names, values, name, defaultValue)
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addRequired('names', @iscellstr);
parser.addRequired('values', @iscell);
parser.addRequired('name', @ischar);
parser.addRequired('defaultValue');
parser.parse(names, values, name, defaultValue);
names = parser.Results.names;
values = parser.Results.values;
name = parser.Results.name;
defaultValue = parser.Results.defaultValue;

isMatch = strcmp(name, names);
if any(isMatch)
    value = values{find(isMatch, 1, 'first')};
else
    value = defaultValue;
end
