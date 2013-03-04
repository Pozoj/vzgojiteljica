module ApplicationHelper
  def title _title, dont_display_heading = false
    @page_title = _title
    unless dont_display_heading
      content_tag :h1, _title
    end
  end

  def format_field record, field
    data = record.send field
    return unless data

    field = field.to_s

    # Relations.
    if field =~ /_id/
      data = record.send field.gsub('_id', '')
      return link_to data, polymorphic_url(data)
    end

    # Paperclip files.
    if data.respond_to?(:url) and record.send("#{field}_content_type")
      if record.send("#{field}_content_type") =~ /image/
        return image_tag(data.url(:medium))
      else
        return link_to record.send("#{field}_file_name"), data.url
      end
    end

    # Dates
    if field =~ /_at/
      return l data, format: :simple
    end

    data
  end

  def generate_table(collection, columns = nil, crud_fields = [:show, :edit, :destroy])
    klass = if collection.klass and collection.klass.column_names
      collection.klass
    elsif collection.first and collection.first.class and collection.first.class.column_names
      collection.first.class
    end

    columns ||= klass.column_names if klass

    haml_tag :table do
      haml_tag :thead do
        haml_tag :tr do
          columns.each do |column|
            # Localize if possible.
            column = klass.human_attribute_name(column) if klass
            haml_tag :th, column.to_s
          end
        end
      end
      haml_tag :tbody do
        collection.each do |record|
          haml_tag :tr do
            columns.each do |column|
              haml_tag :td, format_field(record, column)
            end
            haml_tag :td, :class => :crud do
              if crud_fields and crud_fields.include?(:show)
                concat link_to "Odpri", polymorphic_url(record)
              end
              if crud_fields and crud_fields.include?(:edit)
                concat link_to "Uredi", polymorphic_url(record, action: :edit)
              end
              if crud_fields and crud_fields.include?(:destroy)
                concat link_to "Odstrani", polymorphic_url(record), method: :delete, confirm: 'Ste prepričani?'
              end
            end
          end
        end
      end
    end
  end

  def admin_section(klass=nil, &block)
    if signed_in?
      content_tag(:div, capture(&block), :class => 'admin')
    end
  end

end
