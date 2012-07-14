class Users::ProfileController < ApplicationController
  before_filter :authenticate_user!

  def index
    @providers = current_user.authentications.select(:provider).map {|a| a.provider}
  end

  def profile_edit
    client = LinkedIn::Client.new("szojbrb1rmct", "4e9xQcJET33lVvfk")
    if !session[:oauth_verifier].nil?
      if session[:atoken].nil?
        session[:oauth_verifier]
        pin = session[:oauth_verifier]
        atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
        session[:atoken] = atoken
        session[:asecret] = asecret
      else
        client.authorize_from_access(session[:atoken], session[:asecret])
      end
      @profile = client.profile(:fields => %w(recommendations-received))
      @connections = client.connections
      @recommendations = @profile.recommendations_received.all
    end
    if current_user.user_profile.blank?
      @user_profile = UserProfile.new
    else
      @user_profile = current_user.user_profile
    end
  end
end
