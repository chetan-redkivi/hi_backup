class User < ActiveRecord::Base
  include Redis::Objects
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  require 'net/http'
  require 'rubygems'
  require 'json'
  require 'klout'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  has_many :authentications, :dependent=>:delete_all
  has_one :user_profile, :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  after_update :update_twitter, :update_facebook, :update_peerindex, :update_klout,:update_kred
  after_create :update_twitter, :update_facebook, :update_peerindex, :update_klout,:update_kred

  value :twit_fol

  value :fb_fol

  value :klout_sc

  value :peerindex_count

  value :kred_sc

  value :linkedin_count

  set :linkedin_recc

  sorted_set :twit_rank, :global => true
  sorted_set :fb_rank, :global => true
  sorted_set :klout_rank, :global => true
  sorted_set :peerindex_rank, :global => true
  sorted_set :kred_inf, :global => true
  sorted_set :kred_or, :global => true
  sorted_set :linkedin_rank, :global => true
  set :linkedin_recommendations, :global => true



  def twitter_followers=(val)
    self.twit_fol = val
    self.twit_rank[self.id] = val
  end
  def twitter_followers
    self.twit_fol.value
  end
  def facebook_followers=(val)
    self.fb_fol = val
    self.fb_rank[self.id] = val
  end
  def facebook_followers
    self.fb_fol.value
  end
  def klout_score=(val)
    self.klout_sc = val
    self.klout_rank[self.id] = val
  end
  def klout_score
    self.klout_sc.value
  end

  def kred_influence=(val)
    self.kred_inf = val
    self.kred_inf[self.id] = val
  end
  def kred_influence
    self.kred_inf.value
  end

  def kred_outreach
    self.kred_or.value
  end

  def kred_outreach=(val)
    self.kred_or = val
    self.kred_or[self.id] = val
  end


  def peerindex_score=(val)
    self.peerindex_count = val
    self.peerindex_rank[self.id] = val
  end
  def peerindex_score
    self.peerindex_count.value
  end

  def linkedin_score=(val)
    self.linkedin_count = val
    self.linkedin_rank[self.id] = val
  end
#  def linkedin_score
#    self.linkedin_count.value
#  end

  def linkedin_reccomendation=(val)
		self.linkedin_recc.clear
		self.linkedin_recommendations.clear
		val.each do |rec_id|
			self.linkedin_recc << rec_id
	    self.linkedin_recommendations << rec_id
		end
  end

#  def linkedin_reccomendation
#    self.linkedin_recc.members
#  end

  def apply_omniauth(auth)
    self.email = auth['extra']['raw_info']['email'] if auth['extra']['raw_info']['email']
    self.password = Devise.friendly_token[0,20]
    authentications.build(:provider=>auth['provider'], :uid=>auth['uid'], :token=>auth['credentials']['token'], :secret=>auth['credentials']['secret'])
  end

  def register_omniauth(auth)
    authentications.build(:provider=>auth['provider'], :uid=>auth['uid'], :token=>auth['credentials']['token'], :secret=>auth['credentials']['secret'])
  end

  def update_twitter
    auth = self.authentications.find_by_provider_and_user_id(:twitter,self.id)
    if auth
      t = Twitter::Client.new(oauth_token: auth.token, oauth_token_secret: auth.secret)
     # self.twitter_followers = t.user.follower_count
    end
  end

  def update_facebook
    auth = self.authentications.find_by_provider(:facebook)
    if auth
      f = FbGraph::User.me(auth.token)
      self.facebook_followers = f.friends.count
    end
  end

  def update_linkedin(connection_count)
		self.linkedin_score = connection_count
  end

	def update_linkedin_recc(recc_ids)
		self.linkedin_reccomendation = recc_ids
	end

  def update_peerindex
  	auth = self.authentications.find_by_provider(:twitter)
    if auth
      data = Net::HTTP.get(URI.parse("http://api.peerindex.net/v2/profile/profile.json?id=#{auth.uid}&api_key=617522e8644572b4fe0c9d79ef74b4f2&identity=twitter_id"))
      result = JSON.parse(data)
      self.peerindex_score = result["peerindex"]
    end
  end

  def update_kred
    auth = self.authentications.find_by_provider(:twitter)
    if auth
      data = Net::HTTP.get(URI.parse("http://api.kred.com/kredscore?term=#{auth.screen_name}&source=twitter&app_id=eb3f5999&app_key=2b586daaa270a5f91b9513ba538b7090"))
      result = JSON.parse(data)
     # self.kred_influence = result["data"][0]["influence"]
    end
  end

  def update_klout
    Klout.api_key = "9wvktmm43dsc7rmatmhwhksh"
    auth = self.authentications.find_by_provider(:twitter)
		if auth
		  klout_id = Klout::Identity.find_by_screen_name(auth.screen_name)
		  user = Klout::User.new(klout_id.id).score
		  self.klout_score =  user.score.round
		end
 end

end
