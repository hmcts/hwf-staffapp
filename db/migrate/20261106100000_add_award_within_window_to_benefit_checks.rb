# Sanity check on DWP's date filtering, not for MI; nil when there's nothing to compare - see CHANGELOG.md
class AddAwardWithinWindowToBenefitChecks < ActiveRecord::Migration[8.1]
  def change
    add_column :benefit_checks, :award_within_window, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
