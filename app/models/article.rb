# frozen_string_literal: true
class Article < ActiveRecord::Base
  RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

  before_save :render_markdown, if: :abstract?

  has_many :authorships
  has_many :authors, through: :authorships

  has_many :keywords, through: :keywordables
  has_many :keywordables

  belongs_to :section
  belongs_to :issue
  belongs_to :institution

  def to_param
    "#{id}-#{title.parameterize}"
  end

  private

  def render_markdown
    return unless abstract.present?

    self.abstract_html = RENDERER.render(abstract)
  end
end
