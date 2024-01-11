class GuidePage < BasePage
  set_url '/guide'

  section :content, '#content' do
    element :guide_header, 'h1', text: 'See the guides'
    element :guide_body, 'p', text: 'How to process an application, deal with evidence checks, part-payments, appeals, and fraud.'
    element :how_to_guide, 'a', text: 'How to Guide'
    element :training_course, 'a', text: 'HwF Training Course'
    element :key_control_checks, 'a', text: 'Key Control Checks'
    element :staff_guidance, 'a', text: 'Staff guidance'
    element :old_process_application, 'a', text: 'Process Application - job card old legislation'
    element :new_process_application, 'a', text: 'Process Application - job card new legislation'
    element :old_evidence_checks, 'a', text: 'Evidence checks - job card old legislation'
    element :new_evidence_checks, 'a', text: 'Evidence checks - job card new legislation'
    element :part_payments, 'a', text: 'Part-payments-job card'
    element :fraud_awareness, 'a', text: 'Fraud awareness'
    element :rrds, 'a', text: 'RRDS'
  end
end
