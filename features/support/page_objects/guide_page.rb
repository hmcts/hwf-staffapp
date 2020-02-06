class GuidePage < BasePage
  set_url '/guide'

  section :content, '#content' do
    element :guide_header, 'h1', text: 'See the guides'
    element :how_to_guide, 'span', text: 'How to Guide'
    element :key_control_checks, 'span', text: 'Key Control Checks'
    element :staff_guidance, 'span', text: 'Staff guidance'
    element :process_application, 'span', text: 'Process application'
    element :evidence_checks, 'span', text: 'Evidence checks'
    element :part_payments, 'span', text: 'Part-payments'
    element :appeals, 'span', text: 'Appeals'
    element :fraud_awareness, 'span', text: 'Fraud awareness'
    element :suspected_fraud, 'span', text: 'Suspected fraud'
  end
end
