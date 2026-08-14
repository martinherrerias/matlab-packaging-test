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
    PkgBuild.template('**', dryrun=true, quiet=true);
    listingAfter = dir();
    testCase.verifyEqual(listingAfter, listingBefore);
end

function testCopyToProject(testCase)
    mkdir('foo');
    PkgBuild.template('matlab.toml', prj='foo', quiet=true);
    testCase.verifyTrue(isfile(fullfile('foo', 'matlab.toml')));
end

function testFilters(testCase)
    PkgBuild.template('matlab.toml', quiet=true);
    testCase.verifyTrue(isfile('./matlab.toml'));

    PkgBuild.template('tests', quiet=true);
    testCase.verifyTrue(isfile('./tests/testDummy.m'));

    PkgBuild.template('**/release.yaml', 'buildfile.m', quiet=true);
    testCase.verifyTrue(isfile(fullfile('.github', 'workflows', 'release.yaml')));
    testCase.verifyTrue(isfile('buildfile.m'));

    PkgBuild.template('resources','!**/*.png', quiet=true);
    testCase.verifyEmpty(dir('./resources/*.png'));
end

function testSkipExisting(testCase)
% templating the same file throws 'PkgBuild:template:skip',
% and keeps the original

    PkgBuild.template('matlab.toml', quiet=true);
    testCase.verifyTrue(isfile('./matlab.toml'));

    timestampBefore = dir('./matlab.toml').datenum;
    pause(0.1);
    testCase.verifyWarning(@() PkgBuild.template('matlab.toml'), 'PkgBuild:template:skip');
    timestampAfter = dir('./matlab.toml').datenum;
    testCase.verifyEqual(timestampAfter, timestampBefore);
end

function testMessageReporting(testCase)

    msg = evalc("PkgBuild.template('scripts', dryrun=true)");
    testCase.verifyTrue(contains(msg, '2 files would be copied'));
    testCase.verifyTrue(contains(msg, 'scripts'));

    msg = evalc("PkgBuild.template('foo/bar/bam/baz', dryrun=true)");
    testCase.verifyTrue(contains(msg, 'the provided pattern(s) matched no files'));

    msg = evalc("PkgBuild.template('scripts', dryrun=true, quiet=true)");
    testCase.verifyEmpty(msg);
end