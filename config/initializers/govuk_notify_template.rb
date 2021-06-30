GOVUK_NOTIFY_TEMPLATES = {
  english: {
    completed_application: ENV.fetch('NOTIFY_COMPLETED_TEMPLATE_ID'),
    completed_application_refund: ENV.fetch('NOTIFY_COMPLETED_REFUND_TEMPLATE_ID')
  },
  welsh: {
    completed_application: ENV.fetch('NOTIFY_COMPLETED_CY_TEMPLATE_ID'),
    completed_application_refund: ENV.fetch('NOTIFY_COMPLETED_CY_REFUND_TEMPLATE_ID')
  }
}.freeze
