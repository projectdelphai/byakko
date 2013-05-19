class MangasController < ApplicationController
  before_filter :api_key_login
  after_filter :api_key_logout
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
   respond_to do |format|
     format.html
     format.json { 
       if @new_manga_chapters.size != 0
	 newchapters =[]
	 @new_manga_chapters.each { |x|
  	   newchapters.push x[0], "http://www.mangaeden.com/en-manga/#{@mangainfo['alias']}/#{x[0]}/1"
	 }
       else
	 newchapters = nil
       end
       render json: { "mangainfo" => @mangainfo.reject { |x| x == "chapters" }, "newchapters" => newchapters }
     }
   end
  end

  def read
    if params["page"]
      @page = params["page"].to_i
    end
    manga_url = download_manga(params['manga'], params['chapter'])

    if manga_url != nil
      @manga_url = manga_url
      @manga = params['manga']
      @chapter = params['chapter']
    else
      redirect_to :back
    end

    require 'open-uri' 
    require 'zip/zip'
    filename = "#{@manga}-#{@chapter}.zip"
    Dir.foreach("public/") do |dir|
      if dir.match(/#{@manga}-#{@chapter}/)
	@dirname = dir
	@test = "true"
      end
    end
    unless @test == "true" 
      @dir = Dir.mktmpdir("#{@manga}-#{@chapter}", "public")
      open("#{@dir}/#{filename}", "wb") do |file| 
  	file << open("#{@manga_url}").read 
      end
      unzip_file("#{@dir}/#{filename}", "#{@dir}")
    end
    Dir.foreach("public/") do |dir|
      if dir.match(/#{@manga}-#{@chapter}/)
	@dirname = dir
	@test = "true"
      end
    end
    @images = `ls "public/#{@dirname}" | grep jpg`.split(/\n/)
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
    if current_user.subscription == nil
      sub=[]
      entry = { title: params[:manga][0], chapter: params[:manga][2] }
      sub.push entry
    else
      sub = YAML.load(current_user.subscription)
      entry = { title: params[:manga][0], chapter: params[:manga][2] }
      sub.push entry
    end
    current_user.update_attributes(subscription: sub)
    current_user.save!(validate: false)
    sign_in current_user
    redirect_to current_user
  end

  def remove
    sub = YAML.load(current_user.subscription)
    sub.delete_if { |x| x[:title] == params['manga'] }
    current_user.update_attributes(subscription: sub)
    current_user.save!(validate: false)
    sign_in current_user
    redirect_to current_user
  end

  private

  def api_key_login
    if params['api_key']
      sign_in(User.find_by_api_key(params['api_key']))
    end
  end

  def api_key_logout
    if params['api_key']
      sign_out
    end
  end
end
