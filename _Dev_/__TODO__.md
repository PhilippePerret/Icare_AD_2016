* mailnoiduzep@chez.com / monmotdepasse
* Nicolas Dufourg   : crapette
* Emmanuelle Badina : crapette

* IMPÉRATIF : Le mail de refus doit être envoyé à l'user, pas à moi
* IMPÉRATIF : Mise en page pour horribles PC (citation ne comprend même pas la propriété inherit de couleur + les div font n'importe quoi, comme toujours sur windows — cf. avec l'ordinateur merdique de la petite Marion)
* IMPÉRATIF : Cron job pour actualités (POURSUIVRE)
* IMPÉRATIF : Implémenter le watcher de changement d'étape


* Ne mettre l'outil "check synchro" qu'en OFFLINE

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

## À FAIRE AVANT L'OUVERTURE

* Récupérer les données de la MINI-FAQ des étapes
* Récupérer tous les documents du Quai des docs
* Reprendre tous les users
* Reprendre tous les paiements pour injecter la table paeiements (User.table_paiements)
* Reprendre tous les icmodules, icetapes et icdocuments

## FONCTIONNALITÉS

* Ajout de jours gratuits

## À FAIRE APRÈS L'OUVERTURE

* Mettre au point un petit déctecteur de — pas de fumée — d'incompatibilité au niveau des données de modules (notamment les abs_module_id) en fonction des étapes et des documents, et proposer des corrections à adopter ou non.

* TODO Installer le QUAI DES DOCS
  - affichage des documents par trimestre
  - recherche de documents

* TODO Installer le cron-job
  - suppression des dossiers tmp/download assez vieux (1 mois)

* TODO Installer la partie historique du bureau

* TODO ADMIN Outil assisté pour instancier des watchers (en prenant les objets possibles et les processus possibles)
