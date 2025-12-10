Feature: View gift statuses on a gift list
  As a gift planner
  So that I can organize gifts by progress
  I want to see status columns on each gift list

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And there are no gift lists
    And there are no gifts
    And a recipient "Nancy" exists for this user
    And a gift list "General ideas" exists for "Nancy"
    And I am on the "General ideas" gift list page

  @ui
  Scenario: Status columns are visible on the gift list page
    Then I should see "Idea"
    And I should see "Planned"
    And I should see "Ordered"
    And I should see "Received or finished"
    And I should see "Wrapped"
    And I should see "Given"

  @ui
  Scenario: Gifts appear on the gift list page
    Given a gift "Book" exists on the "General ideas" gift list
    Then I should see "Book"
