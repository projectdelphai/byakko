module ApplicationHelper
  def info(title)
    mangaedenmanga = JSON.parse(File.open("app/controllers/edenmangalist.txt", "rb") { |f| f.read })
    @query = title
    @manga=""
    mangaedenmanga['manga'].each { |x|
      @manga = x if x['t'].downcase == title.strip.downcase
    }
    return @manga
  end

  def title(page_title)
    content_for(:title) { page_title }
  end
end
