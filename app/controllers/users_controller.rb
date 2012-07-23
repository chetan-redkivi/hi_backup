class UsersController < ApplicationController
  def twitter_fillup
    user = User.new(params[:user])
    auth = JSON.parse(Redis.current.get("omniauth_twitter_#{session[:session_id]}"))
    Rails.logger.info("auth is #{auth}")
    user.apply_omniauth(auth)
    if user.save(:validate=>false)
      authentication = Authentication.find_by_uid_and_user_id(auth["uid"],user.id)
      authentication.update_attribute('screen_name',auth["info"]["nickname"])
      flash[:notice] = "Account created and you have been signed in!"
      sign_in_and_redirect(:user, user)
    else
      flash[:error] = "Error while logging in! #{user.errors.full_messages.join(" and ")}"
      redirect_to root_url
    end

  end
end
