# Changelog

Notable changes and the reasoning behind non-obvious ones. Newest first.

## 2026-07-22

- **Jenkinsfile_CNP: `rvm get master` before `rvm install`.** The infra update moved
  Jenkins agents to Ubuntu 24.04, which has no prebuilt Ruby binary, so rvm compiles
  from source. The agent's bundled rvm (1.29.12, the latest release, from 2021) asks
  apt for `libncurses5-dev`, which Ubuntu 24.04 removed in favour of `libncurses-dev`.
  The fix ([rvm/rvm#5477](https://github.com/rvm/rvm/pull/5477)) was merged to rvm
  master in 2024 but never released, so `rvm get stable` does not help — master is
  the only option. Expect the "Ruby version install" step to take several minutes
  per stage while Ruby compiles.

- **`.rubocop.yml`: Jenkinsfiles excluded.** They are Groovy; editor rubocop
  integrations lint the open file by passing its path explicitly, which bypasses
  rubocop's Ruby-file detection and reports bogus `Lint/Syntax` errors. Editors use
  `--force-exclusion`, so the exclude list fixes it.
