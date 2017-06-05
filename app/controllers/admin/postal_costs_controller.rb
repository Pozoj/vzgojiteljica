# frozen_string_literal: true
class Admin::PostalCostsController < Admin::AdminController
  def index
    @postal_costs = PostalCost.all.order(service_type: :desc, weight_from: :asc)
    respond_with @postal_costs
  end

  def calculate
    @issue = Issue.last
    weight = @issue.weight

    # Skip manual delivery customers
    @postal_costs = Subscriber.active.reject do |subscriber|
      subscriber.customer.manual_delivery?
    end.group_by do |subscriber|
      subscriber
        .subscriptions
        .active
        .without_rewards
        .sum(:quantity)
    end.reject do |quantity, _entities|
      quantity < 1
    end.sort_by do |quantity, _entities|
      quantity
    end.map do |quantity, entities|
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

  def calculate_reward
    @issue = Issue.last
    weight = @issue.weight

    @postal_costs = Subscription.active.free.rewards.map do |subscription|
      next unless subscription.quantity > 0

      issue_weight = weight

      # 1 is drawing reward, they get 2 copies AND a reward
      if subscription.reward == 1
        issue_weight *= 2
        issue_weight += Issue::WEIGHT_PER_REWARD
      end

      {
        issue_weight: issue_weight,
        subscription: subscription
      }
    end.group_by do |subscription|
      subscription[:subscription].subscriber
    end.map do |subscriber, subscriptions|
      {
        subscriber: subscriber,
        subscriptions: subscriptions,
        quantity: subscriptions.sum { |subscription| subscription[:subscription].quantity }
      }
    end.sort_by do |subscriber|
      subscriber[:quantity]
    end.map do |subscriber|
      package_weight = subscriber[:subscriptions].sum { |subscription| subscription[:issue_weight] }
      postal_cost = PostalCost.calculate_for_weight(package_weight)
      packages = 1

      raise "Could not calculate postal cost for #{package_weight}" unless postal_cost

      {
        quantity: subscriber[:quantity],
        package_weight: package_weight,
        packages: packages,
        postal_cost: postal_cost,
        package_price: postal_cost.price,
        price: postal_cost.price
      }
    end.sort_by do |cost_bracket|
      cost_bracket[:package_weight]
    end.group_by do |cost_bracket|
      cost_bracket[:postal_cost].service_type
    end
  end
end
