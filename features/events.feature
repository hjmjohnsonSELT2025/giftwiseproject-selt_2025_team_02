Feature: Manage events for gift planning
  As a gift giver
  I want to create and manage events
  So that I can plan gifts around those events

  # use database directly for now
  Background:
    Given a user "Chad" exists
    And the user "Chad" has no events

  @happy_path
  Scenario: Create an event
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And I am on the events page
    When I follow "Add New Event"
    And I fill in "Event name" with "Beer oclock"
    And I fill in "Event date" with "2025-11-28"
    And I fill in "Event time" with "22:00"
    And I fill in "Location" with "Downtown"
    And I fill in "Budget" with "50"
    And I press "Create Event"
    Then I should see "Event 'Beer oclock' successfully created." within the flash
    And I should see "Beer oclock"
    And I should see "2025-11-28"
    And I should see "Downtown"
    And I should see "$50.00"
    And the event "Beer oclock" should have:
      | event_date | 2025-11-28 |
      | event_time | 22:00      |
      | location   | Downtown   |
      | budget     | 50         |

  @happy_path
  Scenario: Edit an event
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following events exist for this user:
      | name        | event_date | event_time | location | budget |
      | Beer oclock | 2025-11-28 | 22:00      | Downtown | 50     |
    And I am on the events page
    When I click "Edit"
    And I fill in "Event date" with "2025-12-01"
    And I fill in "Location" with "Rooftop Bar"
    And I press "Update Event"
    Then I should see "Event 'Beer oclock' successfully updated." within the flash
    And I should see "Beer oclock"
    And I should see "Rooftop Bar"
    And the event "Beer oclock" should have:
      | event_date | 2025-12-01 |
      | location   | Rooftop Bar |

  @happy_path
  Scenario: Delete an existing event
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following events exist for this user:
      | name        | event_date | event_time | location | budget |
      | Beer oclock | 2025-11-28 | 22:00      | Downtown | 50     |
    And I am on the events page
    When I follow "Delete"
    Then I should be on the events page
    And I should see "Event 'Beer oclock' deleted." within the flash
    And I should not see "Beer oclock" in the events list

  @happy_path
  Scenario: Associate recipients with an event
    Given the user "Chad" has a recipient named "Thad"
    And the user "Chad" has a recipient named "Brad"
    And the user "Chad" has an event called "Beer oclock"
    When the recipients "Thad" and "Brad" are added to the event "Beer oclock"
    Then the event "Beer oclock" should have recipients:
      | Thad |
      | Brad |
    And the recipient "Thad" should be associated with the event "Beer oclock"
    And the recipient "Brad" should be associated with the event "Beer oclock"

  @wip
  Scenario: View upcoming events for this week
    Given today is a Monday in the current week
    And the user "Chad" has events:
      | name        | event_date     |
      | Beer oclock | this Wednesday |
      | Game night  | next month     |
      | Movie night | this Friday    |
    When the user "Chad" views their events for this week
    Then they should see:
      | Beer oclock |
      | Movie night |
    And they should not see:
      | Game night  |

  @wip
  Scenario: Invite another GiftWise user to collaborate on an event
    Given the user "Chad" has an event called "Beer oclock"
    And another user "Lad" exists
    When "Chad" invites "Lad" to collaborate on the event "Beer oclock"
    Then "Lad" should see the event "Beer oclock" in their events list
    And both "Chad" and "Lad" should be able to view the same event details
