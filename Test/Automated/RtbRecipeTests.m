classdef RtbRecipeTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testLifecycle(testCase)
            % build a recipe
            configureScript = '';
            executive = {@rtbMakeRecipeSceneFiles, @rtbMakeRecipeRenderings, @rtbMakeRecipeMontage};
            parentSceneFile = fullfile(rtbRoot(), 'Test', 'Automated', 'Fixture', 'CoordinatesTest.dae');
            conditionsFile = fullfile(rtbRoot(), 'Test', 'Automated', 'Fixture', 'SimpleConditions.txt');
            mappingsFile = fullfile(rtbRoot(), 'Test', 'Automated', 'Fixture', 'DragonColorCheckerMappings.txt');
            hints.workingFolder = fullfile(tempdir(), 'RtbRecipeTests');
            hints.renderer = 'SampleRenderer';
            hints.remodeler = 'SampleRemodeler';
            
            recipe = rtbNewRecipe( ...
                'configureScript', configureScript, ...
                'executive', executive, ...
                'parentSceneFile', parentSceneFile, ...
                'conditionsFile', conditionsFile, ...
                'mappingsFile', mappingsFile, ...
                'hints', hints);
            
            testCase.assertInstanceOf(recipe, 'struct');
            testCase.assertNumElements(recipe, 1);
            
            % execute the recipe
            recipe = rtbExecuteRecipe(recipe, 'throwException', false);
            testCase.assertInstanceOf(recipe.log, 'struct');
            allErrorData = [recipe.log.errorData];
            if ~isempty(allErrorData)
                rethrow(allErrorData(1));
            end
        end
    end
end
