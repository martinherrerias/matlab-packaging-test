# Matlab Packaging Notes

## GitHub Integration

Since [2024](https://uk.mathworks.com/matlabcentral/discussions/highlights/847426-enhancing-github-and-file-exchange-connection-matlab-and-simulink-integration-for-github-unveiled), it seems it is possible to link a raw GitHub repo and let it appear as a FileExchange repository:

<https://github.com/apps/matlab-and-simulink-integration/>

It is not clear whether/how metadata from the repo is used to populate the package info.

## R2026a and older versions

### _Package Toolbox_ from the Add-Ons menu

- Metadata stored in a mess of XML files under `resources/project` (and `%appdata%`).
- Projects don't work together with [`mpm`](#mpmcreate-and-mpminstall) packages.
- Outputs `.mltbx` file.

### `matlab.addons.toolbox`

Can do the same programmatically. Some settings (but not all) get imported from `resources/mpackage.json` (see [below](#mpmcreate-and-mpminstall)). Omissions/extensions could be addressed by reading the JSON manually?

```matlab
identifier = '9dae281f-ff1f-4f2e-a885-ad27c79cf1fb';
opts = matlab.addons.toolbox.ToolboxOptions(pwd, identifier);

% 
opts.ToolboxName: "example"
opts.ToolboxVersion: "0.1.0"
% ...

matlab.addons.toolbox.packageToolbox(opts);
```

### `mpmcreate` and `mpminstall`

- Package config stored in `resources/mpackage.json`.
- Doesn't play together with project files.
- Meant for local distribution (_Repositories_ are local folders).


## R2026b (pre-release)

- `matlab.toml` resolves the XML mess, and mostly[^1] works with `matlab.addons.toolbox.packageToolbox`
- `FileExchange` should be integrated as an `mpm` Repository, but it's not working yet (listed in known issues).
- `mpmcreate/install` still disconnected from (but can co-exist with) project file.
- R2026b not yet available on Docker or GH actions :(

[^1]: Everything but multi-platform dependencies?

