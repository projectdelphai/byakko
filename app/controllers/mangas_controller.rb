class MangasController < ApplicationController
  
  include MangasHelper

  def new

  end

  def list
    @manga = Manga.new
    require 'httparty'
    mangaedenmanga = JSON.parse(File.open("app/controllers/edenmangalist.txt", "rb") { |f| f.read })
    @query = params[:title]
    @results=[]
    mangaedenmanga['manga'].each { |x|
      @results.push x if x['t'].downcase.include? params[:title].strip.downcase
    }
    if @results.size == 1
      redirect_to mangas_info_path(manga: @results.first, query: @query)
    else
      nil
    end
  end

  def info
   @manga = Manga.new
   @manga = params['manga']  
   @mangainfo = JSON.parse(HTTParty.get("http://www.mangaeden.com/api/manga/#{@manga['i']}/").body)
   @query = params['query']
   if !current_user.nil? == false
     @current_chapter = 0
   else
     subscription = YAML.load(current_user.subscription)
     subscription.each { |x|
       if x[:title] == @query
  	 @current_chapter = x[:chapter]
       else
  	 nil
       end
     }
   end
   @new_manga_chapters = []
   @mangainfo['chapters'].each { |x|
     @new_manga_chapters.push x if x[0] > @current_chapter.to_i
   }
   @new_manga_chapters.reverse!
  end

  def read
    manga_url = download_manga(params['manga'], params['chapter'])

    if manga_url != nil
      @manga_url = manga_url
      @manga = params['manga']
      @chapter = params['chapter']
    else
      redirect_to :back
    end


  end

  def download
    manga_url = download_manga(params['manga'], params['chapter'])

    if manga_url != nil
      redirect_to manga_url
    else
      redirect_to :back
    end
  end

  def markasread
    parsedsubscription = YAML.load(current_user.subscription)
    parsedsubscription.each { |manga|
      if manga[:title] == params['manga']
	manga[:chapter] = params['chapter']
      else
	nil
      end
    }
    current_user.update_attributes(subscription: parsedsubscription)
    current_user.save!(validate: false)
    sign_in current_user

    redirect_to :back

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
