class Users::ProfileController < ApplicationController
  before_filter :authenticate_user!

  def index
    @providers = current_user.authentications.select(:provider).map {|a| a.provider}
  end

  def profile_edit
  	@user =  User.find(1)
		@providers = current_user.authentications.select(:provider).map {|a| a.provider}
		if session["fb_img"].nil?
		 session["fb_img"] = FbGraph::User.me(Authentication.find_by_provider(:facebook).token).fetch.picture
		end
		if session["linkedin_auth"]
			client = LinkedIn::Client.new("szojbrb1rmct", "4e9xQcJET33lVvfk")
			if session[:atoken].nil?
				if session["oauth_verifier"].nil?
          session["oauth_verifier"] = Authentication.find_by_provider_and_user_id('linkedin',session["warden.user.user.key"][1][0]).token
				end
				pin = session["oauth_verifier"]
				atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
				session[:atoken] = atoken
				session[:asecret] = asecret
			else
				client.authorize_from_access(session[:atoken], session[:asecret])
			end
			@recommendations = client.profile(:fields => %w(recommendations-received)).recommendations_received.all
		end

    if current_user.user_profile.blank?
      @user_profile = UserProfile.new
    else
      @user_profile = current_user.user_profile
    end
  end

  def update_profile
   # render :text => params["reccomendation_ids"].inspect and return false
    is_user_pos_found = true if params[:user_profile][:positions]
    is_user_files_found = true if params[:user_profile][:user_attachments]
    is_user_exp_found = true if params[:user_profile][:user_experiences]
    is_user_ind_found = true if params[:user_profile][:industries]
		is_user_rec_found = true if params["reccomendation_ids"]
    convert_ids_to_objects(is_user_pos_found,'Position' ,:positions)
    convert_ids_to_objects(is_user_ind_found,'Industry' ,:industries)

		if is_user_rec_found && !params["reccomendation_ids"].blank?
			current_user.linkedin_recc << [1,2,3,4,5,6].join(',')
		end
		render :text => current_user.linkedin_recc and return false
    if is_user_exp_found
      user_exp_hash = params[:user_profile][:user_experiences]
      unless user_exp_hash.nil? && user_exp_hash.empty?
        user_exp_arr = user_exp_hash.collect do |key,val|
            UserExperience.new(department: Department.find(key), exp_in_yrs: val.to_i )
          end
        params[:user_profile].delete :user_experiences
        params[:user_profile][:user_experiences] = user_exp_arr
      end
    end

    if is_user_files_found
      user_files =  params[:user_profile][:user_attachments]
      user_attachments = user_files.collect do |f|
        UserAttachment.new(attachment: f)
      end
      params[:user_profile].delete :user_attachments
      params[:user_profile][:user_attachments] = user_attachments
    end

    ## Get params for has_many relationship for user_profile
    @user_profile = nil
    if current_user.user_profile.blank?
      @user_profile = UserProfile.new(params[:user_profile])
      @user_profile.user = current_user
    else
      @user_profile = current_user.user_profile
      @user_profile.update_attributes(params[:user_profile])
    end
    current_loggedin_user.user_profile= @user_profile
    current_loggedin_user.save
  end

  private

  # Added by: Parth Barot
  #
  # Converts array of object IDs to real objects, and put in the params hash for easy nested model structure building.
  #

  def convert_ids_to_objects(is_ids_found=false,constant_name,hash_var_name)
    if is_ids_found
      ids_int_arr = params[:user_profile][hash_var_name].collect{ |id| id.to_i}
      unless ids_int_arr.nil? && ids_int_arr.empty?
        objects = Kernel.const_get(constant_name).send(:find, ids_int_arr)
        params[:user_profile].delete hash_var_name
        params[:user_profile][hash_var_name] = objects
      end
    end
  end
end
