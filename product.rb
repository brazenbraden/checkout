class Product
  attr_reader :items

  def initialize
    @items = []
  end

  def add(product = {})
    items << product
  end

  def fetch_item(code)
    items.select { |item| item[:code] == code }.first
  end

end