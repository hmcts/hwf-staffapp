RSpec.shared_examples 'resolver service for user, timestamps and decision_type' do |name_of_object|
  it { expect(object.completed_by.name).to eql user.name }
  it { expect(object.completed_at).to eql Time.zone.now }
  it { expect(object.application.decision_type).to eql name_of_object }
end
