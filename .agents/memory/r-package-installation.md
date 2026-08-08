---
name: R package installation
description: R 4.5 in this workspace has a read-only global library; package availability must be verified through .libPaths() after installation.
---

The global R library under `/nix/store` is not writable. The available package-management catalog did not expose a usable `rPackages.tidyverse` bundle, and accepting component names did not make them visible to the current `Rscript`.

**Why:** Direct CRAN installation to the global library fails, while source installation into a project-local library can exceed the command timeout for compiled dependencies.

**How to apply:** Prefer a verified project-local library and explicitly configure `.libPaths()`/`R_LIBS_USER`; always test `requireNamespace()` in a fresh `Rscript` process before saying a package is installed.

The football analysis scripts use the tidyverse components directly (`dplyr`, `stringr`, `tidyr`, and `purrr`) instead of requiring the aggregate `tidyverse` package; this works with the installed R environment and avoids its optional dependency chain.

**Why:** The aggregate package could not be made visible to the active R 4.5 runtime, while all required components were installed and verified.

**How to apply:** For these scripts, keep component imports and use `suppressPackageStartupMessages()` to avoid normal attach/masking messages while preserving real warnings and errors.