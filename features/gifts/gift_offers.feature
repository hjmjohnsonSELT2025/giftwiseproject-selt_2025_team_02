Feature: Manage purchase options for gifts
  As a gift giver
  So that I can find the best place to buy each gift
  I want to add purchase options (store, price, link) to gifts on my gift lists

  Background:
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com" with password "password123"
    And there are no recipients for this user
    And there are no gift lists
    And there are no gifts
    And a recipient "Thad" exists for this user
    And a gift list "Birthday Wishlist" exists for "Thad"
    And a gift "Nike socks" exists on the "Birthday Wishlist" gift list
    And I am on the "Birthday Wishlist" gift list page

  @happy_path
  Scenario: Add a purchase option to an existing gift
    When I view the gift "Nike socks" from the "Birthday Wishlist" gift list
    And I follow "Add Purchase Option"
    And I fill in "Store name" with "Target"
    And I fill in "Price" with "12.99"
    And I fill in "URL" with "https://www.target.com/nike-socks"
    And I fill in "Rating" with "4.5"
    And I press "Create Purchase Option"
    Then I should be on the gift detail page for "Nike socks"
    And I should see "Target"
    And I should see "$12.99"
    And 1 purchase option should exist for the gift "Nike socks"
