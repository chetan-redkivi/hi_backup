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

http://rtdptech.com/2010/12/importing-gmail-contacts-list-to-rails-application/

http://stackoverflow.com/questions/3903278/ruby-oauth-nightmare-using-contacts-api

https://github.com/cardmagic/contacts/blob/master/examples/grab_contacts.rb
