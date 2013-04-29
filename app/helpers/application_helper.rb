module ApplicationHelper
  def info(title)
    require 'httparty'
    mangaedenmanga = JSON.parse(File.open("app/controllers/edenmangalist.txt", "rb") { |f| f.read })
    @query = title
    @manga=""
    mangaedenmanga['manga'].each { |x|
      @manga = x if x['t'].downcase == title.strip.downcase
    }
    return @manga
  end
end
