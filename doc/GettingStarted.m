%% PkgBuild
%
%% Description
% Build MATLAB toolboxes from a |matlab.toml| file on R2026a and earlier.
% |PkgBuild.fromTOML| reads your |matlab.toml| and calls
% |matlab.addons.toolbox.packageToolbox| to produce a |.mltbx| file,
% providing compatibility for MATLAB releases where native TOML support is
% not yet available (introduced in R2026b).
%
%% System Requirements
% * R2025a or later (all platforms) -- might work on older releases, but
%  the support of a `toolbox.ignore` file is only available in R2025a and later.
% * <https://github.com/g-s-k/matlab-toml matlab-toml> for R2026a and earlier
%  (should be installed automatically by the |mpm|).
%
%% Usage
% To package a toolbox from your project's |matlab.toml|:

PkgBuild.fromTOML("matlab.toml")

%%
% To run the test suite:

PkgBuild.test()
