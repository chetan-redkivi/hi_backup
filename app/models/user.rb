class User < ActiveRecord::Base
  include Redis::Objects
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  has_many :authentications, :dependent=>:delete_all
  has_one :user_profile, :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  value :twit_fol

  value :fb_fol

  value :klout_sc

  value :peerindex_count

  value :kred_sc

  value :linkedin_count

  sorted_set :twit_rank, :global => true
  sorted_set :fb_rank, :global => true
  sorted_set :klout_rank, :global => true
  sorted_set :peerindex_rank, :global => true
  sorted_set :kred_rank, :global => true
  sorted_set :linkedin_rank, :global => true

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

  def kred_score=(val)
    self.kred_sc = val
    self.kred_rank[self.id] = val
  end
  def kred_score
    self.kred_sc.value
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
  def linkedin_score
    self.linkedin_count.value
  end

  def apply_omniauth(auth)
    self.email = auth['extra']['raw_info']['email'] if auth['extra']['raw_info']['email']
    self.password = Devise.friendly_token[0,20]
    authentications.build(:provider=>auth['provider'], :uid=>auth['uid'], :token=>auth['credentials']['token'], :secret=>auth['credentials']['secret'])
  end

  def register_omniauth(auth)
    authentications.build(:provider=>auth['provider'], :uid=>auth['uid'], :token=>auth['credentials']['token'], :secret=>auth['credentials']['secret'])
  end

  def update_twitter
    auth = self.authentications.find_by_provider(:twitter)
    puts auth
    if auth
      t = Twitter.new(oauth_token: auth.token, oauth_token_secret: auth.secret)
      self.twitter_followers = t.user.followers
    end
  end

  def update_facebook
    auth = self.authentications.find_by_provider(:facebook)
    if auth
      f = FbGraph::User.me(auth.token)
      me = f.fetch
      self.facebook_followers = f.friends.count
    end
  end

  def update_linkedin
    # TODO: write similar code as above, to persist data in REDIS
  end

  def update_peerindex

  	#Authentication.find_by_user_id()
		#http://api.peerindex.net/v2/profile/show.json?id=simoncast&api_key=617522e8644572b4fe0c9d79ef74b4f2
    # TODO: write similar code as above, to persist data in REDIS
  end

  def update_kred
    # TODO: write similar code as above, to persist data in REDIS
  end

end
