%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get a mappings object property value.
%   @param obj
%   @param name
%
% @details
% Get the value of a property value of a mappings object.  Returns the
% value.
%
% @details
% Used internally by rtbMakeSceneFiles().
%
% @details
% Usage:
%   value = GetObjectProperty(obj, name)
%
% @ingroup Mappings
function value = GetObjectProperty(obj, name)
value = [];
if ~isempty(obj.properties)
    isProp = strcmp(name, {obj.properties.name});
    if any(isProp)
        index = find(isProp, 1, 'first');
        value = obj.properties(index).value;
    end
end
