xml.instruct!
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do

  xml.channel do
    xml.title 'Manga'
    xml.description ''
    xml.link root_url
    xml.language 'en'
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => feed_url

    for manga in @manga
      xml.item do
        xml.title "#{manga.title} - #{manga.author}"
        xml.pubDate(manga.created_at.rfc2822)
        xml.description("#{manga.title} was added to database on #{manga.created_at.rfc2822}")
      end
    end

  end

end
