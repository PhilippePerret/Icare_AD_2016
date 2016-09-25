

N0001

    Maintenant, c'est sur la boite à outils qu'on peut
    consulter les pages de narration. On va essayer de se
    servir de la session pour vérifier que l'user peut visiter
    la page normalement, en envoyant dans l'url l'identifiant
    de l'user.

    Note : l'ID de la page doit correspondre au vrai identifiant
    sur la collection. Le titre doit être mis, il ne peut plus
    être récupéré.

    On envoie dans l'adresse les informations sur  l'icare afin
    de pouvoir créer son profil s'il n'existe pas. Mais seulement
    s'il est actif.


N0002

    On écarte tous les documents d'inscription, qu'on reconnait au
    fait que leur abs_module_id est à 0.

    Noter qu'on pourrait mettre cette condition dans la clause where,
    mais on ne sait pas si le filtre va fonctionner en Hash ou en
    String.
