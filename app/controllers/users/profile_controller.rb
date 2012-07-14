class Users::ProfileController < ApplicationController
  before_filter :authenticate_user!

  def index
    @providers = current_user.authentications.select(:provider).map {|a| a.provider}
  end

  def profile_edit
    @providers = current_user.authentications.select(:provider).map {|a| a.provider}
    if session["linkedin_auth"]
        client = LinkedIn::Client.new("szojbrb1rmct", "4e9xQcJET33lVvfk")
        if session[:atoken].nil?
            if session["oauth_verifire"].nil?
              session["oauth_verifire"] = Authentication.find_by_provider_and_user_id('linkedin',session["warden.user.user.key"][1][0]).token
            end
            pin = session["oauth_verifier"]
            atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
            session[:atoken] = atoken
            session[:asecret] = asecret
        else
            client.authorize_from_access(session[:atoken], session[:asecret])
        end
#       @connections = client.connections
        @recommendations = client.profile(:fields => %w(recommendations-received)).recommendations_received.all
    end
    if current_user.user_profile.blank?
      @user_profile = UserProfile.new
    else
      @user_profile = current_user.user_profile
    end
  end

  def unlink

  end

end
