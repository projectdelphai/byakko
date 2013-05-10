class FeedsController < ApplicationController
  
  layout false
  
  def manga
    @manga = Manga.all
  end

  def newchapters
    current_user = User.find_by_api_key(params['api_key'])
    @current_user = current_user.username
    current_user_id = current_user.id
    response = JSON.load(HTTParty.get("http://byakko.heroku.com/users/#{current_user_id}.json?api_key=#{params['api_key']}").body)
    @newchapters = response['manga']
    @current_user = User.find_by_api_key(params['api_key']).username
  end

end
