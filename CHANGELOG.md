# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
with entries grouped by branch and date rather than release version.

## 2026-09-23 (rst-7881-postcode)

- Optional UK postcode on the paper Personal details page (only when `DWP_API_ENABLED` is on), shown when present on check details, summary and processed pages for paper and online applications; paper DWP checks and the raw data export use it.
- NI/HO/postcode normalisation extracted to `PersonalDetailsFormatter`, shared by the applicant form, partner form and `Applicant` model.
- DWP client no longer hands an expired cached token to the gem, and on a 401 drops the cached token and retries once; previously either state failed every check on that process until restart. Failed connections and rejected calls are now recorded on the benefit check and in `dwp_api_calls`.

## 2026-09-22 (rst-8579-benefit-result-copy)

### Changed

- Benefits section on all summary pages, both schemes: new "DWP check
  passed" row (Yes/No, no Change link) above "Correct evidence provided",
  which now shows the staff paper evidence answer only when the DWP check
  did not pass. A staff answer with no DWP check counts as "No".
- Pre-UCD evidence, part payment, processed and deleted pages now use
  `Views::Overview::Benefits` like the post-UCD pages; the unused
  `paper_evidence` presenter method is removed.
- The "Benefits declared in application" Change link had a missing
  translation in its hidden label; the Cucumber summary feature now uses it
  to reach the benefits page instead of the evidence row link.

## 2026-09-21 (gem-updates-v73)

### Changed

- Updated Ruby 4.0.6 → 4.0.7 (.ruby-version, Gemfile, Dockerfile base image, Jenkinsfile_CNP, Jenkinsfile_nightly, README)
- Updated axe-core-api 4.12.0 → 4.13.0
- Updated pg_search 2.3.8 → 2.4.0 (now requires activerecord >= 8.0; we are on 8.1)
- Updated rubocop 1.90.0 → 1.91.0 (no new offences)
- Updated rubocop-rails 2.37.0 → 2.38.0 (no new offences)
- Updated selenium-webdriver 4.48.0 → 4.49.0
- Updated parallel_tests 5.7.0 → 5.8.0
- Updated faraday 2.14.3 → 2.14.4
- Updated rubyzip 3.6.0 → 3.7.0
- Updated slim-rails 4.0.0 → 4.0.1
- Updated net-imap 0.6.6 → 0.6.7 (transitive)
- Updated jwt 3.2.0 → 3.3.0 (transitive)
- Updated msgpack 1.8.4 → 1.8.5 (transitive)
- Updated playwright-ruby-client 1.62.0 → 1.63.0 (transitive)
- Updated bigdecimal 4.1.2 → 4.1.3 (transitive)
- Updated fugit 1.13.0 → 1.14.0 (transitive)
- Updated notifications-ruby-client 6.4.0 → 6.5.1 (transitive)
- Updated io-console 0.9.2 → 0.9.4 (transitive)
- Updated net-protocol 0.3.0 → 0.4.0 (transitive)
- Updated unicode-display_width 3.2.0 → 3.3.0 and unicode-emoji 4.2.0 → 4.3.0 (transitive)
- Updated mime-types-data 3.2026.0701 → 3.2026.0921 (transitive)
- Updated govuk-frontend 6.5.0 → 6.5.1
- Updated sass 1.104.0 → 1.104.1
- Updated webpack 5.110.3 → 5.111.1
- Updated jest and jest-environment-jsdom 30.5.1 → 30.5.2

### Known issues

- redis 5.4.1 → 6.0.0 held: major bump, needs its own review.
- simplecov stays at ~> 0.22.0 (1.x breaks the SonarQube coverage report).
- cucumber-*, diff-lcs, json, marcel, multi_test majors are constrained by
  their parent gems and were not proposed.
## 2026-09-16 (rst-8578-benefit-summary)

### Fixed

- Benefits showed "Failed" when a DWP check passed after an earlier "no paper
  evidence" answer. Both result views now use one precedence: manager's
  decision, DWP "Yes", paper evidence answer, failed check.
- A paper benefit application with no NI number failed outright because no
  check could run. `allow_benefit_check_override?` now offers the paper
  evidence page when there is no check, and only for benefits applications.

## 2026-09-15 (rst-8574-appeal-flag)

### Added

- `APPEAL_ENABLED` env switch (`Settings.appeal_enabled`, `appeal_available?`
  helper) hides the Evidence Received (appeal) section on the processed
  application page unless set to 1/true. View only: the controller action and
  `appeal_allowed?` are untouched, so a direct POST still records the appeal.

## 2026-09-14 (rst-8282-hmrc-banner)

### Added

- HMRC checker banner on the home page, next to the DWP one. `HmrcMonitor`
  mirrors `DwpMonitor` (last 10 `HmrcCheck` rows, 25% / 50% thresholds).
  Only service-side failures count (`HmrcCheck.service_failure?`); applicant
  data problems and the local tax credit entitlement message are excluded so
  bad applicant details never trip the banner.
- No admin override and no email. Wording follows the RST-8282 wireframe; the
  amber/red box sits inside the state partial to match the DWP banner on the
  RST-8347 branch.
- RST-8289: while the HMRC banner is red, `EvidenceCheckSelector` gives new
  evidence checks `income_check_type` 'paper' instead of 'hmrc', the same path
  as an applicant without the data needed for an HMRC check. Amber does not
  change the route. Existing evidence checks already marked 'hmrc' are not
  touched, and nothing else in the HMRC flow is gated on the state.


## 2026-09-09 (rst-8264-benefit-evidence-after-failed)

### Added

- "Evidence Received" review on the processed application page for benefit
  applications that failed, recorded once per application as an `Appeal`
  (`has_one`, unique index). "Yes" sets the decision to `full`; "No" only
  records the appeal. Either answer is final.
- "Passed on re-opening benefits" column (`true`/`false`/`N/A` from the
  appeal) next to "Benefits granted?" in the raw data, applications
  by court and Power BI exports.

### Why

- `outcome` is left as the original decision and only `decision` changes, so
  the change stays visible; views read `decision` when an appeal exists.
- The original `BenefitOverride` is not touched so the processing-time
  record is preserved.
- The `benefit_overrides.reprocessed` migration from this branch's first
  commit was rolled back and deleted (never deployed) in favour of `Appeal`.

## 2026-09-08 (rst-8415-paid-date)

### Changed

- Online application refunds: the FREG fee search now picks the fee version
  in force on the date the fee was paid, read live from the new date fee paid
  fields on the edit page (e.g. paid 1/8/2026 with the current version valid
  from 2/8/2026 selects the previous version). `getDateFeePaid` in
  app/javascript/freg.js reads the on-screen `online_application_*` fields —
  the value stamped on the search field at render time goes stale once staff
  edit them; editing the date resets any selected fee and re-runs the search
  (the existing change handler already matched the new field ids). Refunds
  only: non-refund applications keep using the date received, and the
  existing refund rules (no fallback to the current version, rateable fees
  kept) apply unchanged.

## 2026-09-07

### Changed

- Updated sentry-ruby and sentry-rails 6.7.0 → 7.0.0 (major; initializer
  options in config/initializers/sentry.rb all still supported)
- Updated rubyzip 3.5.0 → 3.6.0
- Updated image_processing 2.0.3 → 2.1.0
- Updated bootsnap 1.25.0 → 1.26.0
- Updated parallel 2.1.0 → 2.2.0 (transitive)
- Updated jest 30.4.2 → 30.5.1 and jest-environment-jsdom 30.4.1 → 30.5.1
  (deferred from the 2026-09-01 run for soak time)
- Updated webpack 5.110.2 → 5.110.3
- Updated sass 1.103.1 → 1.104.0
- Updated playwright 1.62.1 → 1.63.0

### Known issues

- No open vulnerabilities: bundle-audit and yarn npm audit both clean before
  and after this run.
- redis 6.0.0 approved but still blocked: mock_redis latest (0.55.0) requires
  `redis ~> 5`; retry when mock_redis supports redis 6.
- json 2.21.2 → 3.0.0 deferred — transitive major released the day of this
  run, and confirmed breaking: it slipped into the lockfile via a dependency
  unlock during this run and activesupport 8.1's `ActiveSupport::JSON.decode`
  then failed with `ArgumentError: wrong number of arguments (given 2,
  expected 1)` on `JSON.parse` (session cookie decoding — feature specs
  caught it). Reverted to 2.21.2; do not take json 3.x until Rails supports
  its new `JSON.parse` signature.
- diff-lcs held at 1.6.2 — blocked by rspec-expectations (`< 2.0`) and
  cucumber (`~> 1.5`).
- simplecov held at `~> 0.22.0` — deliberate pin; 1.x breaks the SonarQube
  coverage report.
- cucumber-* family, marcel, multi_test newer majors remain pinned by their
  parents (cucumber, activestorage).

## 2026-09-03 (rst-8387-purge-update)

### Changed

- The personal data purge now selects applications (and standalone online
  applications) by `updated_at` instead of `created_at`
  (PersonalDataPurgeJob): any touch to a record restarts its 7-year purge
  clock, so the purge keys off last activity rather than creation.
- Purging a pending application now also closes it, so purged applications no
  longer sit forever in the staff queues. New `PendingApplicationCloser`
  (app/lib), called by `PersonalDataPurge` after purging, acts as the purge
  user (new `PURGE_USER_ID` env var → `Settings.personal_data_purge.user_id`;
  set in charts values and .env.development) and replicates the journey staff
  would have taken:
  - Waiting for evidence: the "evidence not arrived or too late" return
    journey (as in Evidence::AccuracyFailedReasonController) — the evidence
    check records `correct: false` / `incorrect_reason: 'not_arrived_or_late'`
    and resolves with outcome `return`; the application moves to processed
    with decision `none` (decision_type `evidence_check`).
  - Waiting for part payment: the "Is the part-payment ready to process?" →
    "No" flow (as in PartPaymentsController accuracy_save + summary_save) —
    the part payment records `correct: false` with the closure reason
    "Not processed in time at the time of data purge." and completes with
    outcome `none`; the application moves to processed with decision `none`
    (decision_type `part_payment`).
  Closing happens as part of `purge!`; applications in any other state, or
  pending ones without an evidence check / part payment record, are left
  untouched.
## 2026-09-02 (CI ruby version fix)

### Fixed

- .ruby-version now reads `ruby-4.0.6` (explicit rvm interpreter string)
  instead of the bare `4.0.6`. The Jenkins smoke test stage runs in a fresh
  shell where the agent's old rvm resolves the ruby from .ruby-version; it
  cannot map a bare 4.x number to an interpreter ("Unknown ruby interpreter
  version"), so no gemset was selected and bundler then failed to find the
  azure_env_secrets git checkout ("is not yet checked out") — a symptom, not
  a missing bundle install. The install step already used the explicit string
  (Jenkinsfile_CNP), which is why only later stages failed. Gemfile's
  `ruby '4.0.6'` is unaffected (it does not read the file).

## 2026-09-02 (FREG FEE0001 filter)

### Changed

- The FREG fee search no longer returns FEE0001. It is FREG's test fee
  ("Test flat fee for development"), so it must never be offered to staff,
  yet it matched searches by code, amount, service or jurisdiction like any
  real fee. `findMatches` in app/javascript/freg.js now drops codes listed in
  `EXCLUDED_FEE_CODES` before any matching; add future codes there.

## 2026-09-01

### Changed

- Updated rubocop 1.89.0 → 1.90.0. Its tightened `Layout/ExtraSpacing` cop
  led to whitespace fixes in 4 spec files; its new `Style/DirectiveScope` cop
  is disabled in .rubocop.yml (we keep disable/enable pairs).
- Updated rubyzip 3.4.1 → 3.5.0
- Updated bullet 8.1.3 → 8.2.0
- Updated webmock 3.26.2 → 3.26.4
- Updated selenium-webdriver 4.47.0 → 4.48.0
- Updated responders 3.2.0 → 3.2.1 (transitive)
- Updated net-protocol 0.2.2 → 0.3.0 (transitive)
- Updated et-orbi 1.4.1 → 1.4.2 (transitive)
- Updated rbs 4.1.3 → 4.2.0 (transitive)
- Updated govuk-frontend 6.4.0 → 6.5.0
- Updated sass 1.102.0 → 1.103.1
- Updated webpack 5.109.2 → 5.110.2
- Updated webpack-cli 7.2.2 → 7.2.3
- Header menu spacing (app/assets/stylesheets/local/navigation.scss): the nav
  items' and service name's 15px vertical padding moved onto the container
  from tablet up, with a 10px row-gap on the list — the menu block keeps its
  outer spacing while the wrapped menu rows sit closer together. Side effect:
  the active-page underline now sits snug under the link text instead of at
  the bar's bottom edge (it hung off the item padding).

### Fixed

- Header layout regression from govuk-frontend 6.5.0: it added
  `align-items: center` to `.govuk-service-navigation__container` (for its new
  inline "end slot" feature), which vertically centered the "Help with fees"
  service name between the two rows our long nav wraps into. Restored the
  pre-6.5.0 alignment (`align-items: stretch` from tablet up) in
  app/assets/stylesheets/local/navigation.scss, next to the existing wrapper
  flex override that keeps the name and links on one line.

### Known issues

- No open vulnerabilities: bundle-audit and yarn npm audit both clean before
  and after this run.
- redis 5.4.1 → 6.0.0 deferred — major version bump, to be done as its own change.
- jest / jest-environment-jsdom 30.5.1 deferred — released the same day as this
  run (supply-chain caution); pick up next run.
- diff-lcs held at 1.6.2 — 2.0.0 approved but blocked by rspec-expectations
  (`< 2.0`) and cucumber (`~> 1.5`) constraints.
- simplecov held at `~> 0.22.0` — deliberate pin; 1.x breaks the SonarQube
  coverage report.
- cucumber-* family, marcel, multi_test newer majors exist but are transitive
  and pinned by their parents (cucumber, activestorage).

## 2026-08-25 (rst-8497-benefit-override)

### Changed

- The online flow no longer skips the benefit check when the `DwpMonitor`
  computes offline (≥ 50% of the last 10 checks failed) while the admin
  `DwpWarning` is on Auto/default. `display_paper_evidence_page?` previously
  consulted the monitor directly and went straight to the Evidence of
  benefits page, letting online applications be processed without evidence
  during an auto-detected outage with no admin decision — and diverging from
  the paper flow, which never consults the monitor. Both flows now behave
  identically: only the admin-set DWP offline state skips the check
  (`display_paper_evidence_page?` now mirrors the paper flow's
  `disable_benefit_calls?` via `DwpWarning.offline?`); the monitor only
  drives the warning banner. See docs/benefit_checker_flow.md.

### Fixed

- The online benefits page was missing the rst-8513 InvalidRequest guard that
  the paper flow already had: answering "No evidence" for an InvalidRequest
  ("surname is invalid") check sent staff to the homepage with "cannot process
  application" instead of proceeding to the summary like Undetermined.

### Changed

- Replaced the duplicated per-controller blocking logic
  (`dwp_blocks_processing?` in `BenefitOverridesController` and
  `OnlineApplicationBenefitsController`) with a shared
  `BenefitOverrideRedirection` concern (app/controllers/concerns) providing
  `benefit_override_allowed?(record, evidence_provided:)` and `take_user_home`.
  Positive semantics: true means the staff answer can be recorded and the
  application processed — DWP offline (admin warning), InvalidRequest, or
  evidence provided all allow; only an outage-type error with no evidence
  blocks. The duplication had already let the two flows drift once (the online
  controller missed the InvalidRequest guard).

## 2026-08-20 (rst-8513-bad-request)

### Changed

- DWP BadRequest responses whose message is "surname is invalid" are now stored
  as `dwp_result: 'InvalidRequest'` and treated like Undetermined: DWP answered,
  the applicant's data is the problem, so it is not an outage (no monitor count,
  no rerun) and staff are not blocked. On the paper-evidence page, answering
  "No evidence" for an InvalidRequest check now processes the application with
  outcome "none" (continuing to summary/declaration) instead of redirecting to
  the homepage with "cannot process application" — that redirect is meant for
  outages, where retrying later could still succeed. Guard lives in
  `BenefitOverridesController#allow_benefit_override?` via new
  `BenefitCheck#invalid_request?`.

## 2026-08-18

### Changed

- Updated Ruby 4.0.5 → 4.0.6 (.ruby-version, Gemfile, Dockerfile base image, Jenkinsfile_CNP, Jenkinsfile_nightly, README)
- Updated @rails/actiontext 8.1.300 → 8.1.301 (npm; matches actiontext gem 8.1.3.1)
- Updated bootsnap 1.24.6 → 1.25.0
- Updated brakeman 8.0.5 → 8.0.6
- Updated io-console 0.8.2 → 0.9.2
- Updated pg_search 2.3.7 → 2.3.8
- Updated rack 3.2.6 → 3.2.7
- Updated rbs 4.1.2 → 4.1.3
- Updated rubocop-performance 1.26.1 → 1.27.0
- Updated rubocop-rails 2.36.0 → 2.37.0
- Updated selenium-webdriver 4.46.0 → 4.47.0
- Updated temple 0.10.6 → 0.10.7
- Updated tilt 2.8.0 → 2.9.0
- Updated Yarn 4.17.1 → 4.18.0 (`packageManager` in package.json; Corepack picks it up)

### Known issues

- redis 6.0.0 not applied: `mock_redis` (latest 0.55.0) still requires `redis ~> 5`.
- cucumber-* / diff-lcs / multi_test majors not applied: pinned by cucumber 11.1.1 (latest).
- simplecov held at ~> 0.22.0 deliberately (1.x breaks SonarQube coverage report).

## [Unreleased]
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
