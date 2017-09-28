Feature: Prebid Mobile

Scenario: Test DFP Scenarios
    Given the app has launched
    When I touch "DFP"
    And I touch "Banner"
    And I touch the "See Ad" button
    And I wait for 4 seconds
    Then I should see an AppNexus ad

Scenario: Test DFP Interstitial Scenarios
    Given the app has launched
    When I touch "DFP"
    And I touch "Interstitial"
    And I touch the "See Ad" button
    And I wait for 4 seconds
    Then I should see an AppNexus ad

Scenario: Test DFP Facebook Banner Scenarios
    Given the app has launched
    When I touch "DFP"
    And I touch "Banner"
    And I clear input field number 2
    And I enter "audienceNetwork" into input field number 2
    And I touch the "See Ad" button
    And I wait for 4 seconds
    Then I should see a Facebook ad

Scenario: Test MoPub Scenarios
    Given the app has launched
    When I touch "MoPub"
    And I touch "Banner"
    And I touch the "See Ad" button
    And I wait for 4 seconds
    Then I should see an AppNexus ad in WKWebView

Scenario: Test MoPub Interstitial Scenarios
    Given the app has launched
    When I touch "MoPub"
    And I touch "Interstitial"
    And I touch the "See Ad" button
    And I wait for 4 seconds
    Then I should see an AppNexus ad in WKWebView
