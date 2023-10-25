module Payments
  PaymentRequested =
    Data.define(:order_id, :amount) do
      def event_type
        self.class.name
      end
    end
  PaymentRegistered =
    Data.define(:order_id, :amount) do
      def event_type
        self.class.name
      end
    end

  Amount =
    Data.define(:value, :currency) do
      def initialize(value:, currency:)
        raise ArgumentError, "'value' must be numeric" unless Numeric === value
        raise ArgumentError, "'currency' must be string" unless String === currency

        super(value: BigDecimal(value), currency: currency.upcase)
      end

      def +(other)
        raise ArgumentError, "currency mismatch" if currency != other.currency

        Amount.new(value + other.value, currency)
      end

      def >=(other)
        raise ArgumentError, "currency mismatch" if currency != other.currency

        value >= other.value
      end
    end
end
