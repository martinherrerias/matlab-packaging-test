function tests = testTemplating
    tests = functiontests(localfunctions);
end

function setup(testCase)

    tempDir = tempname;
    mkdir(tempDir);
    testCase.TestData.myTempDir = tempDir;

    testCase.TestData.oldPath = pwd;
    cd(tempDir);
end

function teardown(testCase)

    cd(testCase.TestData.oldPath);

    if isfolder(testCase.TestData.myTempDir)
        rmdir(testCase.TestData.myTempDir, 's');
    end
end

function testDryDoesNotCopyFiles(testCase)
    listingBefore = dir();
    PkgBuild.template('**', dryrun=true);
    listingAfter = dir();
    testCase.verifyEqual(listingAfter, listingBefore);
end

function testCopyToProject(testCase)
    mkdir('foo');
    PkgBuild.template('matlab.toml', prj='foo', dryrun=false);
    testCase.verifyTrue(isfile(fullfile('foo', 'matlab.toml')));
end

function testFilters(testCase)
    PkgBuild.template('matlab.toml');
    testCase.verifyTrue(isfile('./matlab.toml'));

    PkgBuild.template('tests');
    testCase.verifyTrue(isfile('./tests/testDummy.m'));

    PkgBuild.template('**/release.yaml', 'buildfile.m', dryrun=false);
    testCase.verifyTrue(isfile(fullfile('.github', 'workflows', 'release.yaml')));
    testCase.verifyTrue(isfile('buildfile.m'));

    PkgBuild.template('resources','!**/*.png');
    testCase.verifyEmpty(dir('./resources/*.png'));
end

function testSkipExisting(testCase)
% templating the same file throws 'PkgBuild:template:skip',
% and keeps the original

    PkgBuild.template('matlab.toml', prj='.', dryrun=false);
    testCase.verifyTrue(isfile('./matlab.toml'));

    timestampBefore = dir('./matlab.toml').datenum;
    pause(0.1);
    testCase.verifyWarning(@() PkgBuild.template('matlab.toml', prj='.', dryrun=false), 'PkgBuild:template:skip');
    timestampAfter = dir('./matlab.toml').datenum;
    testCase.verifyEqual(timestampAfter, timestampBefore);
end
