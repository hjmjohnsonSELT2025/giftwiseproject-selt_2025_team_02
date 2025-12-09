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
    And I fill in "Event date" with "2030-11-28"
    And I fill in "Event time" with "22:00"
    And I fill in "Location" with "Downtown"
    And I fill in "Budget" with "50"
    And I press "Create Event"
    Then I should see "Event 'Beer oclock' successfully created." within the flash
    And I should see "Beer oclock"
    And I should see "2030-11-28"
    And I should see "Downtown"
    And I should see "$50.00"
    And the event "Beer oclock" should have:
      | event_date | 2030-11-28 |
      | event_time | 22:00      |
      | location   | Downtown   |
      | budget     | 50         |

  @happy_path
  Scenario: Edit an event
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following events exist for this user:
      | name        | event_date | event_time | location | budget |
      | Beer oclock | 2030-11-28 | 22:00      | Downtown | 50     |
    And I am on the events page
    When I edit the event "Beer oclock"
    And I fill in the event date with "2030-12-01"
    And I fill in "Location" with "Rooftop Bar"
    And I press "Update Event"
    Then I should see "Event 'Beer oclock' successfully updated." within the flash
    And I should see "Beer oclock"
    And I should see "Rooftop Bar"
    And the event "Beer oclock" should have:
      | event_date | 2030-12-01 |
      | location   | Rooftop Bar |

  @happy_path
  Scenario: Delete an existing event
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following events exist for this user:
      | name        | event_date | event_time | location | budget |
      | Beer oclock | 2030-11-28 | 22:00      | Downtown | 50     |
    And I am on the events page
    When I follow "Delete"
    Then I should be on the events page
    And I should see "Event 'Beer oclock' deleted." within the flash
    And I should not see "Beer oclock" in the events list

  @happy_path
  Scenario: Add recipient to an event
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following recipients exist for this user:
      | name | age | gender | relation |
      | Thad | 25  | male   | Bro      |
      | Brad | 26  | male   | Bro      |
    And the following events exist for this user:
      | name        | event_date | event_time | location  | budget |
      | Beer oclock | 2030-11-28 | 22:00      | Downtown | 50     |
    And I am on the events page
    When I follow "Beer oclock"
    And I select "Thad" from "Choose a recipient"
    And I press "Add to Event"
    Then I should see "Recipient 'Thad' successfully added to 'Beer oclock'." within the flash
    And I should see "Thad" in the recipients section

  @happy_path
  Scenario: Remove recipient from an event
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following recipients exist for this user:
      | name | age | gender | relation |
      | Thad | 25  | male   | Bro      |
      | Brad | 26  | male   | Bro      |
    And the following events exist for this user:
      | name        | event_date | event_time | location  | budget |
      | Beer oclock | 2030-11-28 | 22:00      | Downtown | 50     |
    And I am on the events page
    When I follow "Beer oclock"
    And I select "Thad" from "Choose a recipient"
    And I press "Add to Event"
    And I follow "Remove" within the "Thad" row
    Then I should see "Recipient 'Thad' successfully removed from 'Beer oclock'." within the flash
    And I should not see "Thad" in the recipients section

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

  @happy_path
  Scenario: Create an event with extra info
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And I am on the events page
    When I follow "Add New Event"
    And I fill in "Event name" with "Christmas with the bros"
    And I fill in "Event date" with "2030-12-25"
    And I fill in "Event time" with "18:00"
    And I fill in "Location" with "Chad's pad"
    And I fill in "Budget" with "200"
    And I fill in "Additional Event Information (optional)" with "Bro gift exchange, matching jammies, Mariah Carey tunes, peppermint mocha."
    And I press "Create Event"
    Then I should see "Event 'Christmas with the bros' successfully created." within the flash
    And I should see the additional event info "Bro gift exchange, matching jammies, Mariah Carey tunes, peppermint mocha."
    And the event "Christmas with the bros" should have extra info "Bro gift exchange, matching jammies, Mariah Carey tunes, peppermint mocha."

  @happy_path
  Scenario: Create an event without extra info (section stays hidden)
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And I am on the events page
    When I follow "Add New Event"
    And I fill in "Event name" with "Christmas with the bros"
    And I fill in "Event date" with "2030-12-25"
    And I fill in "Event time" with "18:00"
    And I fill in "Location" with "Chad's pad"
    And I fill in "Budget" with "200"
    And I press "Create Event"
    Then I should see "Event 'Christmas with the bros' successfully created." within the flash
    And I should not see the additional event info section
    And the event "Christmas with the bros" should have no extra info

  @happy_path
  Scenario: Edit an event to add extra info
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following events exist for this user:
      | name                    | event_date  | event_time | location    | budget |
      | Christmas with the bros | 2030-12-25  | 18:00      | Chad's pad  | 200    |
    And I am on the events page
    When I click the event edit link

    And I fill in "Additional Event Information (optional)" with "Bro gift exchange, matching jammies, Mariah Carey tunes, peppermint mocha."
    And I press "Update Event"
    Then I should see "Event 'Christmas with the bros' successfully updated." within the flash
    And I should see the additional event info "Bro gift exchange, matching jammies, Mariah Carey tunes, peppermint mocha."
    And the event "Christmas with the bros" should have extra info "Bro gift exchange, matching jammies, Mariah Carey tunes, peppermint mocha."

  @happy_path
  Scenario: Edit an event to clear extra info (hide section again)
    Given I am logged in as "chad_bro_chill@fakemail.com" with password "lowkeybussin"
    And there are no previous events for this user
    And the following events exist for this user:
      | name                    | event_date  | event_time | location    | budget | extra_info                                                                 |
      | Christmas with the bros | 2030-12-25  | 18:00      | Chad's pad  | 200    | Bro gift exchange, matching jammies, Mariah Carey tunes, peppermint mocha. |
    And I am on the events page
    When I click the event edit link

    And I fill in "Additional Event Information (optional)" with ""
    And I press "Update Event"
    Then I should see "Event 'Christmas with the bros' successfully updated." within the flash
    And I should not see the additional event info section
    And the event "Christmas with the bros" should have no extra info

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
