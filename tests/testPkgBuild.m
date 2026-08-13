function tests = testPkgBuild
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)

    tempDir = tempname;
    mkdir(tempDir);
    testCase.TestData.myTempDir = tempDir;
    PkgBuild.template(prj=tempDir);
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
    opts = PkgBuild.mapToolboxOptions('matlab.toml');
    testCase.verifyClass(opts, 'matlab.addons.toolbox.ToolboxOptions');
end

function testNewUUIDReturnsValidID(testCase)
    id = PkgBuild.newUUID();
    testCase.verifyMatches(id, '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
end

function testFromTOMLNoDependencies(testCase)
    outputFile = fullfile(testCase.TestData.myTempDir, 'output.mltbx');
    overrides = {'OutputFile', 'output.mltbx', 'RequiredAddons', []};
    PkgBuild.fromTOML('matlab.toml', overrides{:});
    testCase.verifyTrue(isfile(outputFile));
end
