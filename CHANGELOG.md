# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
with entries grouped by branch and date rather than release version.

## rst-8317-export-update — 2026-08-13

### Changed

- Exports: pre-UCD evidence checks predate the `income_check_type` field, so it is
  blank on those rows even though every pre-UCD income check was done on paper. The
  "DB income check type" column in the raw data, applications-by-court and Power BI
  exports now reports `paper` when the application is pre-UCD (calculation scheme
  blank or `prior_q4_23`) and the evidence check's `income_check_type` is NULL.
  Rows without an evidence check, and post-UCD blanks, are unchanged.

## rst-8490-frontend-updates — 2026-08-10

### Added

- Re-introduced the DWP offline override, as used during the May–Nov 2025 DWP outage
  (originally ebf92a09/574d8480/4e88da81, reversed by 6e758f19). When the admin-set
  `DwpWarning` state is `offline`: no benefit checks are sent to DWP (paper flow
  already skipped them; `OnlineBenefitCheckRunner` — including the rerun job — now
  skips too), and staff are no longer blocked from processing: the paper-evidence
  page processes even when the answer is "no evidence" (previously kicked back to
  the homepage with "cannot process application"), and the online-application
  benefits page proceeds to the summary instead of redirecting home. Staff decisions
  are recorded via the existing `benefits_override`/`dwp_manual_decision` fields.
  New `DwpWarning.offline?` replaces the duplicated
  `DwpWarning.order(id: :desc).first&.check_state == …` checks.
- The online "Evidence of benefits" page's outage banner ("Due to the benefits
  checker being down…") now keys off `dwp_checker_state` (admin `DwpWarning`
  override with `DwpMonitor` fallback) instead of raw `DwpMonitor`. Under the
  offline override no checks are sent, so the monitor never trips and the banner
  would not have shown; the paper benefits page already used `dwp_checker_state`.
  `dwp_checker_state` is now exposed as a view helper. The banner is now a single
  block — bold "DWP evidence check is disabled" heading plus the supporting-evidence
  sentence — and suppresses the "DWP evidence check has failed" block while offline.
  The "BEFORE PROCEEDING FURTHER…" evidence hint still renders below the banner.
- The online application check-details page now shows "Correct evidence provided"
  under "Benefits declared in application" (paper summaries already had it):
  the staff member's manual answer when one was recorded (`dwp_manual_decision`
  set — DWP offline or errored), otherwise the DWP check result; hidden when
  neither exists. A "Change" link back to the Evidence of benefits page appears
  only for manual answers. Logic lives in `Views::Overview::OnlineBenefitEvidence`.
- `ProcessApplication` now persists the manual evidence decision when completing
  an online application: previously a `BenefitOverride` was only created for
  "Yes" answers, so a "No" recorded while DWP was offline left no trace on the
  processed application. A manual "No" (`dwp_manual_decision: false`) now stores
  `BenefitOverride(correct: false)`, matching the paper flow; outcome handling
  is unchanged ("Yes" → full, "No" → none via the existing runner fallback).
  `BenefitCheckRunner#checks_allowed?` now uses the shared `DwpWarning.offline?`.

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
