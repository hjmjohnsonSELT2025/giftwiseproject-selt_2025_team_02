Feature: Delete gift recipient
  As an organized gift giver
  So that I can keep my recipient list up to date
  I want to delete a gift recipient when they are no longer needed

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And the following recipients exist for this user:
      | name        | age | gender | relation    |
      | Grandma Joy | 70  | female | Grandmother |
      | Uncle Bob   | 55  | male   | Uncle       |
    And I am on the recipients page

  @happy_path
  Scenario: Successfully delete an existing recipient
    When I follow "Grandma Joy"
    And I follow "Delete"
    Then I should be on the recipients page
    And I should see "Recipient 'Grandma Joy' deleted." within the flash
    And I should not see "Grandma Joy" in the recipients list
    And I should see "Uncle Bob"

  @sad_path
  Scenario: Leave the recipients unchanged by not deleting
    When I follow "Grandma Joy"
    And I follow "Back to Recipients"
    Then I should be on the recipients page
    And I should see "Grandma Joy"
    And 2 recipients should exist for the current user
