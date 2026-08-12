The `external/` directory is intended for dependencies that are required for runtime/development, but should not be shipped as part of the published toolbox bundle (by default, this directory is listed in `package.ignore`).

The idea is that it contains git submodules, so that `git clone --recurse-submodules` yields a working copy of the project,
but no external code is uploaded to [FileExchange](https://www.mathworks.com/matlabcentral/fileexchange).

Other packages available on FileExchange can be listed as dependencies in the `matlab.toml` file, and will be downloaded automatically by `mpm` during installation .e.g.:

```toml
[dependencies]
PkgBuild = {version = ">=1.0", id = "88a98551-056e-41b9-ac04-3f9a08225bf9"}
```

The unique package `id` appears on the download link of the package, or as *Identifier* in the list of installed add-ons: `matlab.addons.installedAddons()`.

> [!NOTE]
> ## TODO: external dependencies that are *not* on FileExchange
> There are fields to declare external software dependencies on the TOML, but I'm not sure how/if they are handled by `mpm`. For now, I'm guessing a custom setup script would be best?
