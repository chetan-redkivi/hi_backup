class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    process_callback
  end

  def twitter
    process_callback
  end


  def linkedin
    client = LinkedIn::Client.new('szojbrb1rmct', '4e9xQcJET33lVvfk')
    request_token = client.request_token(:oauth_callback =>"http://#{request.host_with_port}/users/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to client.request_token.authorize_url
  end
  def callback
    client = LinkedIn::Client.new("szojbrb1rmct", "4e9xQcJET33lVvfk")
    if session[:atoken].nil?
      session[:oauth_verifier] = params[:oauth_verifier]
    end
		redirect_to "/users/profile_edit"
  end




  private

  def process_callback
    if user_signed_in?
      add_authentication
    else
      process_create_user
    end
  end

  def add_authentication
    auth = request.env["omniauth.auth"]
    session["name"] = request.env["omniauth.auth"].extra.raw_info.screen_name
    current_user.register_omniauth(auth)
    current_user.save!

    flash[:notice] = "Connected to #{auth["provider"]} successfully."

    redirect_to users_profile_path
  end

  def process_create_user
    auth = request.env["omniauth.auth"]
    session["name"] = request.env["omniauth.auth"].extra.raw_info.name
    authentication = Authentication.find_by_provider_and_uid(auth['provider'], auth['uid'])

    if authentication.present?
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    else
      user = User.new
      user.apply_omniauth(auth)
      if user.email.blank?
        # we need to ask for more information (twitter)
        Redis.current.set "omniauth_twitter_#{session[:session_id]}", auth.to_json
        @user = User.new

        render 'users/twitter_fillup'
      else
        if user.save(:validate=>false)
          flash[:notice] = "Account created and you have been signed in!"
          sign_in_and_redirect(:user, user)
        else
          flash[:error] = "Error while logging in! #{user.errors.full_messages.join(" and ")}"
          redirect_to root_url
        end
      end
    end
  end



end
