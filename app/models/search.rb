# Article search.
class Search
  attr_accessor :query, :tokens

  def initialize _query
    @query = _query
    @tokens = tokenize @query
  end

  def tokenize query
    query.strip.squish.gsub(/[^\wščćžđŠČĆŽĐ ]*/i, '').downcase.split " "
  end

  def perform
    # Conditions array.
    conditions = []
    # Prepare AREL table.
    articles = Article.arel_table
    articles_table = Article.order(:title, :section_id)

    # Try article title.
    conditions << articles[:title].matches("%#{@tokens.join('%')}%")

    # Extract years.
    years_intersection = @tokens & Issue.select(:year).order(:year).group(:year).map { |i| i.year.to_s }
    if years_intersection.any?
      articles_table = articles_table.joins(:issue)
      conditions << Issue.arel_table[:year].eq(years_intersection.last)

      # Remove year from search tokens now.
      @tokens.delete years_intersection.last
    end

    # Is there anymore tokens? Otherwise let's wrap up.
    if @tokens.any?
      # Extract keywords.
      keywords = Keyword.select(:id).where(keyword: @tokens).map(&:id)
      if keywords.any?
        articles_table = articles_table.joins(:keywordables)
        conditions << Keywordable.arel_table[:keyword_id].in(keywords)
      end

      # Try authors.
      authors = Author.select(:id).where(
        @tokens.map { |t| "first_name LIKE ? OR last_name LIKE ?" }.join(' OR '), 
       *(@tokens.map { |t| ["%#{t}%", "%#{t}%"] } ).flatten 
      ).map(&:id)
      if authors.any?
        articles_table = articles_table.joins(:authorships)
        conditions << Authorship.arel_table[:author_id].in(authors)
      end

      # Try section titles.
      sections = Section.select(:id).where(
        @tokens.map { |t| "name LIKE ?" }.join(' OR '), 
       *@tokens.map { |t| "%#{t}%" }
      ).map(&:id)
      if sections.any?
        conditions << articles[:section_id].in(sections)
      end
    end

    # Build WHERE/OR query.
    where = if conditions.length == 1
      conditions.first
    else
      last = conditions.pop
      conditions.inject(last) { |query_buildup, condition| query_buildup.or condition }
    end

    # Return whole query.
    articles_table.where(where).uniq
  end
end