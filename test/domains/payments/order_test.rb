require "test_helper"

module Payments
  class OrderTest < ActiveSupport::TestCase
    cover Order

    test "request payment" do
      order_id = "order-123"
      Infra::AggregateRootRepository
        .new(event_store)
        .with_aggregate(Order.new, "Payments::Order$#{order_id}") { |order| order.request_payment("order-123", 300) }

      assert_expected_events_in_stream(
        event_store,
        [PaymentRequested.new(data: { order_id: "order-123", amount: 300, currency: "EUR" })],
        "Payments::Order$#{order_id}",
      )
    end
  end
end
