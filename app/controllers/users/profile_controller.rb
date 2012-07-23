class Users::ProfileController < ApplicationController
  before_filter :authenticate_user!

  def index
    @providers = current_user.authentications.select(:provider).map {|a| a.provider}
  end

  def profile_edit
#	  user =  FbGraph::User.me(Authentication.find_by_provider_and_user_id(:facebook,current_user.id).token).fetch.picture
#	  render :text => user.inspect and return false
	  #  render :text => FbGraph::User.me(Authentication.find_by_provider_and_user_id(:facebook,current_user.id).token).picture.inspect and return false
    @providers = current_user.authentications.select(:provider).map {|a| a.provider}
		@departments = Department.all
    @positions = Position.all
    @industries = Industry.all
  #  render :text => current_user.user_profile.img_url.inspect and return false
    if @providers.include?("facebook")
	    session[:fb_img] = FbGraph::User.me(Authentication.find_by_provider_and_user_id(:facebook,current_user.id).token).fetch.picture
	    session[:fb_profile_img] =  session[:fb_img]+"?type=large"
    else
	    session[:fb_img] =""
	    session[:fb_profile_img] = ""
    end
    if @providers.include?("linkedin")
	    authentication = Authentication.find_by_provider_and_user_id(:linkedin,current_user.id)
      client = LinkedIn::Client.new
      client.authorize_from_access(authentication.token,authentication.secret)
      session["linkedin_connections"] = client.connections.total
      @recommendations = client.profile(:fields => %w(recommendations-received)).recommendations_received.all
      @lin_name = authentication.screen_name
    end
    if current_user.user_profile.blank?
      @user_profile = UserProfile.new
    else
      @user_profile = current_user.user_profile
    end
  end

  def update_profile
    is_user_pos_found = true if params[:user_profile][:positions]
    is_user_files_found = true if params[:user_profile][:user_attachments]
    is_user_exp_found = true if params[:user_profile][:user_experiences]
    is_user_ind_found = true if params[:user_profile][:industries]
		is_user_rec_found = true if params["recommendation_ids"]
    is_user_linkedin_connection_count = true if session["linkedin_connections"]
    convert_ids_to_objects(is_user_pos_found,'Position' ,:positions)
    convert_ids_to_objects(is_user_ind_found,'Industry' ,:industries)

		if is_user_linkedin_connection_count
				current_user.linkedin_count.clear
				current_user.update_linkedin(session["linkedin_connections"])
		end
		current_user.linkedin_recommendations.clear
		if is_user_rec_found
			if params["recommendation_ids"].size > 5
				flash[:notice] = "You have Selected More than 5 recommendations"
				render :action => 'update_profile'
			else
				current_user.update_linkedin_recc(params["recommendation_ids"])
			end
		end
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
  	redirect_to "/users/profile_edit"
  end

  def profile_view

   @user_profile = current_user.user_profile
   if @user_profile.user_attachments.blank?
   	@user_documents = @user_profile.user_attachments
   end
   @user_positions = @user_profile.user_positions
   @departments = Department.all
   if !Authentication.find_by_provider_and_user_id(:linkedin,current_user.id).nil?
	   @recommendations = []
	   authentication = Authentication.find_by_provider_and_user_id(:linkedin,current_user.id)
	   client = LinkedIn::Client.new
     client.authorize_from_access(authentication.token,authentication.secret)
     recommendations = client.profile(:fields => %w(recommendations-received)).recommendations_received.all
     recommendations.each do |recommendation|
	     if current_user.linkedin_recommendations.include?(recommendation.id)
		        @recommendations << recommendation
	     end
     end
   end



	  # render :text => @user_profile.user_positions.inspect and return false
  end

  def  unlink
	  case params["provider"]
		  when "facebook"
				current_user.fb_rank.delete(current_user.fb_fol)
				session["fb_name"]= ""
		  when "linkedin"
		  	current_user.linkedin_rank.delete(current_user.linkedin_recc)
	  end
	  authentication = Authentication.find_by_provider_and_user_id(params["provider"],current_user.id)
	  authentication.destroy
		redirect_to "/users/profile_edit"
  end

  def download
  	user_profile = UserProfile.find(params["profile"])
  	user_doc = user_profile.user_attachments.first
		user_doc.attachment.path
  	send_file("#{user_doc.attachment.path}")
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
