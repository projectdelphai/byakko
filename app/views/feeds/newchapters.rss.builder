xml.instruct!
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do

  xml.channel do
    xml.title "New Chapters for #{current_user.username}"
    xml.description "RSS feed of new chapters for #{current_user.username}'s subscribed manga"
    xml.link root_url
    xml.language 'en'
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => feed_url

    for chapter in @new_manga
      xml.item do
	xml.title "#{chapter['title']} - Chapters: #{chapter['newchapter']}"
	xml.link "http://byakko.herokuapp.com/mangas/info?manga=#{chapter['title'].gsub(' ', '+')}&newchapters=#{chapter['newchapter'].size}"
      end
    end

  end

end
