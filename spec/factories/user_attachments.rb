# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_attachment do
    user_profile_id 1
    attachment "MyString"
  end
end
