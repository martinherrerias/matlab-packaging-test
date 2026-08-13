# PkgBuild

Build MATLAB toolboxes from `matlab.toml` on R2026a and earlier.
`PkgBuild.fromTOML` is a compatibility shim that packages a `.mltbx` from a
`matlab.toml` project file on MATLAB releases where native TOML support is not
yet available (introduced in R2026b).

## Requirements

- Aiming for it to work on R2025a+ and all platforms
- For anything before R2026b, we might need an external [matlab-toml](https://github.com/g-s-k/matlab-toml) parser (see [below](#r2026b-pre-release)).

## Target Features

> [!NOTE]
> Most of these are still *aspirational*

- Single source of project metadata (no copy-paste to `resources/mpackage.json` and [FileExchange](https://mathworks.com/matlabcentral/fileexchange) UI)
- Versioned deployments to FileExchange using GitHub actions
- Clear definition of paths that are bundled/excluded in the package
- Clear definition of paths that are added to the user path during install
- Install/uninstall "hook" scripts to do one-time tasks?

# MATLAB Packaging Notes

## GitHub Integration

Since [2024](https://uk.mathworks.com/matlabcentral/discussions/highlights/847426-enhancing-github-and-file-exchange-connection-matlab-and-simulink-integration-for-github-unveiled), it seems it is possible to link a raw GitHub repo and let it appear as a [FileExchange](https://www.mathworks.com/matlabcentral/fileexchange) repository:

<https://github.com/apps/matlab-and-simulink-integration/>

The [`mpackage.json`](#mpmcreate-and-mpminstall) and [`matlab.toml`](#r2026b-pre-release) files are utterly ignored. ~~The same metadata has to be entered manually in the web UI... and I'm guessing it has to be periodically updated by hand?~~

*UPDATE*: According to [MATLAB support](https://github.com/gibbonCode/GIBBON/issues/202#issuecomment-5128953874):

> if you attach a .mltbx file as an asset to your GitHub release, File Exchange will automatically extract metadata embedded inside the .mltbx including title, version, MATLAB release compatibility range, required products, and UUID. This is currently the most automated route available for keeping your File Exchange listing up to date without manual web UI entry for those fields.

This is yet to be implemented.

## R2026a and older versions

### _Package Toolbox_ from the Add-Ons menu

- Metadata (entered through _Project_ UI) stored in a mess of XML files under `resources/project` (and `%appdata%` or equivalent).
- Projects don't work together with [`mpm`](#mpmcreate-and-mpminstall) packages.
- Outputs `*.mltbx` file. ~~Not sure if this can be pushed to FileExchange via an API/GitHub-action.~~

*UPDATE*: In [theory](#github-integration) adding the `*.mltbx` file as an asset to a GitHub release should be enough for FileExchange to extract the metadata.

### [`mpmcreate`](https://mathworks.com/help/matlab/ref/mpmcreate.html) and [`mpminstall`](https://mathworks.com/help/matlab/ref/mpminstall.html)

- Package config stored in `resources/mpackage.json`.
- Doesn't play together with project files.
- Meant for local distribution (_Repositories_ are local folders).

### [`matlab.addons.toolbox.ToolboxOptions`](https://mathworks.com/help/matlab/ref/matlab.addons.toolbox.toolboxoptions.html)

Can be used to build a `*.mltbx` file programmatically. Some settings (but not all?) get imported from `resources/mpackage.json` (see [below](#mpmcreate-and-mpminstall)). Omissions/extensions could be addressed by parsing the JSON/TOML manually?

```matlab
identifier = '9dae281f-ff1f-4f2e-a885-ad27c79cf1fb';
opts = matlab.addons.toolbox.ToolboxOptions(pwd, identifier);

% 
opts.ToolboxName: "example"
opts.ToolboxVersion: "0.1.0"
% ...

matlab.addons.toolbox.packageToolbox(opts);
```

## R2026b (pre-release)

- `matlab.toml` resolves the XML mess, and mostly[^1] works with `matlab.addons.toolbox.packageToolbox`
- `FileExchange` should be integrated as an `mpm` Repository, but it's not working yet (listed in known issues).
- `mpmcreate/install` still disconnected from (but can co-exist with) project file.
- R2026b not yet available on Docker or GH actions :(

[^1]: Everything but multi-platform dependencies?
