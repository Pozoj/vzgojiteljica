class Admin::LabelsController < Admin::AdminController
  def index
    @labels = Subscriber.active.map do |subscriber|
      label = Label.new
      label.subscriber = subscriber
      label.quantity = subscriber.subscriptions.active.sum(:quantity)
      next unless label.quantity > 0
      
      label
    end

    @labels = @labels.compact.sort_by(&:quantity)

    render layout: 'print'
  end
end
