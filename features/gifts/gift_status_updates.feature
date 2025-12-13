Feature: Update gift statuses on a gift list
  As a gift planner
  So that I can track progress of each gift
  I want to update a gift's status from the gift list page

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And there are no gift lists
    And there are no gifts
    And the following recipients exist for this user:
      | name        | age | gender | relation    | birthday
      | Nancy       | 20  | female | friend      | 01/22/2005
    And a gift list "General ideas" exists for "Nancy"
    And a gift "Book" exists on the "General ideas" gift list
    And I am on the "General ideas" gift list page

  @ui
  Scenario: See the Save Changes action for drag-and-drop updates
    Then I should see "Save Changes"
    And I should see "Idea"
    And I should see "Planned"

