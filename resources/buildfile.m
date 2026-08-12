function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask;
plan("test") = TestTask;
plan("release").Dependencies = ["check" "test"];

plan.DefaultTasks = ["check" "test"];
end

function releaseTask(~)
% Package Toolbox using matlab-toml

    disp('Running release task')
    tomlFile = fullfile(fileparts(mfilename('fullpath')), '..', 'matlab.toml');
    PkgBuild.fromTOML(tomlFile);
end
