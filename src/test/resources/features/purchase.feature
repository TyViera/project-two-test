@purchase
@operation
@authorized
Feature: Purchase a product
As a user of the application I want to be able to purchase a product
To renew the product stock in the system

  Background:
    * callonce read('classpath:karate-data.js') ['products']
    Given url baseUrl
    * def operationPath = 'purchases'
    * def createProductFunctionName = 'products.feature@create-one-product'
    * def doPurchaseFunctionName = '@do_purchase'
    And header Authorization = callonce read('classpath:basic-auth.js') 'purchases'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'

  @positive_case
  Scenario: Successful purchase for one product
    # Product creation
    * def productRequest = { "name": "ProductPurchase", "code": "PP9911248L" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    * purchaseRequest.products[0].id = productResult.response.id
    # Purchase operation
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }
    # Store created product
    And eval extraData.products.push(productResult.response.id)

  @positive_case
  Scenario: Successful purchase for multiple products
    # Products creation
    # Product one
    * def productRequest = { "name": "MultipleProductPurchase1", "code": "PP9988713L" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * def purchaseRequest = read('classpath:api/purchases/success-three-products.json')
    * purchaseRequest.products[0].id = productResult.response.id
    # Product two
    * def productRequest = { "name": "MultipleProductPurchase2", "code": "PP9911521L" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * purchaseRequest.products[1].id = productResult.response.id
    # Product three
    * def productRequest = { "name": "MultipleProductPurchase3", "code": "PP998823L" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * purchaseRequest.products[2].id = productResult.response.id
    # Purchase operation
    * call read(doPurchaseFunctionName) { purchaseRequest: '#(purchaseRequest)' }

  @ignore @do_purchase
  Scenario: Do a purchase
    Given path operationPath
    And request purchaseRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 201
    And match response == ''

  @negative_case
  Scenario Outline: Failed purchase - <scenario_name>
    # Products creation
    Given path operationPath
    * def purchaseRequest = read('classpath:api/purchases/<input_file>.json')
    And request purchaseRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 400
    Examples:
      | scenario_name  | input_file           |
      | no supplier    | error-no-supplier    |
      | no products    | error-no-products    |
      | empty products | error-empty-products |
      | no product id  | error-no-product-id  |

  @negative_case
  Scenario Outline: Failed purchase with existent product - <scenario_name>
    # Products creation
    * def purchaseRequest = read('classpath:api/purchases/<input_file>.json')
    * def productRequest = { "name": "ProductFailedPurchase", "code": "<product_code>" }
    * def productResult = call read(createProductFunctionName) { inputRequest: '#(productRequest)' }
    * purchaseRequest.products[0].id = productResult.response.id
    Given path operationPath
    And request purchaseRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then assert 400 <= responseStatus && responseStatus < 500
    Examples:
      | scenario_name        | input_file                 | product_code |
      | non existent product | error-non-existent-product | PP9981725L   |
      | negative stock       | error-negative-quantity    | PP9981726L   |
      | zero stock           | error-zero-quantity        | PP9981727L   |
