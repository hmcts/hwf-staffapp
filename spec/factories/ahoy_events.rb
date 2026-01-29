FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    name { 'Button Click' }
    properties do
      {
        'element_type' => 'button',
        'button_text' => 'Submit',
        'page' => 'home'
      }
    end
    time { Time.current }

    trait :with_application do
      application
    end

    trait :with_user do
      user
    end

    trait :with_visit do
      visit factory: [:ahoy_visit]
    end

    trait :button_click do
      name { 'Button Click' }
      properties do
        {
          'element_type' => 'button',
          'button_text' => Faker::Lorem.word,
          'button_id' => Faker::Internet.slug
        }
      end
    end

    trait :radio_selection do
      name { 'Radio Selection' }
      properties do
        {
          'element_type' => 'radio',
          'radio_name' => Faker::Lorem.word,
          'radio_value' => Faker::Lorem.word
        }
      end
    end

    trait :form_submit do
      name { 'Form Submit' }
      properties do
        {
          'element_type' => 'form',
          'form_action' => "/#{Faker::Internet.slug}",
          'form_method' => 'post'
        }
      end
    end
  end

  factory :ahoy_visit, class: 'Ahoy::Visit' do
    visit_token { SecureRandom.uuid }
    visitor_token { SecureRandom.uuid }
    started_at { Time.current }

    trait :with_user do
      user
    end
  end
end
