Contrairement au traitement des modules habituel, chaque fichier de ce dossier est appelé individuellement selon l'opération à exécuter.

Cf. le fichier `./objet/admin/users.rb`

Pour créer un nouvel outil :

* Créer son fichier ruby dans son dossier. L'affixe du fichier doit être l'identifiant de la méthode (par exemple `pause_module`)
* Créer dans ce fichier ruby une méthode de classe de `Admin::Users` qui porte le nom `exec_<identifiant méthode>`
* Dans le fichier `./objet/admin/users.rb` ajouter au tableau des outils cet outil. Si l'outil a besoin d'un champ court, moyen ou long, il faut respectivement définir le texte de `:short_value`, `:medium_value` ou `:long_value`, qu'on peut appeler dans la méthode `exec_...` par ces mêmes noms (`short_value`, `medium_value`, `long_value`)
