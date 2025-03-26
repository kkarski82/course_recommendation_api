# frozen_string_literal: true

# Generates quotes for providers based on requested topics
class QuoteService
  DEFAULT_FACTOR = 10
  FACTORS = [20, 25, 30].freeze

  attr_reader :logger, :topics, :providers

  def initialize(requested_topics)
    @logger = ActiveSupport::Logger.new('log/quotes.log')
    @topics = sort_topics(requested_topics).freeze
    @providers = provider_data
  end

  # calculate quotes for each provider based on matching topics
  def calculate_quotes
    quotes = {}

    select_providers.each do |provider, topic_arr|
      if topic_arr.length > 1
        total_value = topic_arr.sum(0.0) { |t| topics[t] }
        factor = DEFAULT_FACTOR
      else
        total_value = topics[topic_arr.first].to_f
        factor = FACTORS[topics.keys.find_index(topic_arr.first)]
      end

      quotes[provider] = total_value * factor / 100
    end

    logger.info("QUOTED #{quotes.inspect} PROVIDERS")

    quotes
  end

  protected

  # returns top 3 topics by value
  def sort_topics(requested_topics)
    sorted = requested_topics.transform_values(&:to_f).sort_by { |_k, v| -v }.first(3).to_h

    logger.info("SELECTED #{sorted.inspect} FROM #{requested_topics.inspect}")

    sorted
  end

  # select providers that match requested topics
  def select_providers
    relevant_topics = topics.keys

    chosen = providers
      .select { |_k, v| relevant_topics.any? { |t| v.include?(t) } }
      .each_with_object({}) do |(provider, topics_arr), agg|
        provider_topics = topics_arr.split('+')

        agg[provider] = []

        provider_topics.each { |t| agg[provider].push(t) if relevant_topics.include?(t) }
      end

    logger.info("SELECTED #{chosen.inspect} PROVIDERS")

    chosen
  end

  # fetch relevant data for providers
  def provider_data
    Rails.configuration.provider_data['provider_topics'].freeze
  end
end
