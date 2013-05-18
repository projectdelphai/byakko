module MangasHelper
  def check(title)
    if current_user.subscription == nil
      return false
    else
      YAML.load(current_user.subscription).each { |x| return true if x.has_value? title }
    end
    false
  end

  def download_manga(manga,chapter)
    manga = Manga.find_by_title(manga) 
    chapter_urls = YAML.load(manga.chapter_urls)
    @manga_url = chapter_urls[chapter]
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
