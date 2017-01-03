# frozen_string_literal: true
module ApplicationHelper
  def title(_title, dont_display_heading = false)
    @page_title = _title
    content_tag :h1, _title unless dont_display_heading
  end

  def conditional_filtering_link(text, options = {})
    param = options[:param]

    active = if options[:default]
               !params.find { |k, _v| k =~ /filter/ }
             elsif options[:param_value]
               params[param].to_s == options[:param_value].to_s
             else
               !!params[param]
             end

    if active
      content_tag :span, text
    else
      if options[:default]
        url = options[:route]
      else
        url = {}
        url[param] = options[:param_value] || true
      end

      link_to text, url
    end
  end

  def menu_item(_title, url, section)
    klass = controller_name == section.to_s ? 'current' : nil
    content_tag :li, link_to(_title, url), class: klass
  end

  def format_field(record, field, path_prefix = nil)
    data = record.send field
    return unless data

    field = field.to_s

    # Belongs to relations.
    if field =~ /_id/ && record.respond_to?(field.gsub('_id', ''))
      data = record.send field.gsub('_id', '')
      return link_to data, polymorphic_url([path_prefix, data])
    end

    # Has many relations.
    if field =~ /s$/ && record.send(field).respond_to?(:all)
      return record.send(field).map { |r| link_to r, polymorphic_url([path_prefix, r]) }.join(', ').html_safe
    end

    # Paperclip files.
    if data.respond_to?(:url) && record.send("#{field}_content_type")
      if record.send("#{field}_content_type") =~ /image/
        return image_tag(data.url(:medium))
      else
        return link_to record.send("#{field}_file_name"), data.url
      end
    end

    # Dates
    return l data, format: :simple if field =~ /_at/

    data
  end

  def generate_table(collection, columns = nil, crud_fields = [:show, :edit, :destroy], path_prefix = nil)
    klass = if collection.klass && collection.klass.column_names
              collection.klass
            elsif collection.first && collection.first.class && collection.first.class.column_names
              collection.first.class
    end

    columns ||= klass.column_names if klass

    haml_tag :table, class: 'table' do
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
            haml_tag :td, class: :admin do
              if crud_fields && crud_fields.include?(:destroy)
                concat link_to 'Odstrani', polymorphic_url([path_prefix, record]), method: :delete, 'data-confirm' => 'Ste prepričani?'
              end
              if crud_fields && crud_fields.include?(:edit)
                concat link_to 'Uredi', polymorphic_url([path_prefix, record], action: :edit)
              end
              if crud_fields && crud_fields.include?(:show)
                concat link_to 'Odpri', polymorphic_url([path_prefix, record])
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

    content_tag :div, class: klass.to_s do
      columns.each do |column|
        next unless format_field(resource, column, path_prefix).present?
        concat content_tag :strong, klass.human_attribute_name(column)
        concat content_tag :p, format_field(resource, column, path_prefix)
      end
    end
  end

  def admin_section(_klass = nil, &block)
    content_tag(:div, capture(&block), class: 'admin') if signed_in?
  end
end
