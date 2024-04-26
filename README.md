
<!-- README.md is generated from README.Rmd. Please edit that file -->

# knitractive <img src="man/figures/logo.png" align="right" width="100px" />

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

## Overview

The `knitractive` package provides a [knitr](https://yihui.name/knitr/)
engine that allows you to simulate interactive sessions (e.g., Python
console, Bash shell) across multiple code chunks. Interactive sessions
are run inside a tmux session through the
[tmuxr](https://jeronejanssens.github.io/tmuxr) and
[rexpect](https://jeroenjanssens.github.io/rexpect) packages.

## Status

This package is experimental and not documented. Its main purpose was to
build the book [Data Science at the Command
Line](https://jeroenjanssens.com/dsatcl), which contains many
command-line snippets, with R Markdown. It has served this purpose well.
Check out the [examples](/knitractive/articles/) to determine whether
`knitractive` can be useful for you.

## Installation

You can install `knitractive` from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("jeroenjanssens/knitractive")
```

## License

The `knitractive` package is licensed under the MIT License.
