%% PkgBuild
% Links to the README and a list of functions in the toolbox:

PkgBuild.help()

%% Usage
% To create a new package project from the bundled template:

mkdir('my_test_package')
cd('my_test_package')
PkgBuild.template()

%%
% To package an existing toolbox from its |matlab.toml|:

PkgBuild.fromTOML('matlab.toml')

%%
% To run the internal test suite:

PkgBuild.runtests()
