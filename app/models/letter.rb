class Letter < ActiveRecord::Base
  RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

  before_save :render_markdown

  def to_s
    title
  end

  private

  def render_markdown
    return unless body.present?

    self.body_html = RENDERER.render(body)
  end
end
