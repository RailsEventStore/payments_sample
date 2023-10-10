require "test_helper"

module Payments
  class OrderTest < ActiveSupport::TestCase
    cover Order

    test "request payment" do
      with_aggregate("order-123") { |order| order.request_payment("order-123", 300) }

      assert_expected_events_in_stream(
        event_store,
        [PaymentRequested.new(data: { order_id: "order-123", amount: 300, currency: "EUR" })],
        "Payments::Order$order-123",
      )
    end

    test "register payment" do
      with_aggregate("order-123") do |order|
        order.request_payment("order-123", 300)
        order.register_payment("order-123", 300)
      end

      assert_expected_events_in_stream(
        event_store,
        [
          PaymentRequested.new(data: { order_id: "order-123", amount: 300, currency: "EUR" }),
          PaymentRegistered.new(data: { order_id: "order-123", amount: 300, currency: "EUR" }),
        ],
        "Payments::Order$order-123",
      )
    end

    test "full amount paid" do
      with_aggregate("order-123") do |order|
        order.request_payment("order-123", 300)
        order.register_payment("order-123", 300)
        assert order.paid?
      end
    end

    test "too much paid" do
      with_aggregate("order-123") do |order|
        order.request_payment("order-123", 300)
        order.register_payment("order-123", 301)
        assert order.paid?
      end
    end

    test "too little paid" do
      with_aggregate("order-123") do |order|
        order.request_payment("order-123", 300)
        order.register_payment("order-123", 299)
        refute order.paid?
      end
    end

    test "payment not yet requested" do
      with_aggregate("order-123") do |order|
        refute order.paid?
      end
    end

    private

    def with_aggregate(order_id)
      Infra::AggregateRootRepository
        .new(event_store)
        .with_aggregate(Order.new, "Payments::Order$#{order_id}") { |order| yield order }
    end
  end
end
