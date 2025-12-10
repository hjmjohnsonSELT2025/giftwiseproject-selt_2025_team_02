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
    And a recipient "Nancy" exists for this user
    And a gift list "General ideas" exists for "Nancy"
    And a gift "Book" exists on the "General ideas" gift list
    And I am on the "General ideas" gift list page

  @ui
  Scenario: See the Save Changes action for drag-and-drop updates
    Then I should see "Save Changes"
    And I should see "Idea"
    And I should see "Planned"

  # Note: Drag-and-drop interaction is handled by Stimulus/JS and covered by request/view specs.
  # Here we only validate that the page exposes the UI necessary to make updates.
