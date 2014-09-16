module ApplicationHelper
  def title _title, dont_display_heading = false
    @page_title = _title
    unless dont_display_heading
      content_tag :h1, _title
    end
  end

  def menu_item _title, url, section
    klass = controller_name == section.to_s ? "current" : nil
    content_tag :li, link_to(_title, url), :class => klass
  end

  def format_field record, field, path_prefix = nil
    data = record.send field
    return unless data

    field = field.to_s

    # Belongs to relations.
    if field =~ /_id/ and record.respond_to?(field.gsub('_id', ''))
      data = record.send field.gsub('_id', '')
      return link_to data, polymorphic_url([path_prefix, data])
    end

    # Has many relations.
    if field =~ /s$/ and record.send(field).respond_to?(:all)
      return record.send(field).map { |r| link_to r, polymorphic_url([path_prefix, r]) }.join(', ').html_safe
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

  def generate_table(collection, columns = nil, crud_fields = [:show, :edit, :destroy], path_prefix = nil)
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
          haml_tag :th
        end
      end
      haml_tag :tbody do
        collection.each do |record|
          haml_tag :tr do
            columns.each do |column|
              haml_tag :td, format_field(record, column, path_prefix)
            end
            haml_tag :td, :class => :admin do
              if crud_fields and crud_fields.include?(:destroy)
                concat link_to "Odstrani", polymorphic_url([path_prefix, record]), method: :delete, confirm: 'Ste prepričani?'
              end
              if crud_fields and crud_fields.include?(:edit)
                concat link_to "Uredi", polymorphic_url([path_prefix, record], action: :edit)
              end
              if crud_fields and crud_fields.include?(:show)
                concat link_to "Odpri", polymorphic_url([path_prefix, record])
              end
            end
          end
        end
      end
    end
  end

  def generate_fields(resource, columns = nil, path_prefix = nil)
    klass = resource.class
    columns ||= klass.column_names if klass

    content_tag :dl, :class => klass.to_s do
      columns.each do |column|
        next unless format_field(resource, column, path_prefix).present?
        concat content_tag :dt, klass.human_attribute_name(column)
        concat content_tag :dd, format_field(resource, column, path_prefix)
      end
    end
  end

  def admin_section(klass=nil, &block)
    if signed_in?
      content_tag(:div, capture(&block), :class => 'admin')
    end
  end

end
