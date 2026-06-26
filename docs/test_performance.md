# Test performance metrics (local)

A local way to see what's slow in the test suite so we can measure before/after
when speeding things up. None of this runs on CI - CI is unchanged.

## See the stats

```
# Whole suite: slowest examples/groups + which factories cost the most time.
bundle exec rake test:profile

# Scope it to a folder or file:
bundle exec rake "test:profile[spec/features]"
bundle exec rake "test:profile[spec/models/benefit_check_spec.rb]"
```

This runs RSpec with `--profile 25` and `test-prof`'s FactoryProf. You'll see:

- **Top 25 slowest examples** and **slowest example groups** - which specs to
  look at first.
- **`Finished in X seconds`** - the suite/scope total (use this to compare runs).
- **FactoryProf report** - a table of factories by total time and number of
  runs. Excessive `create` (vs `build`/`build_stubbed`) and deep factory
  associations are the usual reason specs are slow.

## Other profilers (optional)

`test-prof` profilers switch on via env var on a normal `rspec` run, e.g.:

```
EVENT_PROF='sql.active_record' bundle exec rspec spec/features   # time spent in SQL
```

## Comparing before/after

Note the `Finished in` total and the Top-N slowest lists, make a change, run
the same scope again, and compare.

## Likely next levers

- **Parallelise RSpec.** `parallel_tests` is already in the Gemfile but the suite
  runs serially - splitting spec files across cores is the biggest expected win.
- **Cut factory cost** in the slowest specs (`build_stubbed` / `let_it_be`).
