@reports
@authorized
Feature: Get sale reports
As a user of the application I want to know the stock of a product
To know if I can sell it or not

  Background:
    * callonce read('classpath:karate-data.js') []
    Given url baseUrl
    * def createProductFunctionName = 'products.feature@create-one-product'
    * def createClientFunctionName = 'clients.feature@create-one-client'
    * def doPurchaseFunctionName = 'purchase.feature@do_purchase'
    * def doSaleFunctionName = 'sales.feature@do_sale'
    And header Authorization = callonce read('classpath:basic-auth.js') 'reports'
    And header Accept = 'application/json'

  @past_sales @positive_case
  Scenario: Successful past sales - newly created client
    # Client creation
    * def clientRequest = { "name": "Reports", "nif": "Z88874585L" }
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    # Query report
    Given path 'clients', clientResult.response.id, 'sales'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response == []

  @past_sales @positive_case
  Scenario: Successful past sales - client with one sale only
    * def saleRequest = read('classpath:api/sales/success-one.json')
    # Client creation
    * def clientRequest = { "name": "Reports", "nif": "Z88874585L" }
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * def createdClientId = clientResult.response.id
    * saleRequest.client.id = createdClientId
    # Product creation
    * def productRequest = { "name": 'ProductReportOne', "code": "PRF554712" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[0].id = createdProductId
    # Purchase to be able to sell the product
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = createdProductId
    * purchaseRequest.products[0].quantity = 33
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    # Sale operation
    * saleRequest.products[0].quantity = 11
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Query report
    Given path 'clients', createdClientId, 'sales'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response == '#[1]'
    And match response[0].id == '#present'
    And match response[0].products == '#[1]'
    And match response[0].products[0].product.id == createdProductId
    And match response[0].products[0].product.name == productRequest.name
    And match response[0].products[0].quantity == 11

  @past_sales @positive_case
  Scenario: Successful past sales - client with multiple sales
    * def saleRequest = read('classpath:api/sales/success-one.json')
    # Client creation
    * def clientRequest = { "name": "Reports", "nif": "Z88874585L" }
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * def createdClientId = clientResult.response.id
    * saleRequest.client.id = createdClientId
    # Product creation
    * def productRequest = { "name": 'ProductReportSaleTwo', "code": "PRF554713" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[0].id = createdProductId
    # Purchase to be able to sell the product
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = createdProductId
    * purchaseRequest.products[0].quantity = 54
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    # Sale operation
    * saleRequest.products[0].quantity = 16
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Sale operation
    * saleRequest.products[0].quantity = 20
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Sale operation
    * saleRequest.products[0].quantity = 3
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Sale operation
    * saleRequest.products[0].quantity = 11
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Query report
    Given path 'clients', createdClientId, 'sales'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response == '#[4]'
    And match response[0].id == '#present'
    And match response[0].products == '#[1]'
    And match response[0].products[0].product.id == createdProductId
    And match response[0].products[0].product.name == productRequest.name
    And match response[0].products[0].quantity == 16
    And match response[1].id == '#present'
    And match response[1].products == '#[1]'
    And match response[1].products[0].product.id == createdProductId
    And match response[1].products[0].product.name == productRequest.name
    And match response[1].products[0].quantity == 20
    And match response[2].id == '#present'
    And match response[2].products == '#[1]'
    And match response[2].products[0].product.id == createdProductId
    And match response[2].products[0].product.name == productRequest.name
    And match response[2].products[0].quantity == 3
    And match response[3].id == '#present'
    And match response[3].products == '#[1]'
    And match response[3].products[0].product.id == createdProductId
    And match response[3].products[0].product.name == productRequest.name
    And match response[3].products[0].quantity == 11

  @past_sales @negative_case
  Scenario Outline: Failed see past sales - unexistent client
    Given path 'clients', '<client_id>', 'sales'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 404
    Examples:
      | client_id                            |
      | 123                                  |
      | abc0                                 |
      | non-existent                         |
      | bd72eb07-9970-4221-89ea-ab4b5e8ab284 |


  @income_report @positive_case
  Scenario: Successful income report
    # Query report
    Given path 'sales', 'most-sold-products'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response == '#[5]'
    And match response[0].product.id == '#present'
    And match response[0].product.name == '#present'
    And match response[0].quantity == '#present'
    And match response[1].product.id == '#present'
    And match response[1].product.name == '#present'
    And match response[1].quantity == '#present'
    And match response[2].product.id == '#present'
    And match response[2].product.name == '#present'
    And match response[2].quantity == '#present'
    And match response[3].product.id == '#present'
    And match response[3].product.name == '#present'
    And match response[3].quantity == '#present'
    And match response[4].product.id == '#present'
    And match response[4].product.name == '#present'
    And match response[4].quantity == '#present'
    And assert response[0].quantity >= response[1].quantity
    And assert response[1].quantity >= response[2].quantity
    And assert response[2].quantity >= response[3].quantity
    And assert response[3].quantity >= response[4].quantity