Feature: Manage gift recipients
  As an organized gift giver
  So that I can keep track of who I need to buy gifts for
  I want to add people as gift recipients

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And I am on the recipients page

  @happy_path
  Scenario: Successfully add a new gift recipient
    When I follow "Add New Recipient"
    And I fill in "Name" with "Grandma Rose"
    And I fill in "Age" with "68"
    And I select "Female" from "Gender"
    And I fill in "Relation" with "Grandmother"
    And I check "Reading"
    And I check "Pets"
    And I press "Add Recipient"
    Then I should be on the recipients page
    And I should see "Grandma Rose was successfully created." within the flash
    And I should see "Grandma Rose"

  @sad_path
  Scenario: Cancel adding a new recipient before saving
    When I follow "Add New Recipient"
    And I follow "Back to Home"
    Then I should be on the home page
    And 0 recipients should exist for the current user

