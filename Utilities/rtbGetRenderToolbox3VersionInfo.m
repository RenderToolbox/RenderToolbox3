%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
% Collect revision information about RenderToolbox3 and dependencies.
%
% @details
% Gets revision and data information about RenderTooblox3 and its
% dependencies, including Psychtoolbox, Matlab, the computer, PBRT, and
% Mitsuba.
%
% @details
% Returns a struct that contains information collected about each
% component.
function info = rtbGetRenderToolbox3VersionInfo()

% Git info about RenderToolbox3
try
    info.RenderToolbox3GitInfo = GetGITInfo(rtbRoot());
catch err
    info.RenderToolbox3GitInfo = err;
end

% SVN or git info about Psychtoolbox
try
    info.PsychtoolboxSVNInfo = GetSVNInfo(PsychtoolboxRoot());
    info.PsychtoolboxGITInfo = GetGITInfo(PsychtoolboxRoot());
    
catch err
    info.PsychtoolboxSVNInfo = err;
end

% Matlab version
try
    info.MatlabVersion = version();
catch err
    info.MatlabVersion = err;
end

% Matlab tooblox versions
try
    info.MatlabToolboxVersions = ver();
catch err
    info.MatlabToolboxVersions = err;
end

% Text that includes OS version
try
    info.OSVersion = evalc('ver');
catch err
    info.OSVersion = err;
end

% RenderToolbox3 preferences
try
    info.RenderToolbox3Preferences = getpref('RenderToolbox3');
catch err
    info.RenderToolbox3Preferences = err;
end
