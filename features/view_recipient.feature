Feature: View gift recipient
  As an organized gift giver
  So that I can see the details for someone I buy gifts for
  I want to view an existing gift recipient's profile

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And the following recipients exist for this user:
      | name        | age | gender | relation    |
      | Grandma Joy | 70  | female | Grandmother |
    And I am on the recipients page

  @happy_path
  Scenario: View details for an existing recipient
    When I follow "Grandma Joy"
    Then I should see "Grandma Joy"
    And I should see "Age: 70"
    And I should see "Gender: female"
    And I should see "Relation: Grandmother"
    And I should see "Edit"
    And I should see "Delete"
    And I should see "Back to Recipients"
    And I should see "Back to Home"

  @sad_path
  Scenario: Return to recipients list from the recipient profile
    When I follow "Grandma Joy"
    And I follow "Back to Recipients"
    Then I should be on the recipients page
