class Businesses::SearchController < ApplicationController
  def index
  end

  def search
    sets = []
    r = Redis.current
    if params[:twitter]
      key = SecureRandom.hex(10)
      twitter = split_range(params[:twitter])
      r.multi do

        r.zunionstore(key, ['user::twit_rank'])
        r.zremrangebyscore(key, 0, twitter[0]-1)
        r.zremrangebyscore(key, twitter[1]+1, 99999)
      end
      sets << key

    end
    if params[:facebook]
      key = SecureRandom.hex(10)
      facebook = split_range(params[:facebook])
      r.multi do
        r.zunionstore( key, ['user::fb_rank'])
        r.zremrangebyscore(key, 0, facebook[0]-1)
        r.zremrangebyscore(key, facebook[1]+1, 99999)
      end
      sets << key
    end
    result_key = SecureRandom.hex(10)
    Redis.current.zinterstore result_key, sets

    render :json=>{
      :count=>Redis.current.zcard(result_key),
      :users=>User.where(:id => Redis.current.zrevrange(result_key, 0, 100))
    } and return false
    sets << result_key
    render :text => sets and return false
		 sets.each { |s| Redis.current.del s }
  end

  private

  def split_range(str)
    str.split("..").map { |s| s.to_i }
  end
end
