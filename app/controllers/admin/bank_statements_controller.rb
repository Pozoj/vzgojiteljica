class Admin::BankStatementsController < Admin::AdminController
  def index
    @statement = BankStatement.new
    respond_with collection
  end

  def show
    @entries = resource.entries
    respond_with resource
  end

  def new
    @statement = BankStatement.new
    respond_with resource
  end

  def create
    @statement = BankStatement.create params[:bank_statement]
    respond_with resource, location: -> { admin_bank_statement_path(@statement) }
  end

  def parse
    resource.parse!
    respond_with resource
  end

  private

  def resource
    @statement ||= BankStatement.find(params[:id])
  end

  def collection
    @statements ||= BankStatement.order(id: :desc).page(params[:page])
  end
end
