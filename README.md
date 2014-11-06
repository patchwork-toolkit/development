Patchwork Development Environment Layout
===========

Scripts &amp; configuration required for setting up a Patchwork development environment.

## Setup

```
$ ./setup.sh
This script configures current directory as Patchwork Toolkit development environment.
Proceed? [y/n] y
...
DONE!
```

## Run

```
$ foreman start
03:16:26 mqtt.1 | started with pid 95603
03:16:26 sc.1   | started with pid 95604
03:16:26 dc.1   | started with pid 95605
03:16:26 sr.1   | started with pid 95606
03:16:26 dgw.1  | started with pid 95608
...
```

## Release

```
$ release.sh v0.2.1
...
DONE!
```