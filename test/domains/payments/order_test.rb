require "test_helper"

module Payments
  class OrderTest < ActiveSupport::TestCase
    cover Order

    test "request payment" do
      repository.with_order("order-123") { |order| order.request_payment(Amount.new(300, "EUR")) }

      assert_expected_events_in_stream(
        event_store,
        [PaymentRequested.new(data: { order_id: "order-123", amount: 300, currency: "EUR" })],
        "Payments::Order$order-123",
      )
    end

    test "register payment" do
      repository.with_order("order-123") do |order|
        order.request_payment(Amount.new(300, "EUR"))
        order.register_payment(Amount.new(300, "EUR"))
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
        order.request_payment(Amount.new(300, "EUR"))
        order.register_payment(Amount.new(300, "EUR"))

        assert order.paid?
      end
    end

    test "full amount paid with multiple payments" do
      repository.with_order("order-123") do |order|
        order.request_payment(Amount.new(300, "EUR"))
        order.register_payment(Amount.new(100, "EUR"))
        order.register_payment(Amount.new(200, "EUR"))

        assert order.paid?
      end
    end

    test "too much paid" do
      repository.with_order("order-123") do |order|
        order.request_payment(Amount.new(300, "EUR"))
        order.register_payment(Amount.new(301, "EUR"))

        assert order.paid?
      end
    end

    test "too little paid" do
      repository.with_order("order-123") do |order|
        order.request_payment(Amount.new(300, "EUR"))
        order.register_payment(Amount.new(299, "EUR"))

        refute order.paid?
      end
    end

    test "payment not yet requested" do
      repository.with_order("order-123") { |order| refute order.paid? }
    end

    test "payment not yet requested but paid" do
      repository.with_order("order-123") do |order|
        assert_raises(Order::PaymentNotRequestedYet) { order.register_payment(Amount.new(300, "EUR")) }
      end
    end

    private

    def repository
      OrderRepository.new(event_store)
    end
  end
end
