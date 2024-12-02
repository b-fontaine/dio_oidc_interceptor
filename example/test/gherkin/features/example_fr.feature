Feature: example
  Test des fonctionnalités de l'exemple

  Scenario: Je me connecte
    Given J'ai lancé l'application avec succès
    When Je clique sur le bouton {'Go to login'}
    And Je clique sur le bouton {'Local connect with default login (admin/admin)'}
    Then Je vois le texte {'dio_oidc_interceptor: logout'}

  Scenario: Je me déconnecte
    Given J'ai lancé l'application avec succès
    When Je clique sur le bouton {'Go to login'}
    And Je clique sur le bouton {'Local connect with default login (admin/admin)'}
    And Je clique sur le bouton {'Log out and return to login'}
    Then Je vois le texte {'dio_oidc_interceptor: login'}
