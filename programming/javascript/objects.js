function Product() {
  this.price = 123
  this.printPrice = function() {
    console.log(this.price)
  }
}

var product = new Product()
console.log(product.constructor)
