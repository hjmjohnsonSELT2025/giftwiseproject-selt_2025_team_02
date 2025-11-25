Feature: Manage events for gift planning
  As a gift giver
  I want to create and manage events
  So that I can plan gifts around those events

  # use database directly for now
  Background:
    Given a user "Chad" exists
    And the user "Chad" has no events

  @wip
  Scenario: Create an event with details
    When the user "Chad" creates an event called "Beer oclock" with:
      | event_date | 4 days from now |
      | event_time | 22:00           |
      | location   | Downtown        |
      | budget     | 50              |
    Then the user "Chad" should have an event called "Beer oclock"
    And the event "Beer oclock" should have:
      | event_date | 4 days from now |
      | event_time | 22:00           |
      | location   | Downtown        |
      | budget     | 50              |

  @wip
  Scenario: Associate recipients with an event
    Given the user "Chad" has a recipient named "Thad"
    And the user "Chad" has a recipient named "Brad"
    And the user "Chad" has an event called "Beer oclock"
    When the recipients "Thad" and "Brad" are added to the event "Beer oclock"
    Then the event "Beer oclock" should have recipients:
      | Thad |
      | Brad         |
    And the recipient "Thad" should be associated with the event "Beer oclock"
    And the recipient "Brad" should be associated with the event "Beer oclock"

  @wip 
  Scenario: Delete an event and remove it from my schedule
    Given the user "Chad" has an event called "Beer oclock"
    When the user "Chad" deletes the event "Beer oclock"
    Then the user "Chad" should not see "Beer oclock" in their events
    And the event "Beer oclock" should not appear in the user's schedule

  @wip 
  Scenario: Edit event details
    Given the user "Chad" has an event called "Beer oclock" with:
      | event_date | 4 days from now |
      | location   | Downtown        |
    When the user "Chad" updates the event "Beer oclock" to:
      | event_date | 7 days from now |
      | location   | Rooftop Bar     |
    Then the event "Beer oclock" should have:
      | event_date | 7 days from now |
      | location   | Rooftop Bar     |

  @wip 
  Scenario: View upcoming events for this week
    Given today is a Monday in the current week
    And the user "Chad" has events:
      | name          | event_date      |
      | Beer oclock   | this Wednesday  |
      | Game night    | next month      |
      | Movie night   | this Friday     |
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
