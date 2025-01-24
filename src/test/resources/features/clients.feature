@clients
@crud
Feature: Crud for clients
  As a user of the application I want to be able to create, read, update and delete clients
  To manage them inside the system

  Background:
    Given url baseUrl
    * callonce read('classpath:arrays.js') ['clientIds', 'clientsData']
    * def operationPath = 'clients'
    And header Authorization = callonce read('classpath:basic-auth.js') { username: 'user', password: 'password' }
    And header Accept = 'application/json'

  @creation @positive_case
  Scenario Outline: Successful client creation - <file-name>
    * def inputRequest = read('classpath:api/clients/create/<file-name>.json')
    Given path operationPath
    And header Content-Type = 'application/json'
    And request inputRequest
    When method post
    # Response validations
    And print 'Response: ', response
    Then status 201
    And match response.id == '#present'
    And match response.name == inputRequest.name
    And match response.nif == inputRequest.nif
    And match response.address == inputRequest.address
    # Remove created clients
    And eval extraData.clientIds.push(response.id)
    Examples:
      | file-name                 |
      | success-all-data          |
      | success-max-length-values |
      | success-min-length-values |
      | success-no-address        |
      | success-two-names         |

  @creation @negative_case
  Scenario Outline: Failed client creation - <file-name>
    * def inputRequest = read('classpath:api/clients/create/<file-name>.json')
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
      | error-no-name              |
      | error-no-nif               |
      | error-too-long-address     |
      | error-too-long-name        |
      | error-too-long-nif         |
      | error-too-short-address    |
      | error-too-short-name       |
      | error-too-short-nif        |

  @read @positive_case
  Scenario: Successful client list query
    Given path operationPath
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And assert response.length >= extraData.clientIds.length
    And match response[*].id contains extraData.clientIds

  @read @positive_case
  Scenario: Successful client by id query
    * def fun = function (item) { return karate.call('@get_by_id', {clientId: item, dataArray: extraData.clientsData}); }
    * karate.forEach(extraData.clientIds, fun)

  @ignore @get_by_id
  Scenario: Get client by id - clientId
    Given path operationPath + '/' + clientId
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response.id == clientId
    And eval dataArray.push(response)

  @read @negative_case
  Scenario Outline: Get non existent client id <client-id>
    Given path operationPath + '/<client-id>'
    When method get
    # Response validations
    And print 'Response: ', response
    Then status 404
    Examples:
      | client-id                            |
      | 123                                  |
      | invalid-value                        |
      | Abc                                  |
      | 2dea5cc5-c42a-4257-bdda-79931f665765 |

  @update @positive_case
  Scenario: Successful client modification
    * def filesIndex = 0
    * def files = ['success-one-name', 'success-no-address']
    * def fun = function (k, i) { return karate.call('@update-by-id', {clientId: extraData.clientIds[i], index: i, dataArray: extraData.clientsData, fileName: files[(filesIndex++) % files.length ]}); }
    * karate.forEach(extraData.clientIds, fun)

  @ignore @update-by-id
  Scenario: Successful client modification
    * def previousClient = dataArray[index]
    * def inputRequest = read('classpath:api/clients/update/' + fileName + '.json')
    Given path operationPath + '/' + clientId
    And header Content-Type = 'application/json'
    And request inputRequest
    When method put
    # Response validations
    And print 'Response: ', response
    Then status 200
    And match response.id == clientId
    And match response.name != previousClient.name
    And match response.nif != previousClient.nif
    And match response.address != previousClient.address
    #comparison with previous
    And match response.id == previousClient.id
    And match response.name == inputRequest.name
    And match response.nif == inputRequest.nif
    And match response.address == inputRequest.address
    #Update the client data
    And eval dataArray[index] = response

  @delete @positive_case
  Scenario: Successful client by id deletion
    * def fun = function (item) { return karate.call('@delete_by_id', {clientId: item}); }
    * karate.forEach(extraData.clientIds, fun)

  @ignore @delete_by_id
  Scenario: Delete client by id - clientId
    Given path operationPath + '/' + clientId
    When method delete
    # Response validations
    And print 'Response: ', response
    Then status 204
    And match response == ''

  @delete @negative_case
  Scenario Outline: Delete non existent client id <client-id>
    Given path operationPath + '/<client-id>'
    When method delete
    # Response validations
    And print 'Response: ', response
    Then status 404
    Examples:
      | client-id                            |
      | 123                                  |
      | invalid-value                        |
      | Abc                                  |
      | 2dea5cc5-c42a-4257-bdda-79931f665765 |
