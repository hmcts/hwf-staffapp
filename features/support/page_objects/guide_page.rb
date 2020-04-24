class GuidePage < BasePage
  set_url '/guide'

  section :content, '#content' do
    element :guide_header, 'h1', text: 'See the guides'
    element :how_to_guide, 'a', text: 'How to Guide'
    element :key_control_checks, 'a', text: 'Key Control Checks'
    element :covid_guidance, 'a', text: 'COVID 19 guidance'
    element :staff_guidance, 'a', text: 'Staff guidance'
    element :process_application, 'a', text: 'Process application'
    element :evidence_checks, 'a', text: 'Evidence checks'
    element :part_payments, 'a', text: 'Part-payments'
    element :appeals, 'a', text: 'Appeals'
    element :fraud_awareness, 'a', text: 'Fraud awareness'
    element :suspected_fraud, 'a', text: 'Suspected fraud'
  end
end
