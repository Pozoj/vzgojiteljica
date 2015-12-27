class Admin::CustomersController < Admin::AdminController
  has_scope :page, :default => 1

  def show
    respond_with resource
  end

  def new_freerider
    @customer = Customer.new
  end

  def merge
    @customer = Customer.find(params[:id])
  end

  def merge_in
    @customer = Customer.find(params[:id])
    other_customer = Customer.find(params[:other_customer_id])

    if @customer && other_customer
      @customer.merge_in(other_customer)
    end

    redirect_to admin_customer_path(@customer), notice: "Pridružil #{other_customer.id} k #{@customer.id}"
  end

  def create_freerider
    Customer.transaction do
      @customer = Customer.new
      @subscriber = @customer.subscribers.build
      customer_params = params.require(:customer)
      @customer.title   = @subscriber.title   = customer_params[:title]
      @customer.name    = @subscriber.name    = customer_params[:name]
      @customer.address = @subscriber.address = customer_params[:address]
      @customer.post_id = @subscriber.post_id = customer_params[:post_id]

      @customer.save
      @subscriber.save

      # Subscription
      if customer_params[:subscription]
        @subscription = @subscriber.subscriptions.build
        @subscription.plan = Plan.free
        @subscription.start = DateTime.now
        @subscription.quantity = customer_params[:subscription][:quantity]
        # Type
        type = customer_params[:subscription][:free_type]
        @subscription.end = if type == "1"
          DateTime.now.end_of_month
        elsif type == "2"
          DateTime.now.end_of_year
        elsif type == "3"
          1.year.from_now.beginning_of_month
        elsif type == "4"
          # No end for now.
        end

        if @subscription.save
          redirect_to admin_subscription_path(@subscription)
          return
        end
      end
    end

    render action: :new_freerider
  end

  def new_from_order
    begin
      order = Order.find(params[:order_id])
      customer = Customer.new_from_order(order)
      order.processed!(current_user.id)
      redirect_to admin_customer_path(customer), notice: "Stranka uspešno ustvarjena iz naročila ##{order.id}"
    rescue Customer::FromOrderError => e
      redirect_to admin_order_path(order, error: e.inspect)
    end
  end

  def new
    @customer = Customer.new
    respond_with resource
  end

  def create
    @customer = Customer.create resource_params
    respond_with resource, location: -> { admin_customer_path(@customer) }
  end

  def edit
    @all_customers = Customer.all.select(:id, :name, :title).where.not(id: resource.id).sort_by { |c| c.to_s }.map { |c| ["#{c.to_s} -- #{c.id}", c.id] }
    respond_with resource, location: -> { admin_customer_path(resource) }
  end

  def update
    resource.update_attributes resource_params
    if resource.valid?
      respond_with resource, location: -> { admin_customer_path(@customer) }
    else
      respond_with resource, location: -> { edit_admin_customer_path(@customer) }
    end
  end

  def destroy
    resource.destroy
    respond_with resource, location: -> { admin_entities_path }
  end

  # People

  def add_person
    @entity = case params[:person]
    when 'contact'
      ContactPerson
    when 'billing'
      BillingPerson
    end.new

    @customer = resource
  end

  def edit_person
    @entity = Entity.find(params[:id])
    @customer = @entity.entity
  end

  def update_person
    @entity = Entity.find(params[:person_id])
    @customer = @entity.entity

    if params[:contact_person]
      @entity.update_attributes(params[:contact_person])
    elsif params[:billing_person]
      @entity.update_attributes(params[:billing_person])
    end

    if @entity.valid?
      respond_with resource, location: -> { admin_customer_path(@customer) }
    else
      render 'edit_person'
    end
  end

  def create_person
    @customer = resource
    if params[:contact_person]
      @entity = @customer.build_contact_person(params[:contact_person])
    elsif params[:billing_person]
      @entity = @customer.build_billing_person(params[:billing_person])
    end

    if @entity.valid?
      @entity.save
      @customer.save
      respond_with resource, location: -> { admin_customer_path(@customer) }
    else
      render 'add_person'
    end
  end

  private

  def resource
    @customer ||= Customer.find(params[:id])
  end

  def resource_params
    params.require(:customer)
  end
end
