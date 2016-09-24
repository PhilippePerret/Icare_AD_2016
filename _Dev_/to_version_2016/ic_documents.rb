# encoding: UTF-8
=begin
  Module de récupération des documents à partir de la table SQLite3

  NOTE : Ce module doit être utilisé juste avant de mettre définitivement
  l'atelier en RestFull. Il faut :
    - copier le fichier storage/db/documents.db distant dans le
      dossier ./xprev_version/db/
    - décocher dans site/home.rb la ligne lançant la récupération des
      users, décrite ci-dessous
    - rejoindre l'accueil en local
    => Les deux tables, locales et distantes, se peuplent avec les
       toute dernières données

  @usage

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/ic_documents.rb'

=end
require 'sqlite3'

# Si true, le module n'actualise que les documents qui
# n'avaient pas un time_commented défini (donc logiquement ceux
# en cours)
ONLY_NO_TIME_COMMENTED = false

# Pour faire juste le test pour voir si ça passe
DO_NOT_SAVE = false

# Pour essayer seulement sur la première donnée
TRY_ONLY_ONE = false

# Ancienne base de données SQLite3
pathold = './xprev_version/db/documents.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe pour repartir
# complète à zéro
unless ONLY_NO_TIME_COMMENTED
  request = "DROP TABLE IF EXISTS icdocuments"
  site.db_execute(:modules, request, {online: false})
  site.db_execute(:modules, request, {online: true})
  # PARFOIS, ÇA NE FONCTIONNE PAS EN ONLINE, IL FAUT DÉTRUIRE LA TABLE
  # MANUELLEMENT
end

# exit 0

# La table online
table_online  = site.dbm_table(:modules, 'icdocuments', online = true)
table_offline = site.dbm_table(:modules, 'icdocuments', online = false)

# exit 0

unless ONLY_NO_TIME_COMMENTED
  table_online.create rescue nil
  table_offline.create
end

# Boucle sur toutes les données
# -----------------------------
nombre_items_traited = 0
request = 'SELECT * FROM documents'
dbase_old.results_as_hash = true
all_items = dbase_old.execute(request)
debug "NOMBRE D'ÉLÉMENTS À TRAITER : #{all_items.count}"
# exit 0 # pour connaitre le nombre d'éléments à traiter
all_items.each do |row|
  row = row.to_sym
  # debug row.inspect

  if ONLY_NO_TIME_COMMENTED
    tcom = row[:time_comments]
    if tcom.instance_of?(Fixnum) && tcom > 0
      next
    end
  end

  newrow = Hash.new

  # On corrige les différences
  [ :id, :user_id, :icmodule_id, :icetape_id,
    :original_name, :doc_affixe,
    :time_original, :time_comments,
    :cote_original, :cote_comments,
    :cotes_original, :cotes_comments,
    :readers_original, :readers_comments,
    :expected_comments, :statut,
    # Données récupérées pour construire @options
    :has_original, :has_comments,
    :acces_original, :acces_comments

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

    case oldk
    when :cotes_original, :cotes_comments, :readers_original, :readers_comments
      if newvalue
        newvalue = JSON.parse(newvalue).join(' ')
      end
    end

    newrow.merge!(newk => newvalue)

  end
  # /fin de boucle sur chaque propriété

  # Construction des options
  statut  = newrow.delete(:statut).to_i
  # DOCUMENT_SENT       = 1
  # DOCUMENT_GETTED     = 2
  # DOCUMENT_COMMENTED  = 4
  # DOCUMENT_QDDED      = 8
  # DOCUMENT_COMPLETED  = 16 # si changé, modifier le 16 dans cron/cron_qdd

  hasorig = newrow.delete(:has_original).to_i
  hascoms = newrow.delete(:has_comments).to_i
  accorig = newrow.delete(:acces_original).to_i
  acccoms = newrow.delete(:acces_comments).to_i

  bit_qdded         = statut & 8 > 0 ? 1 : 0
  # Partage
  # Sur ancien Icare : 0: non partagé, 1: partagé
  # Sur nouvel Icare : 1: partagé, 2: non partagé
  bit_shared_orig   = accorig > 0 ? 1 : 2
  bit_shared_coms   = acccoms > 0 ? 1 : 2

  bit_complete = (statut & 16 > 0) ? '1' : '0'
  bit_sharing_defined = bit_complete

  if hasorig == 0 && accorig > 0
    hasorig = 1
  end
  if hascoms == 0 && acccoms > 0
    hascoms = 1
  end
  options  = "#{hasorig||'0'}#{bit_shared_orig}1#{bit_qdded}#{bit_sharing_defined}#{bit_complete}00"
  options += "#{hascoms||'0'}#{bit_shared_coms}1#{bit_qdded}#{bit_sharing_defined}#{bit_complete}00"
  options.length == 16 || raise("L'options fait #{options.length} bits au lieu de 16.")

  # Récupération de l'id du module absolu et de l'étape absolue

  data_icmodule = dbtable_icmodules.get(newrow[:icmodule_id])
  data_icmodule != nil || begin
    raise "Impossible d'obtenir les données de l'ic-module #{newrow[:icmodule_id]}"
  end
  abs_module_id = data_icmodule[:abs_module_id]
  abs_module_id != nil || begin
    raise 'Impossible d’obtenir l’identifiant du module absolu… (abs_module_id)'
  end
  data_icetape = dbtable_icetapes.get(newrow[:icetape_id])
  data_icetape != nil || begin
    raise "Impossible d'obtenir les données de l'ic-étape #{newrow[:icetape_id].inspect}…"
  end
  abs_etape_id  = data_icetape[:abs_etape_id]
  abs_etape_id != nil || begin
    raise 'Impossible d’obtenir l’identifiant de l’etape absolue (abs_etape_id)'
  end

  # Il faut ajouter les propriétés manquantes
  newrow.merge!(
    options:        options,
    abs_module_id:  abs_module_id,
    abs_etape_id:   abs_etape_id
  )

  if ONLY_NO_TIME_COMMENTED
    did = newrow[:id]
    if table_offline.get(did) != nil
      table_offline.delete(did)
    end
    if table_online.get(did) != nil
      table_online.delete(did)
    end
  end

  unless DO_NOT_SAVE
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
  end

  nombre_items_traited += 1

  debug "\n\nNEW_ROW : #{newrow.pretty_inspect}"

  if TRY_ONLY_ONE
    break # pour seulement essayer
  end

end
# /Fin de boucle sur chaque donnée

if ONLY_NO_TIME_COMMENTED
  flash "Seuls les documents sans temps de commentaires ont été traités (#{nombre_items_traited} documents)."
else
  flash "#{nombre_items_traited} documents ont été traités et injectés dans la base."
end
