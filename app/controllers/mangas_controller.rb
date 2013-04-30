class MangasController < ApplicationController

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

  def download
    require 'httparty'
    require 'zip/zip'
    @manga = params['manga']
    @chapter = params['chapter']
    @mangachapter = params['mangachapter']
    @response = JSON.parse(HTTParty.get("http://www.mangaeden.com/api/chapter/#{@mangachapter[3]}/").body)
    Dir.mktmpdir("#{@manga['a']}_#{@chapter}", Rails.root) { |dir|
      bt = Time.now
      @response['images'].reverse.each { |x|
	y = sprintf '%02d', x[0].to_i
	File.open("#{dir}/#{@manga['t']}_#{y}.jpg", "wb") do |i|
	  begin
  	    i << HTTParty.get("http://cdn.mangaeden.com/mangasimg/#{x[1]}")
	  rescue
	    retry
	  end
	end
      }
      images=`ls #{dir}`.split(/\n/)
      Zip::ZipFile.open("public/manga/#{@manga['a']} #{@chapter}.cbz", Zip::ZipFile::CREATE) do |zipfile|
	images.each_with_index { |image,index|
	  y = sprintf '%02d', index.to_i
	  zipfile.add("#{@manga['a']} #{@chapter} #{y}.jpg", "#{dir}/#{image}")
	}
      end
      send_file "public/manga/#{@manga['a']} #{@chapter}.cbz"
      et = Time.now
      puts "Time elapsed: #{(et-bt)} seconds"
    }
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
