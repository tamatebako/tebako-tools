[![lint](https://github.com/tamatebako/macos-cross-compile/actions/workflows/lint.yml/badge.svg)](https://github.com/tamatebako/macos-cross-compile/actions/workflows/lint.yml)

## Tebako portability tools ##

This repository contains cmake, shell scripts and include files aimed to support tebako builds on different platforms.

## Homebrew cross-installation scripts ##

Sometimes you need to build MacOS application in a foreign environment. For example, GitHub Actions provides x86 runners only, but you may need to build and package arm64 binary.
Most of the applications rely on external dependencies, so on MacOS you will require a method to use another instance of homebrew to support the target environment.

Among other tools this repository provides a set of simple scripts to cross install homebrew dependencies

### arm64 packages on x86_64 system

```
    arm-brew-install <arm brew parent folder>
    arm-brew-setup <arm brew folder> <formula to install 1> ... <formula to install 1>
```

For example

```
    arm-brew-install ~/test
    arm-brew-setup ~/test glog gflags
```

Will create arm brew environment in ~/test/arm-homebrew and install glog and gflags formulae there


### x86_64 packages on arm system

```
    x86_64-brew-install <x86_64 brew parent folder>
    x86_64-brew-setup <x86_64 brew folder> <formula to install 1> ... <formula to install 1>
```

For example

```
    x86_64-brew-install ~/test
    x86_64-brew-setup ~/test glog gflags
```

Will create x86_64 brew environment in ~/test/x86_64-homebrew and install glog and gflags formulae there

There are related discussions at https://github.com/orgs/Homebrew/discussions/2843
and https://stackoverflow.com/questions/70821136/can-i-install-arm64-libraries-on-x86-64-with-homebrew/70822921#70822921
