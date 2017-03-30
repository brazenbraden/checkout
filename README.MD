**Checkout Example**

The purpose of this little project is to provide a simple interface to a checkout system. Products can be injected into the system and then a checkout 'basket' can be filled with items after which, totalling up the prices of all items optionally modified by 'promotional rules'.

Simple usage of the classes are as follows:

`
# Define the promotional rules
rules = {
  total: {
    gt: 60,
    discount: 0.1  # i.e. 10%
  }
}

@checkout = Checkout.new(rules)

# Add products to the system
@checkout.products.add(code: '001', name: 'Product 1', price: '10.49')
@checkout.products.add(code: '002', name: 'Product 2', price: '63.92')

# Add items to the basket
@checkout.scan('001')
@checkout.scan('002')
@checkout.scan('001')

#Finally, checkout the basket to view the total amount owed
@checkout.total
`

