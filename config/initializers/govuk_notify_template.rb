GOVUK_NOTIFY_TEMPLATES = {
  english: {
    completed_application_refund: ENV.fetch('NOTIFY_COMPLETED_NEW_REFUND_TEMPLATE_ID'),
    completed_application_online: ENV.fetch('NOTIFY_COMPLETED_ONLINE_TEMPLATE_ID'),
    completed_application_paper: ENV.fetch('NOTIFY_COMPLETED_PAPER_TEMPLATE_ID')
  },
  welsh: {
    completed_application_refund: ENV.fetch('NOTIFY_COMPLETED_CY_NEW_REFUND_TEMPLATE_ID'),
    completed_application_online: ENV.fetch('NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID'),
    completed_application_paper: ENV.fetch('NOTIFY_COMPLETED_CY_PAPER_TEMPLATE_ID')
  }
}.freeze
