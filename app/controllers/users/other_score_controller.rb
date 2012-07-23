class Users::OtherScoreController < ApplicationController
  require 'net/http'
  require 'rubygems'
  require 'json'
  require 'klout'

  def klout_score
    Klout.api_key = "9wvktmm43dsc7rmatmhwhksh"
    #auth = Authentication.find_by_provider_and_user_id('twitter',session["warden.user.user.key"][1][0])
    klout_id = Klout::Identity.find_by_screen_name(session[:screen_name])
    user = Klout::User.new(klout_id.id)
    session["klout_score"] = user.score.score.round

    redirect_to "/users/profile_edit"
  end

  def kred_score
    auth = Authentication.find_by_provider_and_user_id('twitter',session["warden.user.user.key"][1][0])
    if auth
      data = Net::HTTP.get(URI.parse("http://api.kred.com/kredscore?term=#{session[:screen_name]}&source=twitter&app_id=eb3f5999&app_key=2b586daaa270a5f91b9513ba538b7090"))
      result = JSON.parse(data)
		  session["kred_influence"] = result["data"][0]["influence"]
		  session["kred_outreach"] = result["data"][0]["outreach"]
		  redirect_to "/users/profile_edit"
    end
  end

  def peerindex
    auth = Authentication.find_by_provider_and_user_id('twitter',session["warden.user.user.key"][1][0])

    if auth
      data = Net::HTTP.get(URI.parse("http://api.peerindex.net/v2/profile/profile.json?id=#{auth.uid}&api_key=617522e8644572b4fe0c9d79ef74b4f2&identity=twitter_id"))
      result = JSON.parse(data)
      session["peerindex"]  = result["peerindex"]
      session["peerindex_url"] = result["url"]
      session["activity"] = result["activity"]
      session["audience"] = result["audience"]
      session["authority"] = result["authority"]
    end
    redirect_to "/users/profile_edit"
  end

end
