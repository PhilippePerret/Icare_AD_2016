# encoding: UTF-8
=begin

  Script pour récupérer les données des modules absolus

  @usage :

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/abs_modules.rb'

=end
require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/modules_abs.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe
request = "DROP TABLE IF EXISTS absmodules"
site.db_execute(:modules, request, {online: false})
site.db_execute(:modules, request, {online: true})

# La table online
table_online  = site.dbm_table(:modules, 'absmodules', online = true)
table_offline = site.dbm_table(:modules, 'absmodules', online = false)

# Boucle sur toutes les données
# -----------------------------
request = 'SELECT * FROM modules_data'
dbase_old.results_as_hash = true
dbase_old.execute(request).each do |row|
  row = row.to_sym
  # debug row.inspect

  newrow = Hash.new

  # On corrige les différences
  [:id, :module_id, :name, :tarif, :description_longue, :description_courte,
    :nb_jours, :hduree,
  :created_at, :updated_at].each do |oldk|

    # Transformation de la clé
    newk =
      case oldk
      when :description_longue  then :long_description
      when :description_courte  then :short_description
      when :nb_jours            then :nombre_jours
      else oldk
      end

    # Transformation de la valeur
    newvalue =
      case oldk
      when :module_id then row[:module_id][1..-1]
      else
        case row[oldk]
        when "NULL" then nil
        else row[oldk]
        end
      end


    newrow.merge!(newk => newvalue)

  end
  # /fin de boucle sur chaque propriété

  # On ajoute la donnée dans la base locale
  table_offline.insert(newrow)
  # On ajoute la donnée dans la base distante
  table_online.insert(newrow)

  debug newrow.pretty_inspect

end
# /Fin de boucle sur chaque donnée
