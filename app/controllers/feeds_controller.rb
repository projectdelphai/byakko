class FeedsController < ApplicationController
  
  layout false
  
  def manga
    @manga = Manga.all
    expires_in 180.minutes
  end

  def newchapters
    @user = User.find_by_api_key(params['api_key'])
    response = JSON.load(HTTParty.get("http://byakko.heroku.com/users/#{@user.id}.json?api_key=#{params['api_key']}").body)
    #response = JSON.load(HTTParty.get("http://localhost:8080/users/#{@user.id}.json?api_key=#{params['api_key']}").body)
    response['manga'].delete_if { |x| x['newchapter'].to_i <= 0 }
    @new_manga = response['manga']
    @new_manga.each { |manga|
      newchapters = []
      1.upto(manga['newchapter'].to_i) { |y|
	newchapters.push manga['currentchapter'].to_i+y
      }
      manga['newchapter'] = newchapters
    }
  end

end
