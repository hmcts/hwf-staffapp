FactoryGirl.define do
  factory :user do
    role            'user'
    email           'user@example.com'
    password        'password'
    
    factory :admin_user do
      role          'admin'
    end
  end

end
