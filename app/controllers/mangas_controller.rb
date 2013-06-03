class MangasController < ApplicationController
  before_filter :api_key_login
  after_filter :api_key_logout
  include MangasHelper

  def new

  end

  def list
    @manga = Manga.new
    mangaedenmanga = JSON.parse(File.open("app/controllers/edenmangalist.txt", "rb") { |f| f.read })
    @query = params[:title]
    @results=[]
    mangaedenmanga['manga'].each { |x|
      @results.push x if x['t'].downcase.include? params[:title].strip.downcase
    }
    redirect_to mangas_info_path(manga: @results.first['t'], newchapters: -1) if @results.size == 1
  end

  def info
    manga = Manga.new
    @manga = manga.basic_info(params[:manga])
    @mangainfo = manga.more_info(@manga['i'])
    @new_manga_chapters = manga.new_manga_chapters(@mangainfo['chapters'],params['newchapters'])
    respond_to do |format|
      format.html
      format.json { 
      render json: { "mangainfo" => @mangainfo.reject { |x| x == "chapters" } }
      }
    end
  end

  def read
    @page = params["page"].to_i if params["page"]
    manga_url = get_manga_url(params['manga'], params['chapter'])
    download_manga("#{@manga}-#{@chapter}")
    @images = `ls "public/#{@dirname}" | grep jpg`.split(/\n/)
  end

  def download
    manga_url = get_manga_url(params['manga'], params['chapter'])
    redirect_to manga_url
  end

  def markasread
    if signed_in?
      new_subscription = current_user.json_subscription.each { |manga| manga[:chapter] = params['chapter'] if manga[:title] == params['manga'] }
      update_subscription(current_user, new_subscription)

      if params['newchapters']
  	new_chapters = get_new_number_of_new_chapters(params['newchapters'].to_i)
	redirect_to mangas_info_path(manga: params['manga'], newchapters: new_chapters)
      else
  	redirect_to current_user
      end
    else
      redirect_to signin_path
    end
  end

  def add
    manga = Manga.find_by_title(params[:manga][0])
    if !manga
      manga = Manga.new( :title => params[:manga][0], :author => params[:manga][1], :latestchapter => params[:manga][2] )
      manga.save
    end
    !current_user.subscription ? sub=[] : sub=current_user.json_subscription
    entry = { title: params[:manga][0], chapter: params[:manga][2] }
    sub.push entry
    update_subscription(current_user, sub)
    redirect_to current_user
  end

  def remove
    sub = current_user.json_subscription
    sub.delete_if { |x| x[:title] == params['manga'] }
    update_subscription(current_user, sub)
    redirect_to current_user
  end

  private

  def update_subscription(user, subscription)
    current_user.update_attributes(subscription: subscription)
    current_user.save!(validate: false)
    sign_in current_user
  end

  def get_new_number_of_new_chapters(new_chapters)
    if new_chapters >= 2
      new_chapters -= 1
    else
      new_chapters = 0
    end
    return new_chapters
  end

  def download_manga(chapter_name)
    if !dir_exists?(chapter_name)
      dir = Dir.mktmpdir(chapter_name, "public")
      open("#{dir}/#{filename}", "wb") { |file| file << open("#{manga_url}").read }
      unzip_file("#{dir}/#{chapter_name}.zip", "#{dir}")
      dir_exists?("#{@manga}-#{@chapter}")
    end
  end

  def dir_exists?(directory)
    Dir.foreach("public/") do |dir|
      if dir.match(/#{directory}/)
	@dirname = dir
	return true
      end
    end
    false
  end

  def unzip_file (file, destination)
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each { |f|
   	f_path=File.join(destination, f.name)
   	FileUtils.mkdir_p(File.dirname(f_path))
   	zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
  end

  def get_manga_url(manga,chapter)
    chapter_urls = Manga.find_by_title(manga).json_chapter_urls
    if chapter_urls[chapter]
      @manga = params['manga']
      @chapter = params['chapter']
    else
      flash[:failed] = "No stored manga within Byakko"
      redirecto_to :back
    end
    return chapter_urls[chapter]
  end

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

class Manga
  def new_manga_chapters(raw_chapters,number_of_new_chapters)
    @new_manga_chapters=[]   
    if number_of_new_chapters.to_i >= 1
      raw_chapters[0..number_of_new_chapters.to_i-1].each { |x| @new_manga_chapters.push x }
      @new_manga_chapters.reverse!
    elsif !number_of_new_chapters or number_of_new_chapters.to_i < 0
      raw_chapters.each { |x| @new_manga_chapters.push x }
      @new_manga_chapters.reverse!
    end
    return @new_manga_chapters
  end

  def more_info(manga_id)
    JSON.parse(HTTParty.get("http://www.mangaeden.com/api/manga/#{manga_id}/").body)
  end

  def basic_info(manga)
    mangaeden_manga_list = JSON.parse(File.open("app/controllers/edenmangalist.txt", "rb") { |f| f.read })
    mangaeden_manga_list['manga'].each { |x|
      @manga = x if x['a'] == manga
      @manga = x if x['t'] == manga
    }
    return @manga
  end
end
