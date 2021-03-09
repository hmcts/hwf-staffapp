module Views
  module Reports
    class FinanceTransactionalReportDataRow

      attr_accessor :month_year, :entity_code, :sop_code, :office_name, :jurisdiction_name, :remission_amount,
                    :refund, :decision, :application_type, :application_id, :reference, :decision_date, :fee

      def initialize(app)
        @month_year = app.decision_date.strftime("%m-%Y")
        assign_application_attrs(app)
        assign_office_attrs(app)
        assign_jurisdiction_attrs(app)
        assign_details_attrs(app)
      end

      def assign_application_attrs(app)
        @remission_amount = app.decision_cost
        @decision = app.decision
        @application_type = app.application_type
        @application_id = app.id
        @reference = app.reference
        @decision_date = app.decision_date.to_date
      end

      def assign_office_attrs(app)
        @entity_code = app.business_entity.try(:be_code)
        @sop_code = app.business_entity.try(:sop_code)
        @office_name = app.office.name
      end

      def assign_jurisdiction_attrs(app)
        return if app.business_entity.blank?
        @jurisdiction_name = app.business_entity.jurisdiction.name
      end

      def assign_details_attrs(app)
        @refund = app.detail.refund
        @fee = app.detail.fee
      end
    end
  end
end
