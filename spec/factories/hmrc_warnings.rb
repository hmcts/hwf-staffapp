FactoryBot.define do
  factory :hmrc_warning do
    check_state { "default_checker" }
  end
end
