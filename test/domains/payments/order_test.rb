require "test_helper"

module Payments
  class OrderTest < ActiveSupport::TestCase
    cover Order

    test "request payment" do
      repository.with_order("order-123") { |order| order.request_payment(300) }

      assert_expected_events_in_stream(
        event_store,
        [PaymentRequested.new(data: { order_id: "order-123", amount: 300, currency: "EUR" })],
        "Payments::Order$order-123",
      )
    end

    test "register payment" do
      repository.with_order("order-123") do |order|
        order.request_payment(300)
        order.register_payment(300)
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
      repository.with_order("order-123") do |order|
        order.request_payment(300)
        order.register_payment(300)

        assert order.paid?
      end
    end

    test "full amount paid with multiple payments" do
      repository.with_order("order-123") do |order|
        order.request_payment(300)
        order.register_payment(100)
        order.register_payment(200)

        assert order.paid?
      end
    end

    test "too much paid" do
      repository.with_order("order-123") do |order|
        order.request_payment(300)
        order.register_payment(301)

        assert order.paid?
      end
    end

    test "too little paid" do
      repository.with_order("order-123") do |order|
        order.request_payment(300)
        order.register_payment(299)

        refute order.paid?
      end
    end

    test "payment not yet requested" do
      repository.with_order("order-123") { |order| refute order.paid? }
    end

    private

    def repository
      OrderRepository.new(event_store)
    end
  end
end
