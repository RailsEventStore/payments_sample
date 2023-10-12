module Payments
  class OrderRepository
    def initialize(event_store = Rails.configuration.event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    private attr_reader :repository

    def with_order(order_id, &block)
      repository.with_aggregate(Order.new(order_id), stream_name(order_id), &block)
    end

    private

    def stream_name(order_id)
      "Payments::Order$#{order_id}"
    end
  end
end