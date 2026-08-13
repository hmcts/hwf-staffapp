# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Fixed

- Dockerfile: moved `assets:precompile` and `static_pages:generate` from the container
  CMD into the image build. Demo pods now run as a non-root user and `/home/app` is
  root-owned, so the startup-time precompile crashed with
  `Error reading app/assets/builds/application.css: permission denied` (the preceding
  `` `/home/app` is not writable. `` line is only a Bundler warning with a /tmp
  fallback). Master fails identically, confirming the environment, not a code change,
  triggered it. Also pre-created world-writable `tmp/` and `log/` (puma mkdirs
  `tmp/pids` at boot). Verified locally: the image, run as uid 1000 with no special
  permissions, boots puma to `Listening on 0.0.0.0:3000`. Side benefits: startup no
  longer runs yarn at all (the SKIP_YARN_INSTALL guard remains as defence in depth)
  and pods start faster without per-boot precompilation.

### Changed

- Updated erb 6.0.6 → 6.0.7
- Updated image_processing 2.0.2 → 2.0.3
- Updated reline 0.6.3 → 0.7.0
- Updated rubocop 1.88.2 → 1.89.0 (removed a newly redundant `rubocop:disable Style/ArrayIntersect` in `app/models/benefit_check.rb`)
- Updated sentry-rails 6.6.2 → 6.7.0
- Updated sentry-ruby 6.6.2 → 6.7.0
- Updated temple 0.10.4 → 0.10.6
- Updated govuk-frontend 6.3.0 → 6.4.0
- Updated playwright 1.61.1 → 1.62.1
- Updated sass 1.101.0 → 1.102.0
- Updated webpack 5.108.4 → 5.109.2
- Updated webpack-cli 7.2.1 → 7.2.2

### Known issues

- redis held at 5.4.1 — 6.0.0 is a major bump of a runtime dependency; needs its own ticket with a review of the 6.0 breaking changes.
- simplecov deliberately pinned at ~> 0.22.0 — 1.x breaks the SonarQube coverage report.
- cucumber-* subcomponents (cucumber-core, cucumber-gherkin, etc.), diff-lcs and multi_test show newer standalone releases but are constrained by their parent gems (cucumber 11.1.1 and rspec, both current) — no action possible or needed.
