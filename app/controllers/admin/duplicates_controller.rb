class Admin::DuplicatesController < Admin::AdminController
  def index
    @duplicates = {}
    Customer.all.order(:id).each do |customer|
      @duplicates[customer.to_s] ||= []
      @duplicates[customer.to_s].push(customer)
      if customer.name? && customer.name != customer.to_s
        @duplicates[customer.name] ||= []
        @duplicates[customer.name].push(customer)
      end
      if customer.title? && customer.title != customer.to_s
        @duplicates[customer.title] ||= []
        @duplicates[customer.title].push(customer)
      end
    end
    @duplicates = @duplicates.reject { |k, v| v.length < 2 }
  end

  def merge
    @report = []

    root_duplicate = Customer.find(params[:id])

    duplicates_query = Customer.arel_table[:name].eq(root_duplicate.to_s).
    or(Customer.arel_table[:title].eq(root_duplicate.to_s).
    or(Customer.arel_table[:name].eq(root_duplicate.to_s).
    or(Customer.arel_table[:title].eq(root_duplicate.to_s))))
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
