# frozen_string_literal: true
require 'set'

class Admin::DuplicatesController < Admin::AdminController
  def index_customers
    @duplicates = {}
    all_customers = Customer.all.order(:id)
    all_customers.each do |customer|
      @duplicates[customer.to_s] ||= Set.new
      @duplicates[customer.name] ||= Set.new
      @duplicates[customer.title] ||= Set.new
    end

    all_customers.each do |customer|
      @duplicates[customer.to_s].add(customer)
      @duplicates[customer.name].add(customer) if customer.name?
      @duplicates[customer.title].add(customer) if customer.title?
    end

    @duplicates = @duplicates.reject { |_k, v| v.length < 2 }
  end

  def index_authors
    @duplicates = Author.find_author_duplicates
  end

  def merge_authors
    author_ids = params[:duplicate_ids].split(',').map(&:to_i).sort

    root_duplicate = Author.find(author_ids.shift)
    duplicates = author_ids.map { |aid| Author.find(aid) }

    duplicates.each do |duplicate|
      duplicate.authorships.each do |authorship|
        authorship.author = root_duplicate
        authorship.save
      end

      next unless duplicate.reload.authorships.empty?

      duplicate.destroy
    end

    render text: 'OK'
  end

  def merge_customers
    @report = []

    root_duplicate = Customer.find(params[:id])

    duplicates_query = Customer.arel_table[:name].eq(root_duplicate.to_s)
                               .or(Customer.arel_table[:title].eq(root_duplicate.to_s)
    .or(Customer.arel_table[:name].eq(root_duplicate.to_s)
    .or(Customer.arel_table[:title].eq(root_duplicate.to_s))))
    duplicates = Customer.where(duplicates_query).order(:id)

    unless duplicates.any?
      return redirect_to(admin_duplicates_path, notice: 'No duplicates can be found')
    end

    unless root_duplicate.id == duplicates.first.id
      return redirect_to(admin_duplicates_path, notice: 'Root duplicate does not match')
    end

    duplicates = duplicates.to_a
    root_duplicate = duplicates.shift

    duplicates.each do |duplicate|
      root_duplicate.merge_in(duplicate)
      @report << "Destroyed #{duplicate} (#{duplicate.id}) in favor of #{root_duplicate} (#{root_duplicate.id})"
    end
  end

  private

  def set_page_title
    @page_title = 'Podvojeni'
  end
end
