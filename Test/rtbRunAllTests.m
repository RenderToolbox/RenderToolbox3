function results = rtbRunAllTests()
%% Run all the TestCase unit tests for RenderToolbox3.
%
%   results = rtbRunAllTests() finds all the TestCase unit tests in the
%   RenderToolbox3 Test/ folder, runs them, and returns the results.
%
%   This is just a convenience, compared to calling the buildint runtests()
%   with a bunch of arguments.
%
%   function results = rtbRunAllTests()
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

pathHere = fileparts(which('rtbRunAllTests'));
results = runtests(pathHere, 'Recursively', true);
