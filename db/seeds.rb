# Idempotent: safe to re-run. Application seeding only runs when there are
# no applications yet, so it never grows unbounded.

JURISDICTIONS = [
  'County', 'Family', 'High', 'Insolvency', 'Magistrates', 'Probate',
  'Employment', 'Gambling', 'Gender recognition',
  'Immigration (first-tier)', 'Immigration (upper)', 'Property'
].freeze

JURISDICTIONS.each { |name| Jurisdiction.find_or_create_by!(name: name) }

OFFICES = [
  { name: 'Digital', entity_code: 'MA105' },
  { name: 'Bristol', entity_code: 'DB402' }
].freeze

county = Jurisdiction.find_by!(name: 'County')

OFFICES.each do |attrs|
  office = Office.find_or_create_by!(name: attrs[:name]) { |o| o.entity_code = attrs[:entity_code] }
  OfficeJurisdiction.find_or_create_by!(office: office, jurisdiction: county)
end

OfficeJurisdiction.all.each_with_index do |oj, index|
  BusinessEntity.find_or_create_by!(office: oj.office, jurisdiction: oj.jurisdiction) do |be|
    be.be_code = oj.office.entity_code
    be.sop_code = format('%05d', index + 1)
    be.name = "#{oj.office.name} - #{oj.jurisdiction.name}"
    be.valid_from = Time.zone.now
  end
end

# Real deployments stop here. Local docker runs (docker-compose.yml sets
# LOCAL_DOCKER) use the production environment but still need login accounts.
if Rails.env.production? && ENV['LOCAL_DOCKER'] != 'true'
  return
end

USERS = [
  { name: 'Admin', email: 'fee-remission@digital.justice.gov.uk',
    password: '1234567890', role: 'admin', office_name: 'Digital' },
  { name: 'Mi', email: 'digital.mi@digital.justice.gov.uk',
    password: '1234567890', role: 'mi', office_name: 'Digital' },
  { name: 'User', email: 'bristol.user@hmcts.gsi.gov.uk',
    password: '9876543210', role: 'user', office_name: 'Bristol' },
  { name: 'Manager', email: 'bristol.manager@hmcts.gsi.gov.uk',
    password: '9876543210', role: 'manager', office_name: 'Bristol' }
].freeze

USERS.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = attrs[:password]
    u.role = attrs[:role]
    u.office = Office.find_by!(name: attrs[:office_name])
  end
end

# Sample applications — one per state with every relation linked.
# Skipped if any applications already exist, so re-running the seed never
# duplicates and never collides with an imported dataset.
# FactoryBot comes from the test gem group, which production bundles
# (including the docker image) do not install, so local docker stops here.
return if Rails.env.production?
return if Application.exists?

require 'factory_bot_rails'
FactoryBot.reload

owner   = User.find_by!(email: 'bristol.user@hmcts.gsi.gov.uk')
office  = Office.find_by!(name: 'Bristol')
entity  = BusinessEntity.find_by!(office: office)

base = { user: owner, completed_by: owner, office: office, business_entity: entity }
jurisdiction = Jurisdiction.find_by!(name: 'County')
# state=0 created — applicant + detail + saving (no EC, no PP)
3000.times do
  FactoryBot.create(:application, :uncompleted, :with_reference, jurisdiction: jurisdiction, **base)
end

# state=1 waiting_for_evidence — EC linked via trait
3000.times do
  FactoryBot.create(:application, :waiting_for_evidence_state, jurisdiction: jurisdiction, **base)
end

# state=2 waiting_for_part_payment — PP linked explicitly
3000.times do
  app = FactoryBot.create(:application, :waiting_for_part_payment_state, jurisdiction: jurisdiction, **base)
  FactoryBot.create(:part_payment, application: app)
end

# state=3 processed (direct decision path, no EC)
3000.times do
  FactoryBot.create(:application, :processed_state, outcome: 'full', jurisdiction: jurisdiction, **base)
end

# state=3 processed (went through evidence check, EC completed)
3000.times do
  app = FactoryBot.create(:application, :processed_state, outcome: 'full', jurisdiction: jurisdiction, **base)
  FactoryBot.create(:evidence_check_full_outcome, :completed, application: app)
end

# state=4 deleted
200.times do
  FactoryBot.create(:application, :deleted_state, outcome: 'full', jurisdiction: jurisdiction, **base)
end
