Feature: Edit gift recipient
  As an organized gift giver
  So that I can keep my recipient info up to date
  I want to edit an existing gift recipient

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And the following recipients exist for this user:
      | name        | age | gender | relation    |
      | Grandma Joy | 70  | female | Grandmother |
    And I am on the recipients page

  @happy_path
  Scenario: Successfully edit an existing recipient
    When I follow "Grandma Joy"
    And I follow "Edit"
    And I fill in "Relation" with "Nana"
    And I press "Update Recipient"
    Then I should see "Grandma Joy was successfully updated." within the flash
    And I should see "Nana"

  @sad_path
  Scenario: Cancel editing before saving changes
    When I follow "Grandma Joy"
    And I follow "Edit"
    And I fill in "Relation" with "Nana"
    And I follow "Back to Recipients"
    Then I should be on the recipients page
    And I follow "Grandma Joy"
    And I should see "Grandmother"
