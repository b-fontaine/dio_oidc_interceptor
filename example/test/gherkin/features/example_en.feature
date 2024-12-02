Feature: example
  Test of example features

  Scenario: I log in
    Given I have successfully launched the application
    When I click on the button {'Go to login'}
    And I click on the button {'Local connect with default login (admin/admin)'}
    Then I see the text {'dio_oidc_interceptor: logout'}

  Scenario: I log out
    Given I have successfully launched the application
    When I click on the button {'Go to login'}
    And I click on the button {'Local connect with default login (admin/admin)'}
    And I click on the button {'Log out and return to login'}
    Then I see the text {'dio_oidc_interceptor: login'}
