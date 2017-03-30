require './product.rb'
require 'bigdecimal'

class Checkout
  attr_reader :rules, :items, :products

  def initialize(rules = {})
    @rules = rules
    @items = []
    @products = Product.new
  end

  def scan(code)
    @items << @products.fetch_item(code)
  end

  def total
    run_rules

    total = items.inject(0) {|sum, item| sum + format_number(@products.fetch_item(item[:code])[:price])}

    if rules.has_key?(:total)
      return format_number(total - (total * rules[:total][:discount])) if total > rules[:total][:gt]
    end

    format_number(total)
  end

  def run_rules
    items_array = items.collect{|item| item[:code]}.sort!

    if rules.has_key?(:item)
      get_items_count(items_array).each do |key, value|
        if rules[:item].has_key?(key)
          rule = rules[:item][key]
          items.each {|item| item[:price] = rule[:price] if item[:code] == key} if value >= rule[:gte]
        end
      end
    end

  end

  private

  def get_items_count(items_array)
    items_array.each_with_object(Hash.new(0)) { |v, h| h[v] += 1 }
  end

  def format_number(number)
    BigDecimal.new(number, 8).round(2)
  end

end
