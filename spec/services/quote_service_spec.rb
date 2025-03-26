# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'QuoteService' do
  let(:requested_topics) do
    {
      'reading' => 20,
      'math' => 50,
      'science' => 30,
      'history' => 15,
      'art' => 10
    }
  end
  let(:provider_data) do
    {
      'provider_a' => 'math+science',
      'provider_b' => 'reading+science',
      'provider_c' => 'history+math',
      'provider_d' => 'art+history'
    }
  end
  let(:service) { QuoteService.new(requested_topics) }

  before do
    allow_any_instance_of(QuoteService).to receive(:provider_data).and_return(provider_data)
  end

  it 'selects correct topics' do
    expect(service.topics).to eq({ 'math' => 50, 'science' => 30, 'reading' => 20 })
  end

  context 'selecting providers' do
    let(:requested_topics) do
      {
        'reading' => 20,
        'math' => 10,
        'science' => 15,
        'history' => 30,
        'art' => 50
      }
    end

    it 'selects correct topics from providers' do
      expected_providers = {
        'provider_b' => ['reading'],
        'provider_c' => ['history'],
        'provider_d' => ['art', 'history']
      }

      expect(service.send(:select_providers)).to eq(expected_providers)
    end
  end

  context 'calculating quotes' do
    let(:requested_topics) do
      {
        'reading' => 20,
        'math' => 10,
        'science' => 15,
        'history' => 30,
        'art' => 50
      }
    end

    it 'calculates correct values' do
      expected_values = {
        'provider_b' => 6.0,
        'provider_c' => 7.5,
        'provider_d' => 8.0
      }

      expect(service.calculate_quotes).to eq(expected_values)
    end
  end
end
