require 'spec_helper'

describe UserProfile do
  it "Should create new User Profile with all children" do

    user_profile = UserProfile.new(description:"Test profile", email: "Test@test.com", fullname: "Test Test",
                                              img_url: "http://www.google.com", zipcode: 34567, user_id: 1)


    department = Department.find(1)
    position = Position.find(1)
    industry = Industry.find(1)

    user_experience = UserExperience.new
    user_experience.department= department
    user_profile.user_experiences<< user_experience

    user_position = UserPosition.new
    user_position.position= position
    user_profile.user_positions<< user_position

    user_industry = UserIndustry.new
    user_industry.industry= industry
    user_profile.user_industries<< user_industry

    user_profile.save

    user_profile.should_not eq nil
    user_profile.user_experiences.should_not eq nil
    user_profile.user_industries.should_not eq nil
    user_profile.user_positions.should_not eq nil

  end
end
