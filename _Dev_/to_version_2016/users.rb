# encoding: UTF-8
=begin
  Module de récupération des users à partir de la table SQLite3

  NOTE : Ce module doit être utilisé juste avant de mettre définitivement
  l'atelier en RestFull. Il faut :
    - copier le fichier storage/db/icariens.db distant dans le
      dossier ./xprev_version/db/
    - décocher dans site/home.rb la ligne lançant la récupération des
      users, décrite ci-dessous
    - rejoindre l'accueil en local
    => Les deux tables, locales et distantes, se peuplent avec les
       toute dernières données

  @usage

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/users.rb'

=end
require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/icariens.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe pour repartir
# complète à zéro
request = "DROP TABLE IF EXISTS users"
site.db_execute(:users, request, {online: false})
site.db_execute(:users, request, {online: true})


# La table online
table_offline = site.dbm_table(:users, 'users', online = false)
table_online  = site.dbm_table(:users, 'users', online = true)

# exit(0) # quand ça bug sans raison

table_offline.create
table_online.create
table_offline.exist? || (raise "BORDEL À CUL !!!!!!! LA TABLE OFFLINE N'EXISTE PAS !!!!")


# Boucle sur toutes les données
# -----------------------------
# On commence par récupérer toutes les données complètes pour
# les placer dans un hash que l'on ajoutera ensuite
data_complete = Hash.new
request = 'SELECT * FROM complete_data'
dbase_old.results_as_hash = true
dbase_old.execute(request).each do |row|
  row = row.to_sym
  if row[:id] == 0
    row[:naissance] = 1964
    row[:id] = 1
    row[:patronyme] = 'Philippe Perret'
  end
  goodrow = Hash.new
  row.each do |k, v|
    v =
      case v
      when "NULL", '', '[]' then nil
      else v
      end
    goodrow.merge!(k => v)
  end
  data_complete.merge!(row[:id] => goodrow)
end

request = 'SELECT * FROM icariens;'
dbase_old.results_as_hash = true
dbase_old.execute(request).each do |row|
  row = row.to_sym
  row[:id] != 0 || row[:id] = 1
  # debug row.inspect

  newrow = Hash.new

  # On corrige les différences
  [ :id, :mail, :pseudo, :sexe, :icmodule_id, :date_sortie,
    :session_id
  ].each do |oldk|

    # Transformation de la clé si nécessaire
    newk =
      case oldk
      when :aucunecle then :autrecle
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
  dcomplete_user = data_complete[newrow[:id]]
  dcomplete_user != nil || raise('Les données complètes de l’user ne devraient pas être vides…')
  newrow.merge!(
    salt:        '',
    ip:          dcomplete_user[:ip],
    patronyme:   dcomplete_user[:patronyme],
    cpassword:   dcomplete_user[:cpassword],
    naissance:   dcomplete_user[:naissance],
    created_at:  dcomplete_user[:created_at],
    updated_at:  dcomplete_user[:updated_at]
  )
  # USER_BIT_ESSAI  = 2

  is_real = (row[:state].to_i & 2) == 0

  # Options ajustés
  is_actif = newrow[:icmodule_id] != nil
  # Pour comprendre les options définies dans l'ancien 'options',
  # cf. le fichier ./ruby/_objets/User/model/Preferences/preferences.rb dans
  # ICARE_AD
  opts = "001"
  opts = opts.set_bit(16, is_actif ? '2' : '4' )
  opts = opts.set_bit(24, is_real ? '1' : '0')
  opts += dcomplete_user[:options]
  # Quelquefois, ça déborde
  opts = opts[0..31]

  if newrow[:id] == 1
    opts[0] = '9'
  end

  newrow.merge!(options: opts)

  begin
    # On ajoute la donnée dans la base locale
    table_offline.exist? || (raise "BORDEL DE MERDE ! LA TABLE N'EXISTE PAS ! ")
    table_offline.insert(newrow)
    # On ajoute la donnée dans la base distante
    table_online.exist? || (raise "BORDEL DE MERDE ! LA TABLE ONLINE N'EXISTE PAS ! ")
    table_online.insert(newrow)
  rescue Exception => e
    error "Une erreur est survenue, consulter le débug : #{e.message}"
    debug "\n\n\n# IMPOSSIBLE D'ENTRER UNE DONNÉE : #{e.message}"
    debug "# DONNÉE : " + newrow.pretty_inspect
  end

  # debug "\n\nNEW_ROW : #{newrow.pretty_inspect}"
  # break # pour seulement essayer

end
# /Fin de boucle sur chaque donnée

# On doit ajouter Benoit
require 'digest/md5'
require './data/secret/data_benoit'
pwd = DATA_BENOIT[:password]
cpassword = Digest::MD5.hexdigest("#{pwd}#{DATA_BENOIT[:mail]}")
newrow = {
  id:           DATA_BENOIT[:id],
  pseudo:       DATA_BENOIT[:pseudo], # BenoA car Benoit est pris
  patronyme:    'Benoit Ackerman',
  mail:         DATA_BENOIT[:mail],
  naissance:    1984,
  salt:         '',
  sexe:         'H',
  cpassword:    cpassword,
  options:      DATA_BENOIT[:default_options],
  created_at:   Time.now.to_i,
  updated_at:   Time.now.to_i
}
# On ajoute la donnée dans la base locale
table_offline.insert(newrow)
# On ajoute la donnée dans la base distante
table_online.insert(newrow)
