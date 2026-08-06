%% TestPackage
%
%% Description
% This is an experiment to try to figure out how to do CI/CD of MATLAB toolboxes 
% (soon "packages"), trying to embrace the R2026b transition to TOML-based projects.
%
%% System Requirements
% * Aiming for it to work on R2025a+ and all platforms
% * For anything before R2026b, we might need external <https://github.com/g-s-k/matlab-toml matlab-toml>
%
%% Target Features
% *NOTE:* most of these are still *aspirational!*
%
% * Single source of project metadata (no copy-paste to |resources/mpackage.json| 
% and FileExchange UI)
% * Versioned deployments to FileExchange using GitHub actions
% * Clear definition of paths that are bundled/excluded in the package
% * Clear definition of paths that are added to the user path during install
% * Install/uninstall "hook" scripts to do one-time tasks?
%
%% Tests
% To see if the package installed correctly try:

dummy(6, 7)
runtests("testDummy")
