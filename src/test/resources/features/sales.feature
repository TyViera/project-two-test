@sale
@operation
@authorized
Feature: Sales a product
As a user of the application I want to be able to sale a product
To get money

  Background:
    * callonce read('classpath:karate-data.js') []
    Given url baseUrl
    * def operationPath = 'sales'
    * def createClientFunctionName = 'clients.feature@create-one-client'
    * def createProductFunctionName = 'products.feature@create-one-product'
    * def doPurchaseFunctionName = 'purchase.feature@do_purchase'
    * def doSaleFunctionName = '@do_sale'
    * def doFailedSaleFunctionName = '@do_failed_sale'
    And header Authorization = callonce read('classpath:basic-auth.js') 'sales'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    * def clientRequest = { "name": "Client", "nif": "123456789" }

  @positive_case
  Scenario Outline: Successful sale - <scenario_name>
    * def saleRequest = read('classpath:api/sales/success-one.json')
    # Client creation
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * saleRequest.client.id = clientResult.response.id
    # Product creation
    * def productRequest = { "name": "ProductSale", "code": "<product_code>" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[0].id = createdProductId
    # Purchase to be able to sell the product
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = createdProductId
    * purchaseRequest.products[0].quantity = <quantity_to_purchase>
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    * saleRequest.products[0].quantity = <quantity_to_sale>
    # Sale operation
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    Examples:
      | scenario_name  | product_code | quantity_to_purchase | quantity_to_sale |
      | one product    | PS971923T    | 100                  | 12               |
      | sale all stock | PS439848T    | 7                    | 7                |

  @positive_case
  Scenario: Successful sale for multiple products
    * def saleRequest = read('classpath:api/sales/success-three.json')
    # Client creation
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * saleRequest.client.id = clientResult.response.id
    # Product one creation
    * def productRequest = { "name": "ProductSale", "code": "PS9911248T" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[0].id = createdProductId
    # Purchase to be able to sell the product one
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = createdProductId
    * purchaseRequest.products[0].quantity = 100
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    * saleRequest.products[0].quantity = 12
    # Product two creation
    * def productRequest = { "name": "ProductSale2", "code": "PS887162T" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[1].id = createdProductId
    # Purchase to be able to sell the product two
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[1].id = createdProductId
    * purchaseRequest.products[1].quantity = 100
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    * saleRequest.products[1].quantity = 27
    # Product three creation
    * def productRequest = { "name": "ProductSale3", "code": "PS2258468T" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[2].id = createdProductId
    # Purchase to be able to sell the product three
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[2].id = createdProductId
    * purchaseRequest.products[2].quantity = 100
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    * saleRequest.products[2].quantity = 89
    # Sale operation
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }

  @ignore @do_sale
  Scenario: Do a sale
    Given path operationPath
    And request saleRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 201
    And match response == ''

  @negative_case
  Scenario Outline: Failed sale - <scenario_name>
    # Products creation
    Given path operationPath
    * def saleRequest = read('classpath:api/sales/<input_file>.json')
    And request saleRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 400
    Examples:
      | scenario_name       | input_file                |
      | no client           | error-no-client           |
      | no client id        | error-no-client-id        |
      | no products         | error-no-products         |
      | empty products      | error-empty-products      |
      | no product id       | error-no-product-id       |
      | no product quantity | error-no-product-quantity |

  @negative_case
  Scenario: Failed sale - non existent client
    * def saleRequest = read('classpath:api/sales/success-one.json')
    * saleRequest.client.id = '7d82cc83-7b4b-48ac-8d48-5f1f37a4f405'
    # Sale operation
    * call read(doFailedSaleFunctionName) { saleRequest: '#(saleRequest)' }

  @negative_case
  Scenario: Failed sale - non existent product
    * def saleRequest = read('classpath:api/sales/success-one.json')
    # Client creation
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * saleRequest.client.id = clientResult.response.id
    * saleRequest.products[0].id = '09e4e622-dec8-463f-a53e-3b9d6ca93e41'
    # Sale operation
    * call read(doFailedSaleFunctionName) { saleRequest: '#(saleRequest)' }

  @negative_case
  Scenario: Failed sale - not purchased product
    * def saleRequest = read('classpath:api/sales/success-one.json')
    # Client creation
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * saleRequest.client.id = clientResult.response.id
    # Product creation
    * def productRequest = { "name": "ProductSale", "code": "PS599658T" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[0].id = createdProductId
    * saleRequest.products[0].quantity = 5
    # Sale operation
    * call read(doFailedSaleFunctionName) { saleRequest: '#(saleRequest)' }

  @negative_case
  Scenario: Failed sale - not enough stock
    * def saleRequest = read('classpath:api/sales/success-one.json')
    # Client creation
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * saleRequest.client.id = clientResult.response.id
    # Product creation
    * def productRequest = { "name": "ProductSale", "code": "PS4178547T" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[0].id = createdProductId
    # Purchase to be able to sell the product
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = createdProductId
    * purchaseRequest.products[0].quantity = 3
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    * saleRequest.products[0].quantity = 5
    # Sale operation
    * call read(doFailedSaleFunctionName) { saleRequest: '#(saleRequest)' }

  @ignore @do_failed_sale
  Scenario: Do a failed sale
    Given path operationPath
    And request saleRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then assert 400 <= responseStatus && responseStatus < 500

  @products @crud @delete @negative_case
  Scenario: Failed to delete a previously sold product
    * def saleRequest = read('classpath:api/sales/success-one.json')
    # Client creation
    * def clientResult = call read(createClientFunctionName) { inputRequest: '#(clientRequest)' }
    * saleRequest.client.id = clientResult.response.id
    # Product creation
    * def productRequest = { "name": "ProductSale", "code": "PS5558745T" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def createdProductId = productResult.response.id
    * saleRequest.products[0].id = createdProductId
    # Purchase to be able to sell the product
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = createdProductId
    * purchaseRequest.products[0].quantity = 2
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    * saleRequest.products[0].quantity = 1
    # Sale operation
    * call read(doSaleFunctionName) { saleRequest: '#(saleRequest)' }
    # Delete product
    Given path 'products/' + createdProductId
    When method delete
    # Response validations
    And print 'Response: ', response
    Then status 422