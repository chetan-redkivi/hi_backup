# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_profile do
    fullname "MyString"
    email "MyString"
    zipcode 1
    img_url "MyString"
    description "MyString"
  end
end
