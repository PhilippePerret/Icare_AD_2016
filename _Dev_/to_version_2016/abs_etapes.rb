# encoding: UTF-8
=begin

  Script pour récupérer les données des étapes absolues

  @usage :

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/abs_etapes.rb'

=end
# La méthode qui pose problème
methode527 = <<-TXT
<%# MODULE SCENARIO - ETAPE 27 - METHODE %><p><b>Pour remettre en forme votre scénario mal formaté</b></p><p>Le plus simple, pour remettre efficacement votre scénario en forme, est d’utiliser cette démarche :</p><h4>1. Suppression de tous les paragraphes vides et les tabulations</h4><p>Imaginons que votre scénario, mis en forme à l’aide de retours de chariot et de tabulations, ait cet aspect (les caractères &para; et &rarr; — tabulation — sont normalement invisibles, mais on peut les faire apparaitre en cochant “Affichage > Caractères non imprimables”) :</p><div style="font-family:courier;"><p></p><p></p><p><b>1. Int. Bureau — Jour</b></p><p></p><p>Une action dans le scénario.</p><p></p><p>Une description courte.</p><p></p><p> &rarr; &rarr; &rarr;NOM DU PERSONNAGE</p><p> &rarr; &rarr; &rarr;Bla bla bla bla bla.</p><p></p><p>Une autre belle description et une action du personnage.</p></div><p>Il faut supprimer tous les &para; seuls sur une ligne et tous les &rarr; jusqu’à ce que le texte ressemble à :</p><div style="font-family:courier;"><p><b>1. Int. Bureau — Jour</b></p><p>Une action dans le scénario.</p><p>Une description courte.</p><p>NOM DU PERSONNAGE</p><p>Bla bla bla bla bla.</p><p>Une autre belle description et une action du personnage.</p></div><h4>2. Création des styles de paragraphe pour un scénario</h4><p>En utilisant le tutoriel mis à votre disposition, définissez tous les styles nécessaires au scénario.</p><p>Pour vous faciliter la tâche, vous pouvez placer votre curseur sur une action/description pour régler ce style, sur un dialogue pour définir le style “Dialogue”, sur un intitulé de scène pour définir le style “Intitulé”, etc.</p><h4>3. Application des styles au scénario</h4><p>Ensuite, il suffit de passer en revue chaque paragraphe et de lui appliquer le style voulu. Ce devrait être chose facile si vous avez défini des raccourcis-clavier.</p><p><b>Ré-utilisation de ces styles pour un autre scénario</b></p><p>Bien entendu, il n’est pas utile de redéfinir tous ces styles chaque fois que vous créez un nouveau scénario. Ce serait idiot… Non, ces styles peuvent être chargés dans n’importe quel autre document.</p><p>Pour ce faire, il existe de nombreuses méthodes :</p><ul><li>Soit (la méthode la plus profitable) vous importez les styles dans votre nouveau document (reportez-vous à l’aide de votre traitement de texte pour savoir comment procéder) ;</li><li>Soit vous définissez ces styles comme des styles communs à tous les documents (idem) </li><li>Soit (la méthode la moins élégante) vous dupliquez dans votre bureau un scénario qui contient les styles définis, vous lui donnez le nom du nouveau scénario, vous l’ouvrez et vous effacez tout le texte de l’ancien scénario pour repartir à zéro ;</li><li>Soit (la méthode la plus élégante) vous créez un modèle de document contenant tous ces styles, modèle qu’il suffit de prendre en référence pour tout nouveau scénario.</li></ul><p>Bon courage pour cette étape, <%= user.pseudo %> !</p>
TXT

require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/modules_abs.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe
request = "DROP TABLE IF EXISTS absetapes"
site.db_execute(:modules, request, {online: false})
site.db_execute(:modules, request, {online: true})

# La table online
table_online  = site.dbm_table(:modules, 'absetapes', online = true)
table_offline = site.dbm_table(:modules, 'absetapes', online = false)

# Map avec en clé l'identifiant ancien du module, par exemple 'suivi_lent'
# et en valeur le nouvelle identifiant nombre (p.e. 10)
MODULE_ID_2_ID = Hash.new
site.dbm_table(:modules, 'absmodules').select(colonnes: [:module_id, :id]).each do |hmod|
  MODULE_ID_2_ID.merge!(hmod[:module_id] => hmod[:id])
end
debug "MODULE_ID_2_ID : #{MODULE_ID_2_ID.pretty_inspect}"

# Boucle sur toutes les données
# -----------------------------
request = 'SELECT * FROM etapes_data'
dbase_old.results_as_hash = true
dbase_old.execute(request).each do |row|
  row = row.to_sym
  # debug row.inspect

  newrow = Hash.new

  # On corrige les différences
  [ :titre, :num_etape, :module_id,
    :objectif, :duree, :duree_max, :travail,
    :travaux, :methode, :liens
  ].each do |oldk|

    # Transformation de la clé si nécessaire
    newk =
      case oldk
      when :num_etape then :numero
      else oldk
      end

    # Transformation de la valeur si nécessaire
    newvalue =
      case oldk
      when :module_id then
        # On remplace l'identifiant string (p.e. 'suivi_lent')
        # en son nombre
        mid = row.delete(:module_id)[1..-1]
        MODULE_ID_2_ID[mid]
      when :num_etape then
        # On corrige les valeurs fausses (9990)
        num_etape = row[:num_etape]
        if num_etape.to_s == '9990' || num_etape.to_s == '999'
          num_etape = 990
          debug "num_etape = #{num_etape}"
        end
        num_etape
      when :methode
        # On corrige une méthode qui passe mal
        if newrow[:module_id] == 5 && newrow[:numero] == 27
          methode527
        else
          row[oldk]
        end
      else
        row[oldk]
      end

    if newvalue.instance_of?(String)
      newvalue =
        case newvalue
        when "NULL", '', '[]' then nil
        else newvalue
        end
    end


    newrow.merge!(newk => newvalue)

  end
  # /fin de boucle sur chaque propriété

  # Il faut ajouter les propriétés manquantes
  newrow.merge!(
    created_at:  Time.now.to_i - 1.year,
    updated_at:  Time.now.to_i
  )

  begin
    # On ajoute la donnée dans la base locale
    table_offline.insert(newrow)
    # On ajoute la donnée dans la base distante
    table_online.insert(newrow)
  rescue Exception => e
    error "Une erreur est survenue, consulter le débug"
    debug "\n\n\n# IMPOSSIBLE D'ENTRER UNE DONNÉE : #{e.message}"
    debug "# DONNÉE : " + newrow.pretty_inspect
    if newrow.key?(:methode)
      debug "\n# RETRAIT DE LA MÉTHODE POUR ESSAYER"
      lamethode = newrow.delete(:methode)
      # ON l'enregistre dans un fichier pour pouvoir la remettre
      pfile = "./xprev_version/methode_#{newrow[:id]}.txt"
      File.open(pfile,'w'){|f| f.write lamethode}
      retry
    end
  end

  # break # pour seulement essayer

end
# /Fin de boucle sur chaque donnée
