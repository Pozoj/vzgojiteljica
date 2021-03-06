# frozen_string_literal: true
class Author < ActiveRecord::Base
  extend DuplicateFinder

  has_many :authorships
  has_many :articles, through: :authorships
  belongs_to :post
  belongs_to :subscriber, foreign_key: :entity_id

  default_scope { order('last_name, first_name') }

  validates_presence_of :last_name

  def unique_name
    uniq_name = "#{last_name}, #{first_name}"
    uniq_name
  end

  def name
    "#{first_name.strip} #{last_name.strip}"
  end

  def to_s
    name
  end

  def institution_for_article(article)
    authorships.find_by(article_id: article.id).try(:institution)
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
