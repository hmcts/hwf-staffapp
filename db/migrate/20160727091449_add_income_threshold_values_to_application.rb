class AddIncomeThresholdValuesToApplication < ActiveRecord::Migration
  def change
    change_table :applications do |t|
      t.decimal :income_min_threshold, null: true
      t.decimal :income_max_threshold, null: true
    end

    reversible do |dir|
      dir.up do
        Application.where('
          income IS NOT NULL OR
          income_min_threshold_exceeded IS NOT NULL OR
          income_max_threshold_exceeded IS NOT NULL').each do |application|

          unless application.applicant.married.nil?
            thresholds = IncomeThresholds.new(application.applicant.married, application.children || 0)

            application.income_min_threshold = thresholds.min_threshold
            application.income_max_threshold = thresholds.max_threshold
            application.save
          end
        end
      end
    end
  end
end
