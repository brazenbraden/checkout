require './checkout'

RSpec.describe Checkout, 'class' do
  def inject_products
    @checkout.products.add(code: '001', name: 'Lavender heart', price: '9.25')
    @checkout.products.add(code: '002', name: 'Personalized Cufflinks', price: '45')
    @checkout.products.add(code: '003', name: 'Kids T-shirt', price: '19.95')
  end

  def format_number(value)
    BigDecimal.new(value, 8).round(2)
  end

  context 'testing format_number conversions' do
    it 'should convert a string into a number' do
      expect(format_number("10.40")).to eq 10.40
    end

    it 'should prevent floating point errors' do
      a = 0.15 + 0.15
      b = 0.1 + 0.2
      expect(format_number(a)).to eq format_number(b)
    end
  end

  context 'creating an instance of Checkout' do
    it 'should create a new instance of Checkout'do
      checkout = Checkout.new
      expect(checkout).to be_an_instance_of Checkout
    end

    it 'should accept additional rules' do
      rules = {foo: 'bar'}
      checkout = Checkout.new(rules)
      expect(checkout.rules).to eq rules
    end
  end

  context 'creating a product' do
    before(:example) do
      @product = Product.new
    end

    it 'should be an instance of Product' do
      expect(@product).to be_an_instance_of Product
    end

    it 'should add a product' do
      @product.add(code: '001', name: 'product', price: '5')
      expect(@product.items.count).to eq 1
      expect(@product.items.first[:name]).to eq 'product'
    end

    it 'should fetch a product' do
      @product.add(code: '001', name: 'product', price: '5')
      expect(@product.fetch_item('001')[:name]).to eq 'product'
    end
  end

  context 'after creating an instance of checkout' do
    before(:example) do
      @checkout = Checkout.new
      inject_products
    end

    it 'should have three products' do
      expect(@checkout.products.items.count).to eq 3
    end
  end

  context 'scanning an item' do
    before(:example) do
      @checkout = Checkout.new
      inject_products
    end

    it 'should add an item to the checkout basket' do
      @checkout.scan('001')
      expect(@checkout.items.count).to eq 1
    end

    it 'adds up the total' do
      @checkout.scan('001')
      @checkout.scan('002')
      expect(@checkout.total).to eq format_number('54.25')
    end
  end

  context 'test rules' do
    it 'should have a discount with a total > 60' do
      rules = {
        total: {
          gt: 60,
          discount: 0.1
        }
      }
      @checkout = Checkout.new(rules)
      inject_products
      @checkout.scan('002')
      @checkout.scan('002')
      expect(@checkout.total).to eq format_number('81')
    end

    it 'should discount 2 or more lavendars (code 001)' do
      rules = {
        item: {
          '001' => {
            gte: 2,
            price: 8.50
          }
        }
      }
      @checkout = Checkout.new(rules)
      inject_products
      @checkout.scan('001')
      @checkout.scan('001')
      expect(@checkout.total).to eq format_number('17')
    end
  end

  context 'examples for use' do
    before(:example) do
      rules = {
        total: {
          gt: 60,
          discount: 0.1
        },
        item: {
          '001' => {
            gte: 2,
            price: 8.50
          }
        }
      }
      @checkout = Checkout.new(rules)
      inject_products
    end

    it 'should accept basket 1' do
      @checkout.scan('001')
      @checkout.scan('002')
      @checkout.scan('003')
      expect(@checkout.total).to eq format_number('66.78')
    end

    it 'should accept basket 2' do
      @checkout.scan('001')
      @checkout.scan('003')
      @checkout.scan('001')
      expect(@checkout.total).to eq format_number('36.95')
    end

    it 'should accept basket 3' do
      @checkout.scan('001')
      @checkout.scan('002')
      @checkout.scan('001')
      @checkout.scan('003')
      expect(@checkout.total).to eq format_number('73.76')
    end

  end
end