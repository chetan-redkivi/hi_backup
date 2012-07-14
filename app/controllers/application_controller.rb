class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_loggedin_user
    if session['current_user_id']
      @current_user = User.find(session['current_user_id'])
    else
      if user_signed_in?
        user_id = session['warden.user.user.key'][1]
        session['current_user_id'] = user_id.first
        @current_user = User.find(user_id.first)
      end
    end
  end
end
