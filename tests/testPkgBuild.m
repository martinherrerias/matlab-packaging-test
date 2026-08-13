function tests = testPkgBuild
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)

    tempDir = tempname;
    mkdir(tempDir);

    testCase.TestData.myTempDir = tempDir;
    testCase.TestData.tomlFile = fullfile(fileparts(mfilename('fullpath')), '..', 'matlab.toml');
end

function teardownOnce(testCase)

    if isfolder(testCase.TestData.myTempDir)
        rmdir(testCase.TestData.myTempDir, 's');
    end
end

function setup(testCase)

    testCase.TestData.oldPath = pwd;
    cd(testCase.TestData.myTempDir);
end

function teardown(testCase)

    cd(testCase.TestData.oldPath);
end


%% Test functions

function testMapToolboxOptionsReturnsOptions(testCase)
    opts = PkgBuild.mapToolboxOptions(testCase.TestData.tomlFile);
    testCase.verifyClass(opts, 'matlab.addons.toolbox.ToolboxOptions');
end

function testFromTOMLProducesFile(testCase)
    outputFile = fullfile(testCase.TestData.myTempDir, 'output.mltbx');
    overrides = {'OutputFile', 'output.mltbx', 'ToolboxVersion', '0.0.0'};
    PkgBuild.fromTOML(testCase.TestData.tomlFile, overrides{:});
    testCase.verifyTrue(isfile(outputFile));
end
