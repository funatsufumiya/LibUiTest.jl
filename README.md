# julia libui test (LibUiTest.jl)

![screenshot](./docs/screenshot.png)

## Run

```bash
$ julia --project=@. -e 'using Pkg; Pkg.instantiate()'
$ julia --project=@. -e 'using LibUiTest; LibUiTest.main()'
```

## Compile standalone executable

NOTE: This takes minutes. Be patient.

```bash
$ julia --project=@. -e 'using Pkg; Pkg.add("PackageCompiler")'
$ julia --project=@. -e 'using PackageCompiler; create_app(".", "build", force=true, incremental=true)'

$ ./build/bin/LibUiTest
```
