# frozen_string_literal: true
Article.all.each do |article|
  keywords = article.read_attribute(:keywords).split(',')
  next unless keywords && keywords.any?
  keywords.each do |keyword|
    keyword = keyword.strip.downcase
    begin
      new_keyword = Keyword.find_or_create_by keyword: keyword
      article.keywords << new_keyword
      print '*'
    rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
      print 'ERROR'
    end
  end
end
