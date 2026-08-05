module Views
  module Reports
    # Single source of truth for CSV/Power BI export column headers.
    #
    # Every export (raw data, Power BI, applications by court) draws its header
    # labels from this one hash, so a concept is spelled exactly the same way in
    # every export. To rename a column, change it here and nowhere else.
    #
    # Convention: sentence case - capitalise the first word only, keep
    # established acronyms uppercase (HwF, HMRC, NI, DB, SOP, PP, HO), and keep
    # the trailing "?" on yes/no columns.
    module ColumnLabels
      LABELS = {
        id: 'Id',
        office: 'Office',
        reference: 'HwF reference number',
        status: 'Status',
        created_at: 'Created at',
        jurisdiction: 'Jurisdiction',
        sop_code: 'SOP code',
        fee: 'Fee',
        fee_code: 'Fee code',
        claim_amount: 'Claim amount',
        fee_population: 'Fee population',
        estimated_amount_to_pay: 'Applicant pays estimate',
        estimated_cost: 'Departmental cost estimate',
        application_type: 'Application type',
        form: 'Form',
        refund: 'Refund',
        emergency: 'Emergency',
        pre_evidence_income: 'Pre evidence income',
        post_evidence_income: 'Post evidence income',
        income_period: 'Income period',
        ho_ni_number: 'HO/NI number',
        children: 'Children',
        age_band_under_14: 'Age band under 14',
        age_band_14_plus: 'Age band 14+',
        married: 'Married',
        pension_age: 'Pension age',
        decision: 'Decision',
        failed_on_savings: 'Failed on savings',
        final_amount_to_pay: 'Applicant pays',
        departmental_cost: 'Departmental cost',
        source: 'Source',
        granted: 'Granted?',
        benefits_granted: 'Benefits granted?',
        evidence_checked: 'Evidence checked?',
        capital_band: 'Capital band',
        savings_and_investments: 'Savings and investments amount',
        part_payment_outcome: 'Part payment outcome',
        pp_outcome: 'PP outcome',
        low_income_declared: 'Low income declared',
        case_number: 'Case number',
        postcode: 'Postcode',
        date_of_birth: 'Date of birth',
        date_received: 'Date received',
        decision_date: 'Decision date',
        date_paid: 'Date paid',
        application_processed_date: 'Application processed date',
        manual_evidence_processed_date: 'Manual evidence processed date',
        processed_date: 'Processed date',
        date_submitted_online: 'Date submitted online',
        statement_signed_by: 'Statement signed by',
        partner_ni_entered: 'Partner NI entered',
        partner_name_entered: 'Partner name entered',
        hwf_scheme: 'HwF scheme',
        db_evidence_check_type: 'DB evidence check type',
        db_income_check_type: 'DB income check type',
        hmrc_total_income: 'HMRC total income',
        evidence_check_outcome: 'Evidence check outcome',
        evidence_check_type: 'Evidence check type',
        hmrc_response: 'HMRC response?',
        hmrc_errors: 'HMRC errors',
        complete_processing: 'Complete processing?',
        declared_income_sources: 'Declared income sources',
        additional_income: 'Additional income',
        income_processed: 'Income processed',
        hmrc_request_date_range: 'HMRC request date range',
        deletion_reason: 'Deletion reason',
        reason_description: 'Reason description'
      }.freeze

      # Canonical label for a single key (raises if the key is unknown, so a typo
      # fails loudly rather than silently exporting a blank header).
      def self.fetch(key)
        LABELS.fetch(key)
      end

      # Canonical labels for an ordered list of keys - used to build a header row.
      def self.for(keys)
        keys.map { |key| LABELS.fetch(key) }
      end
    end
  end
end
