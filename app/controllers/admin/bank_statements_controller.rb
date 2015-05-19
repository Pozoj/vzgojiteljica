class Admin::BankStatementsController < Admin::AdminController
  def index
    @statement = BankStatement.new
    @entries = StatementEntry.all
    respond_with collection
  end

  def show
    @entries = resource.entries
    respond_with resource
  end

  def new
    @statement ||= BankStatement.new
    respond_with resource
  end

  def create
    @statement = BankStatement.new params[:bank_statement]

    if @statement.save
      respond_with resource, location: -> { admin_bank_statement_path(@statement) }
    else
      render action: 'new'
    end
  end

  def parse
    resource.parse!
    respond_with resource, location: -> { admin_bank_statement_path(@statement) }
  end

  private

  def resource
    @statement ||= BankStatement.find(params[:id])
  end

  def collection
    @statements ||= BankStatement.order(id: :desc).page(params[:page])
  end
end
