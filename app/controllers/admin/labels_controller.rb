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

    render action: 'index', layout: 'print'
  end
end
