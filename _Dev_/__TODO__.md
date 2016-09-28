* mailnoiduzep@chez.com / monmotdepasse
* Nicolas Dufourg   : crapette
* Emmanuelle Badina : crapette

## BUGS

* Impossible de trouver le travail-type défini par :
    Rubrique   : histoire
    Short_name : hors_champ_narratif
    Défini pour l'étape absolue d'ID : 119

* Impossible de trouver le travail-type défini par :
    Rubrique   : structure
    Short_name : listing_brins
    Défini pour l'étape absolue d'ID : 117

* Inscription : corriger la fabrication d'un user vide
  - Mais surtout : s'arranger pour que l'user soit "fabriqué" seulement à la fin de l'opération.
  => On enregistre toutes ses données dans un fichier temporaire, avant de les injecter dans la base finale.
* Les documents QDD de l'étape ne semblent pas s'afficher
* À l'inscription, ça crée un user vide en plus
* Le mailing list ne vise pas les icariens qu'il devrait viser (tous sont contactés chaque fois)
* Ne pas pouvoir envoyer deux documents de même nom (dans le travail de l'étape)
* Objectif en double dans l'étape 5 du suivi lent (normal #7)
  => Quand l'objectif est le même que l'objectif du travail type, ne pas l'indiquer.

## Fonctionnalités impératives

* Définition des mails qu'on veut recevoir (Ne recevoir aucun mail)
* Définition de la route à prendre après l'identification

## DIVERS

* Pouvoir laisser un message sur le bureau de l'icarien (il faut que ses options le permettent)

* Pour les citations, plutôt que de les charger chaque fois, pour accélérer, charger 20 citations pour la journée et les faire "tourner" à chaque chargement de l'accueil.

* L'option 17 (18e bit) doit servir à ne recevoir aucun mail de l'atelier, jamais (même les mails par la mailing list)
  - C'est déjà réglé pour la mailing-list, mais il faut le faire pour le reste (cron actualités, autres ?)

* Faire un javascript qui permette de supprimer la notification pour les
  download (mais seulement pour l'administrateur).

* IMPÉRATIF : Cron job pour actualités (POURSUIVRE)

* Pour le bouton "Documents" de l'icarien, il faudra que ça mène vraiment à une liste bureau/documents, pas au quai des docs
  - possibilité de recharger les derniers commentaires (ils sont détruits un mois après leur émission, ou quand le document QDD est déposé)
  -  indication que les documents ne présentation ne sont pas déposés sur le quai des docs
* Un user se crée "dans le vide" lorsqu'il y a une inscription, voir pourquoi.
* La SYNCHRONISATION ne fonctionne pas (offline -> online)

* Pour le moment, je ne prends que le travail du travail-type (les titres et les objectifs sont déjà rassemblés). Il faut faire un traitement pour obtenir la méthode. En fait, elle peut être "ramassée" en construisant le travail puisqu'elle sera affichée après.
* Faire un watcher admin pour le paiement, qui n'est affiché que lorsque l'icarien doit payer.
* Dans le bureau admin, regrouper les watchers par user (il suffit de les relever dans la base en les ordonnant par user_id).
* Ajouter le QDD aux outils de l'icarien
* QDD Poursuivre le set_cote.rb
* QDD Construire le processus 'quai_des_docs/cote_et_commentaire'. La notification de l'user doit conduire à une page où il peut donner une note et laisser un commentaire sur le document.

  - Attribution des cotes pour les documents (changement)
* Finir le notify pour annuler une commande de module (côté user) (pour le moment, il n'y a que le bouton)

* Le lien "Historique" doit simplement présenter la partie si l'icarien est tout jeune à l'atelier
* TODO Voir la procédure à adopter pour le fichier ./objet/bureau/lib/module/section_current_work/helper_abs.rb qui doit permettre à un icarien actif.
* Dans le cronjob, vérifier les watchers de paiements. Si certains sont trop en retard => envoyer des mails (user et admin) et renseigner les data du watcher pour indiquer que les mails sont envoyés. Indiquer à l'administrateur qu'il faut détruire n icarien trop en dépassement (faire un watcher icarien/destroy)
* Faire la page Facebook de l'atelier
* Cron de nettoyage pour supprimer les documents téléchargés (dossier ./tmp/download/user-xxx/). On peut vérifier que les documents ont bien été téléchargés avec la propriété options des documents (3e et 11e bit)
* Édition des watchers : relever tous les processus existants pour avoir les 'objet' possibles et les 'processus' possibles. De la même manière, au cours de l'édition, relever en Ajax les identifiants (quand on est dans le champ user_id => relever les id/pseudo des users, quand on est dans objet_id => relever les id/propriétaires de l'objet choisi)

## Visite comme user

### En se servant des variables sessions :

    Je mets 'admin_visit_as' dans la session, avec l'ID de l'user
    Quand l'application détecte au login cette variable :
      Elle cherche un fichier _adm qui contient :
        l'IP courante
        Le numéro de session
      Si tout matche

    À la déconnexion, on détruit le fichier _adm

## CRON-JOB

* Vérifier les icmodules non démarrés (options[0]==0) depuis trop longtemps (created_at < Time.now.to_i - 1.month). Envoyer d'abord une alerte, puis une mois après le détruire.
* Définition automatique du partage des documents
  Penser à faire une annonce actualité même pour ce partage automatique, mais en modifiant le nom (au lieu de "Untel met en partage ses documents…", dire "Les documents de Untel sont mis en partage")


## FONCTIONNALITÉS URGENTES


## À FAIRE APRÈS L'OUVERTURE

* Procédure pour déposer une question minifaq
* Mettre au point un petit déctecteur de — pas de fumée — d'incompatibilité au niveau des données de modules (notamment les abs_module_id) en fonction des étapes et des documents, et proposer des corrections à adopter ou non.

* TODO Installer le QUAI DES DOCS
  - affichage des documents par trimestre
  - recherche de documents

* TODO Installer le cron-job
  - suppression des dossiers tmp/download assez vieux (1 mois)

* TODO Installer la partie historique du bureau

* Une section du bureau administrateur qui présente l'état des icariens (un aperçu général).
