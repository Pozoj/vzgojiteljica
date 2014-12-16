class Admin::LabelsController < InheritedResources::Base
  before_filter :authenticate
  layout "admin"

  def index
    @labels = Subscriber.active.map do |subscriber|
      label = Label.new
      label.quantity = subscriber.subscriptions.active.sum(:quantity)
      label.subscriber = subscriber
      label
    end

    @labels = @labels.sort_by(&:quantity)

    render layout: 'print'
  end
end
