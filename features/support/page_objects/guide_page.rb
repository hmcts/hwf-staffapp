class GuidePage < BasePage
  set_url '/guide'

  section :content, '#content' do
    element :guide_header, 'h1', text: 'See the guides'
    element :how_to_guide, 'a', text: 'How to Guide'
    element :training_course, 'a', text: 'HwF Training Course'
    element :key_control_checks, 'a', text: 'Key Control Checks'
    element :process_application, 'a', text: 'Process application'
    element :old_job_cards, 'a', text: 'Job Cards old legislation'
    element :new_job_cards, 'a', text: 'Job Cards new legislation'
    element :old_staff_guidance, 'a', text: 'Staff guidance old legislation'
    element :new_staff_guidance, 'a', text: 'Staff guidance new legislation'
    element :fraud_awareness, 'a', text: 'Fraud awareness'
    element :RRDS, 'a', text: 'RRDS'
    element :evidence_checks, 'a', text: 'Evidence checks'
    element :part_payments, 'a', text: 'Part-payments'
    element :appeals, 'a', text: 'Appeals'
    element :suspected_fraud, 'a', text: 'Suspected fraud'
    element :guide_body, 'p', text: 'How to process an application, deal with evidence checks, part-payments, appeals, and fraud.'
  end
end
