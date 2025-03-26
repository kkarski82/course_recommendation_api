# frozen_string_literal: true

class RecommendationsController < ApplicationController

  def quote
    requested_topics = topic_params.to_h.with_indifferent_access["topics"]
    provider_quotes = QuoteService.new(requested_topics).calculate_quotes

    render json: provider_quotes, status: 200
  end

  private

  def topic_params
    params.permit(topics: {})
  end
end
