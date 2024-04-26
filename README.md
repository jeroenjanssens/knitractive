
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

## Everybody can knit with `knitractive`

R Markdown files combine text and code to produce, using a process
called knitting, dynamic documents such as reports, presentations,
websites, and even books. Unlike the name suggests, R Markdown isn’t
just for useRs, but also for Pythonistas, Rubyists, Perl Monks, Lispers,
and basically everybody who enjoys a good REPL. There’s just one issue:
only code chunks written in R–and since recently Python—are evaluated in
a persistent environment; code chucks in any other language are
evaluated separately.

The `knitractive` package solves this issue by providing a `knitr`
engine that allows you to simulate interactive sessions (e.g., Jupyter
console, Bash shell, Postgres CLI) across multiple code chunks.
Interactive sessions are run inside a tmux session (optionally via a
Docker container) through the `tmuxr` package.

I initially developed `knitractive` along with
[tmuxr](https://jeronejanssens.github.io/tmuxr) and
[rexpect](https://jeroenjanssens.github.io/rexpect) in order to make my
book *Data Science at the Command Line* available online, in the same
way as Hadley Wickham and Garrett Grolemund’s *R for Data Science*. Now
that these packages are open source, I hope that they’ll enable others
to create beautiful R Markdown documents with their favorite programming
language or REPL.

## Installation

You can install `knitractive` from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("jeroenjanssens/knitractive")
```

## License

The `knitractive` package is licensed under the MIT License.
