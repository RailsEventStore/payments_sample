module Payments
  class OrderRepository
    def initialize(event_store = Rails.configuration.event_store)
      @event_store = event_store
    end

    private attr_reader :event_store

    def load(order)
      event_store
        .read
        .stream(stream_name(order.order_id))
        .reduce { |_, event| order.apply(infra_to_domain_mapper(event)) }
      order.version = order.unpublished_events.count - 1
      order
    end

    def store(order)
      event_store.publish(
        order.unpublished_events.map(&method(:domain_to_infra_mapper)),
        stream_name: stream_name(order.order_id),
        expected_version: order.version,
      )
      order.version = order.version + order.unpublished_events.count
    end

    private

    def stream_name(order_id)
      "Payments::Order$#{order_id}"
    end

    def infra_to_domain_mapper(event)
      {
        "Infra::Payments::PaymentRequested" =>
          PaymentRequested.new(
            order_id: event.data.fetch(:order_id),
            amount: Amount.new(value: event.data.fetch(:amount_value), currency: event.data.fetch(:amount_currency)),
          ),
        "Infra::Payments::PaymentRegistered" =>
          PaymentRegistered.new(
            order_id: event.data.fetch(:order_id),
            amount: Amount.new(value: event.data.fetch(:amount_value), currency: event.data.fetch(:amount_currency)),
          ),
      }.fetch(event.event_type)
    end

    def domain_to_infra_mapper(event)
      {
        "Payments::PaymentRequested" =>
          Infra::Payments::PaymentRequested.new(
            data: {
              order_id: event.order_id,
              amount_value: event.amount.value,
              amount_currency: event.amount.currency,
            },
          ),
        "Payments::PaymentRegistered" =>
          Infra::Payments::PaymentRegistered.new(
            data: {
              order_id: event.order_id,
              amount_value: event.amount.value,
              amount_currency: event.amount.currency,
            },
          ),
      }.fetch(event.event_type)
    end
  end
end
