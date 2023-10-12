require "test_helper"

module Payments
  class AmountTest < ActiveSupport::TestCase
    cover Amount

    test "equality" do
      assert_equal(Amount.new(100, "EUR"), Amount.new(100, "EUR"))
      assert_not_equal(Amount.new(99, "EUR"), Amount.new(100, "EUR"))
      assert_not_equal(Amount.new(100, "EUR"), Amount.new(100, "USD"))
    end

    test "expect value to become BigDecimal" do
      assert_equal(BigDecimal("100.0"), Amount.new(100, "EUR").value)
    end

    test "raise if value is not numeric" do
      assert_raises(ArgumentError, "'value' must be numeric") { Amount.new("WAT", "EUR") }
    end

    test "upcase currency" do
      assert_equal("EUR", Amount.new(100, "eur").currency)
    end

    test "raise if currency is not string" do
      assert_raises(ArgumentError, "'currency' must be string") { Amount.new(100, 123) }
    end

    test "adding two amounts" do
      assert_equal(Amount.new(200, "EUR"), Amount.new(100, "EUR") + Amount.new(100, "EUR"))
    end

    test "adding between currencies is not supported" do
      assert_raises(ArgumentError, "currency mismatch") { Amount.new(100, "EUR") + Amount.new(100, "USD") }
    end

    test "comparing between currencies is not supported" do
      assert_raises(ArgumentError, "currency mismatch") { Amount.new(100, "EUR") >= Amount.new(100, "USD") }
    end
  end
end
