module MangasHelper
  def check(title)
    YAML.load(current_user.subscription).each { |x| return true if x.has_value? title }
    false
  end

  def download_manga(manga,chapter)
    require "google_drive"
    session = GoogleDrive.login("byakkomanga@gmail.com", ENV['DRIVE_PASSWORD'])

    for file in session.files
      if file.title == "#{params['manga']}-#{params['chapter']}.cbz"
	manga_info = JSON.parse(HTTParty.get("https://www.googleapis.com/drive/v2/files/#{file.resource_id.gsub('file:', '')}?key=AIzaSyBSp1WWKUNTDd2DYBd9DwmxDBGshSWd5qM").body)
	@manga_url = manga_info['webContentLink']
      end
    end
    return @manga_url
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
end
