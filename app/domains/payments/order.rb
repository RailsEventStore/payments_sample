module Payments
  class Order
    include AggregateRoot

    NOT_SET = Object.new.freeze
    PaymentNotRequestedYet = Class.new(StandardError)

    def initialize(order_id)
      @order_id = order_id
      @total_amount = NOT_SET
    end

    private attr_reader :order_id
    private attr_accessor :total_amount, :paid_amount

    def request_payment(amount)
      apply(PaymentRequested.new(data: { order_id: order_id, amount: amount.value, currency: amount.currency }))
    end

    def register_payment(amount)
      raise PaymentNotRequestedYet if total_amount == NOT_SET

      apply(PaymentRegistered.new(data: { order_id: order_id, amount: amount.value, currency: amount.currency }))
    end

    def paid?
      return false if total_amount == NOT_SET

      paid_amount >= total_amount
    end

    on PaymentRequested do |event|
      self.total_amount = Amount.new(value: event.data.fetch(:amount), currency: event.data.fetch(:currency))
      self.paid_amount = Amount.new(value: 0, currency: event.data.fetch(:currency))
    end

    on PaymentRegistered do |event|
      self.paid_amount += Amount.new(value: event.data.fetch(:amount), currency: event.data.fetch(:currency))
    end
  end
end
