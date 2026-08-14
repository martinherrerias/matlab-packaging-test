classdef TestUtils < matlab.unittest.TestCase

    properties (TestParameter)
        projTOML = struct( ...
            own = prjPath('matlab.toml'), ...
            template = prjPath('template/matlab.toml'));
    end

    methods (Test)

        function testToml2struct(testCase, projTOML)
            % read using external/matlab-toml
            s = PkgBuild.toml2struct(projTOML, true);
            testCase.verifyTrue(isstruct(s) && isscalar(s) && isfield(s,'project'))

            % check consistency of implementation when running on R2026b+
            testCase.assumeTrue(version('-release') >= "2026b")
            t = PkgBuild.toml2struct(projTOML, false);
            testCase.verifyEqual_ish(s, t);
        end

        function testMapToolboxOptionsReturnsOptions(testCase, projTOML)
            opts = PkgBuild.mapToolboxOptions(projTOML, true);
            testCase.verifyClass(opts, 'matlab.addons.toolbox.ToolboxOptions');

            testCase.assumeTrue(version('-release') >= "2026b")
            opts = PkgBuild.mapToolboxOptions(projTOML, false);
            testCase.verifyClass(opts, 'matlab.addons.toolbox.ToolboxOptions');
        end

        function testNewUUIDReturnsValidID(testCase)
            id = PkgBuild.newUUID();
            testCase.verifyMatches(id, '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
        end
    end

    methods
        function verifyEqual_ish(testCase, a, b)
            % allow different-size/class empty values
            if isempty(a) && isempty(b)
                return
            end
            if isstruct(a)
                % allow field order mismatch
                testCase.verifyEmpty(setxor(fieldnames(a), fieldnames(b)));
                for fn = fieldnames(a)'
                    testCase.verifyEqual_ish(a.(fn{1}), b.(fn{1}));
                end
            else
                try
                    % allow char/str, double/int, etc. mismatches
                    assert(all(a == b));
                catch
                    testCase.verifyEqual(a, b);
                end
            end
        end
    end
end

function q = prjPath(p)
    q = fullfile(fileparts(mfilename('fullpath')),'..', p);
end