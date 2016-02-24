require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  before do
    @customer = create(:customer)
  end

  context 'unauthenticated' do
    it 'allows access to public show page' do
      get :public_show, token: @customer.token
      expect(response).to be_success
    end

    describe '#ingest_order_form' do
      it 'redirects if token empty' do
        post :ingest_order_form
        expect(response).to redirect_to root_path
      end

      it 'redirects if token invalid' do
        post :ingest_order_form, token: 'foo'
        expect(response).to redirect_to root_path
      end

      it 'redirects unless order_form params are passed in' do
        post :ingest_order_form, token: @customer.token
        expect(response).to redirect_to root_path
      end

      it 'renders template unless order form id is passed in' do
        post :ingest_order_form, token: @customer.token, order_form: {authorizer: 'Lorem'}
        expect(response).to render_template :public_show
      end

      it 'redirects back if proper information is passed' do
        post :ingest_order_form, token: @customer.token, order_form: {form_id: 'Nar 1/2015', authorizer: 'Lorem'}
        expect(response).to redirect_to token_url(token: @customer.token)
      end
    end
  end
end
