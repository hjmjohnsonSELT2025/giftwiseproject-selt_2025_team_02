Feature: Manage gifts
  As a thoughtful gift giver
  So that I can keep track of gifts I plan to give
  I want to add gifts to my list

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no gifts
    And I am on the gifts page

  @happy_path
  Scenario: Successfully add a new gift
    When I follow "New Gift"
    And I fill in "Name" with "Cozy Blanket"
    And I press "Create Gift"
    Then I should see "Cozy Blanket"
    And I should see "Gift giver:"
    And I should see "User"
    And 1 gift should exist for the current user

  @sad_path
  Scenario: Fail to add a new gift when name is missing
    When I follow "New Gift"
    And I press "Create Gift"
    Then I should see "New Gift"
    And 0 gifts should exist for the current user

  @view_gift
  Scenario: View details for an existing gift
    Given there are no gifts
    And I am on the gifts page
    When I follow "New Gift"
    And I fill in "Name" with "Fancy Mug"
    And I press "Create Gift"
    Then I should see "Fancy Mug"
    And I should see "Gift giver:"
    And I should see "User"
    And I should see "Back"

  @cancel_gift
  Scenario: Cancel creating a new gift
    Given there are no gifts
    And I am on the gifts page
    When I follow "New Gift"
    And I follow "Cancel"
    Then I should be on the gifts page
    And 0 gifts should exist for the current user