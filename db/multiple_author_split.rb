Author.all.each do |author|
  author.last_name.gsub!('dr.', '')

  if author.last_name =~ /, /
    authors = author.last_name.split(', ')
  elsif author.last_name =~ / in /
    authors = author.last_name.split(' in ')
  else
    next
  end

  puts "Working on #{author.id} FN:#{author.first_name} LN:#{author.last_name}"
  puts authors.inspect

  if authors and authors.length > 1
    articles = Article.where(author_id: author.id).to_a.freeze

    authors.each do |new_author|
      new_author_name = new_author.strip.split(' ')
      
      unless new_author_name.length > 1
        puts "Error splitting names. #{author.id} - #{new_author}"
        next
      end

      first_name = new_author_name.pop.strip
      last_name = new_author_name.join(" ").strip

      new_author = Author.find_by first_name: first_name, last_name: last_name
      new_author ||= Author.find_by last_name: first_name, first_name: last_name
      unless new_author
        puts "Can't find Author (#{first_name}, #{last_name}) OLD AUTH ID:#{author.id}."
        new_author = Author.create first_name: first_name, last_name: last_name, institution_id: author.institution_id, education: author.education, title: author.title
        puts "Created new Author: #{new_author}/#{new_author.id}"
      else
        puts "Found Author (#{first_name}, #{last_name}) - #{new_author.id}."
      end

      articles.each do |article|
        begin
          if new_author.authorships.create(article_id: article.id)
            article.author_id = nil
            article.save
          end
        rescue ActiveRecord::StatementInvalid
        end
        puts "Adding article #{article.id} to #{new_author.id} (old:#{author.id})"
        # puts "Adding article #{article.id} (old:#{author.id})"
      end
    end

    author.destroy
  else
    puts author.inspect
    puts authors.inspect
  end
end.map {}.compact