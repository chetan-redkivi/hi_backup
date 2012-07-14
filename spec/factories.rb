require 'ffaker'

FactoryGirl.define do
  factory :user do 
    email { Faker::Internet.email }
    password "aaaaaa"
  end
end
