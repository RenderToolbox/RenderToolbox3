%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make sure the given mappings object has the given property.
%   @param obj
%   @param name
%   @param type
%   @param value
%
% @details
% Make sure the given mappings object has a property with the given name.
% If not, creates a new property with the given name, type, and value.
% Returns the updated mappings object.
%
% @details
% Used internally by MakeSceneFiles().
%
% @details
% Usage:
%   obj = FillInObjectProperty(obj, name, type, value)
%
% @ingroup Mappings
function obj = FillInObjectProperty(obj, name, type, value)
if isempty(obj.properties)
    % make the first property
    obj.properties = makeProperty(name, type, value);
    
else
    isProp = strcmp(name, {obj.properties.name});
    if ~any(isProp)
        % make a missing property
        obj.properties(end+1) = makeProperty(name, type, value);
    end
end


% Make a default property.
function property = makeProperty(name, type, value)
property = struct( ...
    'name', name, ...
    'type', type, ...
    'value', value, ...
    'operator', '=');
