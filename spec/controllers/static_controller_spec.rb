require 'rails_helper'

RSpec.describe StaticController, type: :controller do

  context '400' do
    before { get '400' }

    it 'renders 400 static page' do
      expect(response).to render_template 'static/400'
    end
  end

  context '404' do
    before { get '404' }

    it 'renders 404 static page' do
      expect(response).to render_template 'static/404'
    end
  end

  context '500' do
    before { get '500' }

    it 'renders 500 static page' do
      expect(response).to render_template 'static/500'
    end
  end

  context '503' do
    before { get '503' }

    it 'renders 503 static page' do
      expect(response).to render_template 'static/503'
    end
  end
end
