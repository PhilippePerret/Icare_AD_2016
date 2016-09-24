# encoding: UTF-8
=begin

  Script pour récupérer les données des étapes absolues

  @usage :

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/abs_travaux_type.rb'

=end
require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/modules_abs.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe
request = "DROP TABLE IF EXISTS abs_travaux_type"
site.db_execute(:modules, request, {online: false})
site.db_execute(:modules, request, {online: true})

# La table online
table_online  = site.dbm_table(:modules, 'abs_travaux_type', online = true)
table_offline = site.dbm_table(:modules, 'abs_travaux_type', online = false)

# Boucle sur toutes les données
# -----------------------------
request = 'SELECT * FROM travaux_types'
dbase_old.results_as_hash = true
dbase_old.execute(request).each do |row|
  row = row.to_sym
  # debug row.inspect

  newrow = Hash.new

  # On corrige les différences
  [ :id, :rubrique, :titre,
    :objectif, :travail,
    :methode, :liens
  ].each do |oldk|

    # Transformation de la clé si nécessaire
    newk =
      case oldk
      when :id then :short_name
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
  end

  # debug "\n\nNEW_ROW : #{newrow.pretty_inspect}"
  # break # pour seulement essayer

end
# /Fin de boucle sur chaque donnée
