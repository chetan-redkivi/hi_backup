class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    #session["token"] = request.env["omniauth.auth"].credentials.token
    session[:signed_in_with] = request.env["omniauth.auth"].provider
    session[:fb_img] = request.env["omniauth.auth"].info.image
    process_callback
  end

  def twitter
    session[:screen_name] = request.env["omniauth.auth"].extra.raw_info.screen_name
    session[:signed_in_with] = request.env["omniauth.auth"].provider
		session[:tw_img] = request.env["omniauth.auth"].extra.raw_info.profile_image_url
    process_callback
  end

#changed by Chetan Date 12-07-12 START
  def linkedin
		process_callback
    session[:signed_in_with] = request.env["omniauth.auth"].provider
		session[:lin_img] = request.env["omniauth.auth"].info.image
	  session["linkedin_auth"] = true
  end

  def callback
	  if session[:atoken].nil?
  		authentication = Authentication.find_by_provider_and_user_id('linkedin',session["warden.user.user.key"][1][0])
      authentication.update_attribute('token',params[:oauth_verifier])
      session["oauth_verifier"] = params[:oauth_verifier]
	  end
	  redirect_to "/users/profile_edit"
  end
#changed by Chetan Date 12-07-12 END


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
		authentication = Authentication.find_by_provider_and_user_id(auth.provider,session["warden.user.user.key"][1][0])
 		if authentication.nil? && authentication.blank?
			current_user.register_omniauth(auth)
			current_user.save!
		  flash[:notice] = "Connected to #{auth["provider"]} successfully."
		end
# Added By Chetan 14/07/2012
		if auth.provider == 'linkedin'
		  session["lin_name"] = auth.info.name
      if !request.env["omniauth.auth"].extra.raw_info.publicProfileUrl.nil?
      	session["publicProfileUrl"] = request.env["omniauth.auth"].extra.raw_info.publicProfileUrl
      else
      	session["publicProfileUrl"] = "#"
      end
      client = LinkedIn::Client.new('szojbrb1rmct', '4e9xQcJET33lVvfk')
      request_token =  client.request_token(:oauth_callback=>"http://#{request.host_with_port}/users/callback")
      session[:rtoken] = request_token.token
      session[:rsecret] = request_token.secret
	    redirect_to client.request_token.authorize_url
		else
	    redirect_to users_profile_path
		end
  end
# End

  def process_create_user
    auth = request.env["omniauth.auth"]

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
