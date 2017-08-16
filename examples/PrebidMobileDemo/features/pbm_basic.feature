Feature: Prebid Mobile

Scenario: Test DFP Scenarios
    Given the app has launched
    When I touch "DFP"
    And I touch "Banner"
    And I touch the "See Ad" button
    And I wait for 4 seconds
    Then I should see an AppNexus ad

Scenario: Test MoPub Scenarios
    Given the app has launched
    When I touch "MoPub"
    And I touch "Banner"
    And I touch the "See Ad" button
    And I wait for 4 seconds
    Then I should see an AppNexus ad
