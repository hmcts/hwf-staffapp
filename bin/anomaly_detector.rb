#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'date'

class AnomalyDetector
  attr_reader :anomalies, :data

  def initialize(file_path)
    @file_path = file_path
    @anomalies = []
    @data = []
  end

  def run
    load_data
    puts "=" * 70
    puts "ANOMALY DETECTION REPORT"
    puts "=" * 70
    puts "\nLoaded #{@data.length} records from #{@file_path}\n\n"

    check_test_data
    check_outliers
    check_invalid_dates
    check_data_inconsistencies
    check_suspicious_income_changes
    check_hmrc_vs_evidence_income
    check_duplicate_references

    print_summary
    export_report
  end

  private

  def load_data
    # Read file and handle various encodings from Excel exports
    content = File.read(@file_path, encoding: 'bom|utf-8')
    @data = CSV.parse(content, headers: true).map(&:to_h)
  rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError, CSV::InvalidEncodingError
    # Read as binary and convert to UTF-8, replacing problematic characters
    content = File.read(@file_path, mode: 'rb')
    content = content.encode('utf-8', 'windows-1252', invalid: :replace, undef: :replace, replace: '?')
    @data = CSV.parse(content, headers: true).map(&:to_h)
  rescue Errno::ENOENT
    abort "Error: File not found - #{@file_path}"
  end

  # Check 1: Test/placeholder data
  def check_test_data
    test_patterns = /test|dummy|fake|sample|example/i

    @data.each do |row|
      if row['office']&.match?(test_patterns)
        add_anomaly(row, 'Test Data', 'office', row['office'],
                    'Contains test-related keyword - likely test/development data')
      end

      if row['form']&.match?(test_patterns)
        add_anomaly(row, 'Test Data', 'form', row['form'],
                    'Contains test-related keyword - likely test/development data')
      end
    end
  end

  # Check 2: Numeric outliers using IQR method
  def check_outliers
    numeric_checks = {
      'fee' => { max_reasonable: 10_000, check_iqr: true },
      'children' => { max_reasonable: 10, check_iqr: false },
      'pre evidence income' => { max_reasonable: 50_000, check_iqr: true }
    }

    numeric_checks.each do |field, config|
      values = @data.map { |r| parse_numeric(r[field]) }.compact

      if config[:check_iqr] && values.length > 10
        q1, q3 = percentile(values, 25), percentile(values, 75)
        iqr = q3 - q1
        upper_bound = q3 + (1.5 * iqr)

        @data.each do |row|
          value = parse_numeric(row[field])
          next unless value && value > upper_bound && value > config[:max_reasonable]

          add_anomaly(row, 'Outlier', field, value,
                      "Value #{value} exceeds IQR upper bound (#{upper_bound.round(2)})")
        end
      else
        @data.each do |row|
          value = parse_numeric(row[field])
          next unless value && value > config[:max_reasonable]

          add_anomaly(row, 'Outlier', field, value,
                      "Unusually high value (>#{config[:max_reasonable]})")
        end
      end
    end
  end

  # Check 3: Invalid/suspicious dates
  def check_invalid_dates
    @data.each do |row|
      dob = parse_date(row['date of birth'])
      next unless dob

      # Very old DOB
      if dob < Date.new(1920, 1, 1)
        add_anomaly(row, 'Invalid Date', 'date of birth', row['date of birth'],
                    'DOB before 1920 - applicant would be over 100')
      end

      # Check date sequence: decision should be after received
      received = parse_date(row['date received'])
      decision = parse_date(row['decision date'])

      if received && decision && decision < received
        add_anomaly(row, 'Date Sequence Error', 'decision date', row['decision date'],
                    "Decision date (#{decision}) is before received date (#{received})")
      end

      # Suspiciously quick processing for paper applications with evidence check
      if received && decision
        days = (decision - received).to_i
        source = row['source']
        evidence_checked = row['evidence checked?']

        if source == 'paper' && evidence_checked == 'true' && days < 1
          add_anomaly(row, 'Quick Processing', 'decision date', "#{days} days",
                      'Paper application with evidence check processed same day')
        end
      end
    end
  end

  # Check 4: Data inconsistencies
  def check_data_inconsistencies
    @data.each do |row|
      # decision vs granted? mismatch
      granted = row['granted?']
      decision = row['decision']

      if granted == 'false' && decision == 'full'
        add_anomaly(row, 'Data Inconsistency', 'granted?/decision',
                    "granted?=#{granted}, decision=#{decision}",
                    'Full decision but not marked as granted')
      end

      if granted == 'true' && decision == 'none'
        add_anomaly(row, 'Data Inconsistency', 'granted?/decision',
                    "granted?=#{granted}, decision=#{decision}",
                    'Marked as granted but decision is none')
      end

      # Fee calculation check
      fee = parse_numeric(row['fee'])
      applicant_pay = parse_numeric(row['estimated applicant pay'])
      estimated_cost = parse_numeric(row['estimated cost'])

      if fee && applicant_pay && estimated_cost
        expected = applicant_pay + estimated_cost
        diff = (fee - expected).abs
        if diff > 1 # Allow for rounding
          add_anomaly(row, 'Calculation Error', 'fee',
                      "fee=#{fee}, expected=#{expected.round(2)}",
                      'Fee does not equal applicant pay + estimated cost')
        end
      end
    end
  end

  # Check 5: Suspicious income changes
  def check_suspicious_income_changes
    @data.each do |row|
      pre = parse_numeric(row['pre evidence income'])
      post = parse_numeric(row['post evidence income'])

      next unless pre && post && pre > 0

      change_pct = ((post - pre).abs / pre.to_f) * 100

      if change_pct > 300
        add_anomaly(row, 'Suspicious Income Change', 'income',
                    "pre=#{pre}, post=#{post} (#{change_pct.round(1)}% change)",
                    'Income changed by more than 300% after evidence check')
      end
    end
  end

  # Check 6: HMRC income vs evidence check income discrepancies
  def check_hmrc_vs_evidence_income
    @data.each do |row|
      hmrc_income = parse_numeric(row['HMRC total income'])
      evidence_income = parse_numeric(row['post evidence income'])

      next unless hmrc_income && evidence_income

      diff = (hmrc_income - evidence_income).abs

      # Flag if difference is more than 20% and more than £500
      if hmrc_income > 0 && diff > 500
        diff_pct = (diff / hmrc_income.to_f) * 100
        if diff_pct > 20
          add_anomaly(row, 'HMRC vs Evidence Income Mismatch', 'income',
                      "HMRC=#{hmrc_income}, Evidence=#{evidence_income} (#{diff_pct.round(1)}% diff)",
                      'Significant difference between HMRC income and evidence check income')
        end
      end
    end
  end

  # Check 7: Duplicate references
  def check_duplicate_references
    references = @data.map { |r| r['reference'] }
    duplicates = references.group_by(&:itself).select { |_, v| v.size > 1 }.keys

    duplicates.each do |ref|
      @data.select { |r| r['reference'] == ref }.each do |row|
        add_anomaly(row, 'Duplicate', 'reference', ref,
                    'Duplicate reference number found')
      end
    end
  end

  def add_anomaly(row, type, field, value, reason)
    @anomalies << {
      id: row['id'],
      reference: row['reference'],
      anomaly_type: type,
      field: field,
      value: value.to_s,
      reason: reason
    }
  end

  def print_summary
    puts "=" * 70
    puts "SUMMARY"
    puts "=" * 70
    puts "\nTotal anomalies found: #{@anomalies.length}"
    puts "Unique records affected: #{@anomalies.map { |a| a[:id] }.uniq.length}"

    puts "\n--- BY ANOMALY TYPE ---"
    @anomalies.group_by { |a| a[:anomaly_type] }
              .sort_by { |_, v| -v.length }
              .each { |type, items| puts "  #{type}: #{items.length}" }

    puts "\n--- SAMPLE ANOMALIES (first 20) ---"
    @anomalies.first(20).each_with_index do |a, i|
      puts "#{i + 1}. [#{a[:anomaly_type]}] ID: #{a[:id]}, Ref: #{a[:reference]}"
      puts "   Field: #{a[:field]} = #{a[:value]}"
      puts "   Reason: #{a[:reason]}\n\n"
    end
  end

  def export_report
    output_path = @file_path.sub(/\.csv$/, '_anomalies.csv')
    CSV.open(output_path, 'w') do |csv|
      csv << %w[id reference anomaly_type field value reason]
      @anomalies.each do |a|
        csv << [a[:id], a[:reference], a[:anomaly_type], a[:field], a[:value], a[:reason]]
      end
    end
    puts "\nFull report exported to: #{output_path}"
  end

  # Helper methods
  def parse_numeric(value)
    return nil if value.nil? || value == 'N/A' || value == 'None'

    Float(value)
  rescue ArgumentError, TypeError
    nil
  end

  def parse_date(value)
    return nil if value.nil? || value == 'N/A' || value.to_s.empty?

    # Try common formats
    formats = ['%d/%m/%Y', '%d/%m/%Y %H:%M', '%d/%m/%Y %H:%M:%S', '%Y-%m-%d']
    date_str = value.to_s.split(' ').first # Take just the date part

    formats.each do |fmt|
      return Date.strptime(date_str, fmt.split(' ').first)
    rescue ArgumentError
      next
    end
    nil
  end

  def percentile(array, p)
    sorted = array.sort
    rank = (p / 100.0) * (sorted.length - 1)
    lower = sorted[rank.floor]
    upper = sorted[rank.ceil]
    lower + (upper - lower) * (rank - rank.floor)
  end
end

# Run if executed directly
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "Usage: ruby #{$PROGRAM_NAME} <path_to_csv_file>"
    puts "Example: ruby #{$PROGRAM_NAME} data.csv"
    exit 1
  end

  detector = AnomalyDetector.new(ARGV[0])
  detector.run
end