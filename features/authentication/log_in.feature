Feature: User log in
  As a returning GiftWise user
  I want to log in with my credentials
  So that I can access my saved friends, gift recipients, and events

  Background:
    Given a user exists with email "chad_bro_chill@notfakemail.com" and password "lowkeybussin"

  @happy_path
  Scenario: Successful log in
    When I go to the log in page
    And I fill in "Email" with "chad_bro_chill@notfakemail.com"
    And I fill in "Password" with "lowkeybussin"
    And I press "Log in"
    Then I should be logged in
    And I should see "Welcome back" within the flash
    And I should be on the home page

  @sad_path
  Scenario: Incorrect password displays error
    When I go to the log in page
    And I fill in "Email" with "chad_bro_chill@notfakemail.com"
    And I fill in "Password" with "chopped"
    And I press "Log in"
    Then I should not be logged in
    And I should see "Incorrect email and/or password" within the flash
    And I should be on the log in page