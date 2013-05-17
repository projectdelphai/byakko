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
    #response = JSON.load(HTTParty.get("http://localhost:8080/users/#{current_user_id}.json?api_key=#{params['api_key']}").body)
    response['manga'].delete_if { |x|
      x['newchapters'].to_i <= 0
    }
    @newmanga = response['manga']
    @newmanga.each { |x|
      newchapters = []
      1.upto(x['newchapters'].to_i) { |y|
	newchapters.push x['currentchapter'].to_i+y
      }
      x['newchapters'] = newchapters
    }
    @current_user = User.find_by_api_key(params['api_key']).username
  end

end
