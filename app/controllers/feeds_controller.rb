class FeedsController < ApplicationController
  
  layout false
  
  def manga
    @manga = Manga.all
  end

  def newchapters
    response = JSON.load(HTTParty.get("http://localhost:8080/users/2.json?api_key=#{params['api_key']}").body)
    @newchapters = response['manga']
    @current_user = User.find_by_api_key(params['api_key']).username
  end

end
