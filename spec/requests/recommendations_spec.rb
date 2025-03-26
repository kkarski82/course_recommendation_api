# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Recommendations', type: :request do
  describe 'POST /quote' do
    let(:request_params) do
      {
        topics: {
          reading: 20,
          math: 50,
          science: 30,
          history: 15,
          art: 10
        }
      }
    end

    it 'returns the correct quotes' do
      post recommendations_quote_path, params: request_params

      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)

      expect(body).to eq({ 'provider_a' => 8.0, 'provider_b' => 5.0, 'provider_c' => 10.0 })
    end
  end
end
