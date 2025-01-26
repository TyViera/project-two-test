@products
@stock
@operation
Feature: Get stock for a product
As a user of the application I want to know the stock of a product
To know if I can sell it or not

  Background:
    * callonce read('classpath:karate-data.js') []
    Given url baseUrl
    * def createProductFunctionName = 'products.feature@create-one-product'
    * def createClientFunctionName = 'clients.feature@create-one-client'
    * def doPurchaseFunctionName = 'purchase.feature@do_purchase'
    * def doSaleFunctionName = 'sales.feature@do_sale'
    * def doStockFunctionName = '@check_stock'
    And header Authorization = callonce read('classpath:basic-auth.js') 'stock'
    And header Accept = 'application/json'

  @positive_case
  Scenario: Successful get stock - new product
    # Product creation
    * def productRequest = { "name": "ProductToStock", "code": "PTS521469R" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    # Stock
    * call read(doStockFunctionName) { productIdStock: '#(productResult.response.id)', expectedStock: 0 }

  @positive_case
  Scenario: Successful get stock - product with purchase
    * def stockToPurchase = 45
    # Product creation
    * def productRequest = { "name": "ProductToStock", "code": "PTS521470R" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    # Purchase operation
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = productResult.response.id
    * purchaseRequest.products[0].quantity = stockToPurchase
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    # Stock
    * call read(doStockFunctionName) { productIdStock: '#(productResult.response.id)', expectedStock: '#(stockToPurchase)' }

  @positive_case
  Scenario: Successful get stock - product with purchase and sales
    * def stockToPurchase = 45
    * def stockToSale = 20
    * def finalStock = (stockToPurchase - stockToSale)
    # Product creation
    * def productRequest = { "name": "ProductToStock", "code": "PTS521470R" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    # Purchase operation
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = productResult.response.id
    * purchaseRequest.products[0].quantity = stockToPurchase
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    # Client creation
    * def clientRequest = { "name": "Stock", "nif": "U76123981" }
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * def saleRequest = read('classpath:api/sales/success-one.json')
    * saleRequest.client.id = clientResult.response.id
    # Sale operation
    * saleRequest.products[0].id = productResult.response.id
    * saleRequest.products[0].quantity = stockToSale
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Stock
    * call read(doStockFunctionName) { productIdStock: '#(productResult.response.id)', expectedStock: '#(finalStock)' }

  @positive_case
  Scenario: Successful get stock - product with purchase and multiple sales
    * def stockToPurchase = 12
    * def stockToSale = 2
    * def finalStock = (stockToPurchase - stockToSale * 3)
    # Product creation
    * def productRequest = { "name": "ProductToStock", "code": "PTS521470R" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    # Purchase operation
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = productResult.response.id
    * purchaseRequest.products[0].quantity = stockToPurchase
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    # Client creation
    * def clientRequest = { "name": "Stock", "nif": "U76123981" }
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * def saleRequest = read('classpath:api/sales/success-one.json')
    * saleRequest.client.id = clientResult.response.id
    # Sale operation - one
    * saleRequest.products[0].id = productResult.response.id
    * saleRequest.products[0].quantity = stockToSale
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Sale operation - two
    * saleRequest.products[0].id = productResult.response.id
    * saleRequest.products[0].quantity = stockToSale
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Sale operation - three
    * saleRequest.products[0].id = productResult.response.id
    * saleRequest.products[0].quantity = stockToSale
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Stock
    * call read(doStockFunctionName) { productIdStock: '#(productResult.response.id)', expectedStock: '#(finalStock)' }

  @ignore @check_stock
  Scenario: Check stock
    Given path 'products', productIdStock, 'stock'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response.stock == expectedStock

  @negative_case
  Scenario Outline: Failed get stock for one unexistent product query
    Given path 'products', '<product_id>', 'stock'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 404
    Examples:
      | product_id                           |
      | 123                                  |
      | abc0                                 |
      | non-existent                         |
      | b66b8896-4f6d-44b1-9a39-61d0569818d9 |