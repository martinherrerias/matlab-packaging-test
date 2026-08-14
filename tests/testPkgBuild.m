function tests = testPkgBuild
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)

    tempDir = tempname;
    mkdir(tempDir);
    testCase.TestData.myTempDir = tempDir;
    PkgBuild.template(prj=tempDir, quiet=true);
end

function teardownOnce(testCase)

    fclose all;
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

function testFromTOMLNoDependencies(testCase)
    outputFile = fullfile(testCase.TestData.myTempDir, 'output.mltbx');
    overrides = {'OutputFile', 'output.mltbx', 'RequiredAddons', []};
    PkgBuild.fromTOML('matlab.toml', overrides{:});
    testCase.verifyTrue(isfile(outputFile));
end
