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
      redirect_to mangas_info_path(manga: @results.first['t'], newchapters: -1)
    else
      nil
    end
  end

  def info
   @manga = Manga.new
   mangaedenmanga = JSON.parse(File.open("app/controllers/edenmangalist.txt", "rb") { |f| f.read })
   mangaedenmanga['manga'].each { |x|
     @manga = x if x['a'] == params[:manga]
     @manga = x if x['t'] == params[:manga]
   }
   @mangainfo = JSON.parse(HTTParty.get("http://www.mangaeden.com/api/manga/#{@manga['i']}/").body)
   @new_manga_chapters=[]   
   if params['newchapters'].to_i == 0
     @new_manga_chapters=[]
   elsif params['newchapters'].to_i >= 1
     @new_manga_chapters=[]
     @mangainfo['chapters'][0..(params['newchapters'].to_i-1)].each { |x|
       @new_manga_chapters.push x
     }
     @new_manga_chapters.reverse!
   elsif params['newchapters']
     @mangainfo['chapters'].each { |x|
       @new_manga_chapters.push x
     }
     @new_manga_chapters.reverse!
   end
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
    if signed_in?
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
      
      newchapters = -1
      if params['newchapters'].to_i >= 2
  	newchapters = params['newchapters'].to_i - 1
      elsif params['newchapters'].to_i == 0 or params['newchapters'].to_i == 1
  	newchapters = 0
      end
      
      redirect_to mangas_info_path(manga: params['manga'], newchapters: newchapters)
    else
      redirect_to signin_path
    end
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
