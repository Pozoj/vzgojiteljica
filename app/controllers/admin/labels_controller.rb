# frozen_string_literal: true
class Admin::LabelsController < Admin::AdminController
  def print
    @labels = Subscription.active

    if params[:paid].present?
      @labels = @labels.paid
    elsif params[:freeriders].present?
      @labels = @labels.free
    elsif params[:rewards].present?
      @labels = @labels.rewards
    elsif params[:except_rewards].present?
      @labels = @labels.without_rewards
    elsif params[:all].present?
    end

    @labels = @labels.group_by do |subscription|
      subscription.subscriber
    end.map do |subscriber, subscriptions|
      label = Label.new
      label.subscriber = subscriber
      label.quantity = subscriptions.sum(&:quantity)
      next unless label.quantity > 0

      label
    end

    @labels = @labels.compact.sort_by(&:quantity)

    render layout: 'print'
  end

  def show
    subscriber = Subscriber.find(params[:id])
    label = Label.new
    label.subscriber = subscriber
    label.quantity = subscriber.subscriptions.active.sum(:quantity)

    unless label.quantity > 0
      render nothing: true
      return
    end

    @labels = [label]

    render action: 'print', layout: 'print'
  end

  private

  def set_page_title
    @page_title = 'Nalepke'
  end
end
