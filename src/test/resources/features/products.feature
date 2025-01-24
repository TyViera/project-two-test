@products
@crud
Feature: Crud for products
  As a user of the application I want to be able to create, read, update and delete products
  To manage them inside the system

  Background:
    Given url baseUrl
    * callonce read('classpath:arrays.js') ['productIds', 'productsData']
    * def operationPath = 'products'
    And header Authorization = callonce read('classpath:basic-auth.js') { username: 'user', password: 'password' }
    And header Accept = 'application/json'

  @creation @positive_case
  Scenario Outline: Successful product creation - <file-name>
    * def inputRequest = read('classpath:api/products/create/<file-name>.json')
    Given path operationPath
    And header Content-Type = 'application/json'
    And request inputRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 201
    And match response.id == '#present'
    And match response.name == inputRequest.name
    And match response.code == inputRequest.code
    # Remove created products
    And eval extraData.productIds.push(response.id)
    Examples:
      | file-name                 |
      | success-all-data          |
      | success-composite-name    |
      | success-max-length-values |
      | success-min-length-values |

  @creation @negative_case
  Scenario Outline: Failed product creation - <file-name>
    * def inputRequest = read('classpath:api/products/create/<file-name>.json')
    Given path operationPath
    And header Content-Type = 'application/json'
    And request inputRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 400
    Examples:
      | file-name                  |
      | error-empty-json           |
      | error-invalid-char-in-name |
      | error-no-code              |
      | error-no-name              |
      | error-too-long-code        |
      | error-too-long-name        |
      | error-too-short-code       |
      | error-too-short-name       |

  @creation @negative_case
  Scenario: Failed product creation - code already in use
    * def inputRequest = read('classpath:api/products/create/success-all-data.json')
    Given path operationPath
    And header Content-Type = 'application/json'
    And request inputRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 422
    And match response contains 'There is already a product with the provided code'

  @read @positive_case
  Scenario: Successful product list query
    Given path operationPath
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And assert response.length >= extraData.productIds.length
    And match response[*].id contains extraData.productIds

  @read @positive_case
  Scenario: Successful product by id query
    * def fun = function (item) { return karate.call('@get_by_id', {productId: item, dataArray: extraData.productsData}); }
    * karate.forEach(extraData.productIds, fun)

  @ignore @get_by_id
  Scenario: Get product by id - productId
    Given path operationPath + '/' + productId
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response.id == productId
    And eval dataArray.push(response)

  @read @negative_case
  Scenario Outline: Get non existent product id <product-id>
    Given path operationPath + '/<product-id>'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 404
    Examples:
      | product-id                           |
      | 123                                  |
      | invalid-value                        |
      | Abc                                  |
      | 5c40be7d-febc-4857-9d61-0b969343d5e5 |

  @update @positive_case
  Scenario: Successful product modification
    * def filesIndex = 0
    * def files = ['success-one-name']
    * def fun = function (k, i) { return karate.call('@update-by-id', {productId: extraData.productIds[i], index: i, dataArray: extraData.productsData, fileName: files[(filesIndex++) % files.length ]}); }
    * karate.forEach(extraData.productIds, fun)
    * call fun(extraData.productIds[0], 0)

  @ignore @update-by-id
  Scenario: Successful product modification
    * def previousProduct = dataArray[index]
    * def inputRequest = read('classpath:api/products/update/' + fileName + '.json')
    Given path operationPath + '/' + productId
    And header Content-Type = 'application/json'
    And request inputRequest
    When method put
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response.id == productId
    And match response.name != previousProduct.name
    And match response.code != previousProduct.code
    #comparison with previous
    And match response.id == previousProduct.id
    And match response.name == inputRequest.name
    And match response.code == inputRequest.code
    #Update the product data
    And eval dataArray[index] = response

  @update @negative_case
  Scenario: Failed product modification - code already in use
    * def inputRequest = read('classpath:api/products/update/error-repeated-code.json')
    Given path operationPath + '/' + extraData.productIds[0]
    And header Content-Type = 'application/json'
    And request inputRequest
    When method put
    # Response validations
    And print 'Response: ', response
    Then status 422
    And match response contains 'There is already a product with the provided code'

  @delete @positive_case
  Scenario: Successful product by id deletion
    * def fun = function (item) { return karate.call('@delete_by_id', {productId: item}); }
    * karate.forEach(extraData.productIds, fun)

  @ignore @delete_by_id
  Scenario: Delete product by id - productId
    Given path operationPath + '/' + productId
    When method delete
    # Response validations
    And print 'Response: ', response
    Then status 204
    And match response == ''

  @delete @negative_case
  Scenario Outline: Delete non existent product id <product-id>
    Given path operationPath + '/<product-id>'
    When method delete
    # Response validations
    And print 'Response: ', response
    Then status 404
    Examples:
      | product-id                           |
      | 123                                  |
      | invalid-value                        |
      | Abc                                  |
      | 5c40be7d-febc-4857-9d61-0b969343d5e5 |
