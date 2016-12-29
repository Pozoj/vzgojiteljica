# frozen_string_literal: true
class Admin::PostalCostsController < Admin::AdminController
  def index
    @postal_costs = PostalCost.all.order(service_type: :desc, weight_from: :asc)
    respond_with @postal_costs
  end

  def calculate
    @issue = Issue.last

    subscribers = Subscriber.active
    weight = @issue.weight

    if params[:only_paid]
      @paid = true
      subscribers = subscribers.paid
    elsif params[:only_free]
      @free = true
      subscribers = subscribers.free
    end

    # Skip manual delivery customers
    subscribers = subscribers.reject do |subscriber|
      subscriber.customer.manual_delivery?
    end

    @quantities = subscribers.group_by do |subscriber|
      subscriber.subscriptions.active.without_rewards.sum(:quantity)
    end.reject do |quantity, _entities|
      quantity < 1
    end.sort_by do |quantity, _entities|
      quantity
    end

    @postal_costs = @quantities.map do |quantity, entities|
      package_weight = quantity * weight
      postal_cost = PostalCost.calculate_for_weight(package_weight)
      packages = entities.length

      raise "Could not calculate postal cost for #{package_weight}" unless postal_cost

      {
        quantity: quantity,
        weight: weight,
        package_weight: package_weight,
        packages: packages,
        postal_cost: postal_cost,
        package_price: postal_cost.price,
        price: postal_cost.price * packages
      }
    end.group_by do |cost_bracket|
      cost_bracket[:postal_cost].service_type
    end
  end
end
