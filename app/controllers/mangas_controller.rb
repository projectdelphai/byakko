class MangasController < ApplicationController

  def new
    @manga = Manga.new
  end

  def list
    require 'httparty'
    mangaedenmanga = JSON.parse(File.open("app/controllers/edenmangalist.txt", "rb") { |f| f.read })
    @query = params[:title]
    @results=[]
    mangaedenmanga['manga'].each { |x|
      @results.push x if x['t'].downcase.include? params[:title].strip.downcase
    }
  end

  def info
   @manga = params['manga']  
   @mangainfo = JSON.parse(HTTParty.get("http://www.mangaeden.com/api/manga/#{@manga['i']}/").body)
   @query = params['query']
  end

  def add
    manga = Manga.find_by_title(params[:manga][0])
    if manga
      nil
    else
      manga = Manga.new
      manga.title = params[:manga][0]
      manga.author = params[:manga][1]
      manga.latestchapter = params[:manga][2]
      manga.save
    end
    sub = YAML.load(current_user.subscription)
    entry = { title: params[:manga][0], chapter: params[:manga][2] }
    sub.push entry
    current_user.update_attributes(subscription: sub)
    current_user.save!(validate: false)
    sign_in current_user
    redirect_to current_user
  end

end
