Feature: Get gift suggestions for gift recipient
  As an organized gift giver
  So that I can get quality gifts for someone I want to give gift(s) to
  I want to receive gift suggestions from an LLM based on my gift recipient's background

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And the following recipients exist for this user:
      | name        | age | gender | relation    | likes    | dislikes |
      | Grandma Joy | 70  | female | Grandmother | knitting | spiders  |
    And I am on the recipients page

  @happy_path
  Scenario: Generate gift ideas for an existing recipient
    Given the AI service will return "Knitting Kit"
    When I follow "Grandma Joy"
    And I click "Ask Giftwise AI Assistant for Gift Ideas"
    Then I should see "Gift Ideas Based on user profile"
    And I should see "Knitting Kit"
    And I should see "Because she likes knitting"
    And I should see "Back to Recipients"
    And I should see "Back to Home"

  @sad_path
  Scenario: Handle failure when AI service is down
    Given the OpenAI service is currently down
    When I follow "Grandma Joy"
    And I click "Ask Giftwise AI Assistant for Gift Ideas"
    Then I should see "Could not generate gifts"
    And I should not see "Gift Ideas Based on user profile"
