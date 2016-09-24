# Utilisateur

* [Procédure de paiement](#paiement)


<a name='paiement'></a>

## Procédure de paiement

La procédure de paiement est un watcher un peu spécial : le formulaire de paiement appelle `ic_paiement/main` au lieu de la route traditionnelle pour runner le watcher, l'user procède au paiement et en cas de succès, le watcher est runné pour être terminé (et principalement : envoi des mails à l'user et à l'administrateur, création du watcher suivant si nécessaire et destruction du watcher).
