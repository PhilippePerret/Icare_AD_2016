# encoding: UTF-8
=begin
  Module de récupération des users à partir de la table SQLite3

  NOTE : Ce module doit être utilisé juste avant de mettre définitivement
  l'atelier en RestFull. Il faut :
    - copier le fichier storage/db/archives.db distant dans le
      dossier ./xprev_version/db/
    - décocher dans site/home.rb la ligne lançant la récupération des
      users, décrite ci-dessous
    - rejoindre l'accueil en local
    => Les deux tables, locales et distantes, se peuplent avec les
       toute dernières données

  @usage

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/paiements.rb'

=end
require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/archives.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe pour repartir
# complète à zéro
request = "DROP TABLE IF EXISTS paiements"
site.db_execute(:users, request, {online: false})
site.db_execute(:users, request, {online: true})

# exit 0

# La table online
table_online  = site.dbm_table(:users, 'paiements', online = true)
table_offline = site.dbm_table(:users, 'paiements', online = false)


table_online.create rescue nil
table_offline.create


# Boucle sur toutes les données
# -----------------------------
request = 'SELECT * FROM paiements;'
dbase_old.results_as_hash = true
dbase_old.execute(request).each do |row|
  row = row.to_sym
  # debug row.inspect

  newrow = Hash.new

  # On corrige les différences
  [ :id, :user_id, :icmodule_id, :montant, :at, :invoice
  ].each do |oldk|

    # Transformation de la clé si nécessaire
    newk =
      case oldk
      when :aucunecle then :autrecle
      when :at        then :created_at
      when :invoice   then :facture
      else oldk
      end

    # Transformation de la valeur si nécessaire
    newvalue =
      case oldk
      when :aucunecledefinie then nil
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
    updated_at:  newrow[:created_at]
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
  end

  # debug "\n\nNEW_ROW : #{newrow.pretty_inspect}"
  # break # pour seulement essayer

end
# /Fin de boucle sur chaque donnée
