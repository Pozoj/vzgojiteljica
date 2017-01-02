class Admin::AuthorsController < Admin::AdminController
  respond_to :html, :json

  def index
    respond_with collection
  end

  def new
    @author = Author.new
    respond_with resource
  end

  def create
    @author = Author.create resource_params

    respond_with resource, location: -> { admin_authors_path }
  end

  def create_simple
    names = resource_params[:author].split(' ')
    first_name = names[0]
    last_name = names[1..names.length].join(' ')
    @author = Author.create(first_name: first_name, last_name: last_name)

    render json: {
      id: @author.id,
      name: @author.name
    }
  end

  def edit
    respond_with resource
  end

  def update
    resource.update_attributes resource_params
    respond_with resource, location: -> { admin_author_path(resource) }
  end

  def destroy
    resource.destroy
    respond_with resource
  end

  private

  def collection
    @authors ||= Author.all.order(:last_name, :first_name).page(params[:page])
  end

  def resource
    return unless params[:id]
    @author ||= Author.find(params[:id])
  end

  def resource_params
    params.require(:author).permit(:id, :first_name, :last_name, :email, :address, :post_id, :phone, :institution_id, :title, :education, :author)
  end
end
