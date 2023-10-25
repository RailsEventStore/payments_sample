require "test_helper"
require "minitest/mock"

module Payments
  class OrderRepositoryTest < ActiveSupport::TestCase
    cover OrderRepository

    test "infra events are translated to domain events and applied on load" do
      event_store.publish(
        [
          Infra::Payments::PaymentRequested.new(
            data: {
              order_id: "order-1",
              amount_value: 100,
              amount_currency: "EUR",
            },
          ),
          Infra::Payments::PaymentRegistered.new(
            data: {
              order_id: "order-1",
              amount_value: 100,
              amount_currency: "EUR",
            },
          ),
        ],
        stream_name: "Payments::Order$order-1",
      )

      order = Minitest::Mock.new(Order.new("order-1"))
      order.expect(:apply, nil, [PaymentRequested.new(order_id: "order-1", amount: Amount.new(100, "EUR"))])
      order.expect(:apply, nil, [PaymentRegistered.new(order_id: "order-1", amount: Amount.new(100, "EUR"))])

      OrderRepository.new.load(order)

      order.verify
    end

    test "no unpublished events on fresh aggregate instance" do
      refute OrderRepository.new.load(Order.new("order-1")).unpublished_events.any?
    end

    test "aggregate version is set accordingly" do
      event_store.publish(
        Infra::Payments::PaymentRequested.new(data: { order_id: "order-1", amount_value: 100, amount_currency: "EUR" }),
        stream_name: "Payments::Order$order-1",
      )
      order = OrderRepository.new.load(Order.new("order-1"))

      assert_equal(0, order.version)
    end

    test "aggregate version is set for given instance" do
      event_store.publish(
        Infra::Payments::PaymentRequested.new(data: { order_id: "order-1", amount_value: 100, amount_currency: "EUR" }),
        stream_name: "Payments::Order$order-1",
      )
      event_store.publish(
        Infra::Payments::PaymentRequested.new(data: { order_id: "order-1", amount_value: 100, amount_currency: "EUR" }),
        stream_name: "dummy",
      )
      order = OrderRepository.new.load(Order.new("order-1"))

      assert_equal(0, order.version)
    end

    test "store translates domain events to infra ones" do
      event_store = Minitest::Mock.new
      event_store.expect(:publish, nil) do |events, stream_name:, expected_version:|
        assert_equal_event(
          Infra::Payments::PaymentRequested.new(
            data: {
              order_id: "order-1",
              amount_value: 100,
              amount_currency: "EUR",
            },
          ),
          events[0],
        )
        assert_equal_event(
          Infra::Payments::PaymentRegistered.new(
            data: {
              order_id: "order-1",
              amount_value: 100,
              amount_currency: "EUR",
            },
          ),
          events[1],
        )
        assert_equal("Payments::Order$order-1", stream_name)
        assert_equal(-1, expected_version)
      end

      order = Order.new("order-1")
      order.apply(PaymentRequested.new(order_id: "order-1", amount: Amount.new(100, "EUR")))
      order.apply(PaymentRegistered.new(order_id: "order-1", amount: Amount.new(100, "EUR")))

      OrderRepository.new(event_store).store(order)

      event_store.verify

      assert_equal(1, order.version)
    end
  end
end
