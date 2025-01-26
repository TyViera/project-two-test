@unauthorized
Feature: Check authentication
As a user I want to check that sensible operations are protected with basic auth
To ensure only people with the rigth access can reach them

  Background:
    * callonce read('classpath:karate-data.js') []
    Given url baseUrl
    And header Accept = 'application/json'

  @purchase @negative_case
  Scenario: Failed purchase - unauthorized
    Given path 'purchases'
    * def purchaseRequest = read('classpath:api/purchases/success-one.json')
    And request purchaseRequest
    When method post
    And print 'Response: ', response
    Then status 401

  @sale @negative_case
  Scenario: Failed sale - unauthorized
    Given path 'sales'
    * def saleRequest = read('classpath:api/sales/success-one.json')
    And request saleRequest
    When method post
    And print 'Response: ', response
    Then status 401

  @reports @past_sales @negative_case
  Scenario: Failed past sales report - unauthorized
    Given path 'clients', 'd06e3178-58f5-4ebf-92b4-d6c6e6662d1a', 'sales'
    When method get
    And print 'Response: ', response
    Then status 401

  @reports @income_report @negative_case
  Scenario: Failed income report - unauthorized
    Given path 'sales', 'most-sold-products'
    When method get
    And print 'Response: ', response
    Then status 401