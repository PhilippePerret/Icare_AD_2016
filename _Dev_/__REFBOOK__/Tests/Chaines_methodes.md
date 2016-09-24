# Chaines méthodes

* [Méthodes de test pour les mails](#methodesdetestsmails)
* [Les messages](#lesmessages)
  * [Message flash (notice)](#messageflash)
  * [Message d'erreur flash](#messagederreurnoramle)
  * [Message d'erreur fatal](#messagederreurfatail)

* [Méthodes de mail](#methodesdemail)
<a name='methodesdemail'></a>

## Méthodes de mail

~~~

  Phil recoit le mail <Hash data mail>[,
    success: '<message de succès>']

~~~

~~~

  Benoit recoit le mail <Hash data mail>

~~~

Si c'est un autre user qui doit être utilisé, il faut l'instancier de cette manière pour qu'il puisse être un `Someone` de test.

~~~

  def Lui chaine
    Someone.new({user_id: <id>, pseudo: '<son pseudo>'}, chaine).evaluate
  end

~~~

Puis on l'utilise normalement :

~~~

  Lui recoit un mail <data>
  
~~~



<a name='methodesdetestsmails'></a>

## Méthodes de test pour les mails

Pour les mails, il faut initialiser un `Someone` avec l'identifiant de l'utilisateur :

    def Newu chaine
      Somenone.new({user_id: @<id du user>}, chaine).evaluate
    end
    # Penser que @<id du user> doit être accessible, donc soit une
    # méthode soit une variable d'instance.

Puis on peut appeler la méthode :

    data_mail = { .... }
    Newu recoit le mail data_mail


<a name='lesmessages'></a>

## Les messages

<a name='messageflash'></a>

### Message flash (notice)

    La feuille affiche le message "<le message>"

    La feuille n affiche pas le message "<le message>"

<a name='messagederreurnoramle'></a>

### Message d'erreur flash

    La feuille affiche le message erreur "<le message>"

    La feuille n affiche pas le message erreur "<le message>"

<a name='messagederreurfatail'></a>

### Message d'erreur fatal

    La feuille affiche le message fatal "<le message>"

    La feuille n affiche pas de message fatal
