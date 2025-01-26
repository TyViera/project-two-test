@swagger
Feature: Get swagger docs
As a user of the application I want to read the API documentarion using the swagger URIs
To understand the API

  Background:
    * callonce read('classpath:karate-data.js') []
    Given url baseUrl

  @positive_case
  Scenario: Check swagger ui main page
    Given path 'swagger-ui.html'
    When method get
    # Response validations
    Then status 200
    And match header Content-Type == 'text/html'
    And match response contains '<title>Swagger UI</title>'

  @positive_case
  Scenario: Check swagger ui redirected page
    Given path '/swagger-ui/index.html'
    When method get
    # Response validations
    Then status 200
    And match header Content-Type == 'text/html'
    And match response contains '<title>Swagger UI</title>'

  @positive_case
  Scenario: Check openapi docs page
    Given path '/v3/api-docs'
    When method get
    # Response validations
    Then status 200
    And match header Content-Type == 'application/json'
    And match response.openapi contains '3.0'
    And match response.info.title == '#present'
    And match response.info.version == '#present'
    And match response.servers == '#present'
    And match response.tags == '#present'
    And match response.paths == '#present'
    And match response.components == '#present'

