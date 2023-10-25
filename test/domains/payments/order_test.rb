require "test_helper"

module Payments
  class OrderTest < ActiveSupport::TestCase
    cover Order

    test "request payment" do
      assert_equal(
        [PaymentRequested.new(order_id: "order-123", amount: Amount.new(300, "EUR"))],
        Order.new("order-123").request_payment(Amount.new(300, "EUR")),
      )
    end

    test "register payment" do
      order = Order.new("order-123")
      order.request_payment(Amount.new(300, "EUR"))
      order.register_payment(Amount.new(300, "EUR"))

      assert_equal(
        [
          PaymentRequested.new(order_id: "order-123", amount: Amount.new(300, "EUR")),
          PaymentRegistered.new(order_id: "order-123", amount: Amount.new(300, "EUR")),
        ],
        order.unpublished_events.to_a,
      )
    end

    test "full amount paid" do
      order = Order.new("order-123")
      order.request_payment(Amount.new(300, "EUR"))
      order.register_payment(Amount.new(300, "EUR"))

      assert order.paid?
    end

    test "full amount paid with multiple payments" do
      order = Order.new("order-123")
      order.request_payment(Amount.new(300, "EUR"))
      order.register_payment(Amount.new(100, "EUR"))
      order.register_payment(Amount.new(200, "EUR"))

      assert order.paid?
    end

    test "too much paid" do
      order = Order.new("order-123")
      order.request_payment(Amount.new(300, "EUR"))
      order.register_payment(Amount.new(301, "EUR"))

      assert order.paid?
    end

    test "too little paid" do
      order = Order.new("order-123")
      order.request_payment(Amount.new(300, "EUR"))
      order.register_payment(Amount.new(299, "EUR"))

      refute order.paid?
    end

    test "payment not yet requested" do
      refute Order.new("order-123").paid?
    end

    test "payment not yet requested but paid" do
      assert_raises(Order::PaymentNotRequestedYet) { Order.new("order-123").register_payment(Amount.new(300, "EUR")) }
    end
  end
end
