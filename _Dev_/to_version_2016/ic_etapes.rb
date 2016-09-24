# encoding: UTF-8
=begin

  Script pour récupérer les données des ic-modules

  @usage :

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/ic_etapes.rb'

=end
# Par défaut, on ne réactualise pas toute cette table, car
# elle est longue
RETRY       = false
FIRST_ITEM  = 401 #401
LAST_ITEM   = 620 # 610 # par 200, ça passe

# Si true, on n'enregistre pas dans la base de données. C'est intéressant
# lorsqu'il faut faire des essais sur les données avant de les enregistrer
DO_NOT_SAVE = false


# Si true, on n'actualise que les étapes qui n'ont pas été marquées
# finies (pas par le status, qui peut être resté à 5, mais par le
# ended_at)
ONLY_NOT_ENDED = false

# Fichier pour enregistrer des changements à faire manuellement
rf = File.open('./_Dev_/to_version_2016/changements_manuels.txt','a')


require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/modules.db'
dbase_old = SQLite3::Database.new(pathold)

drop_the_tables =
  if ONLY_NOT_ENDED
    false
  elsif FIRST_ITEM != nil
    FIRST_ITEM && FIRST_ITEM == 1
  else
    !RETRY
  end

if drop_the_tables
  # On détruit la nouvelle table si elle existe
  request = "DROP TABLE IF EXISTS icetapes"
  site.db_execute(:modules, request, {online: false})
  site.db_execute(:modules, request, {online: true})
end

# La table online
table_online  = site.dbm_table(:modules, 'icetapes', online = true)
table_offline = site.dbm_table(:modules, 'icetapes', online = false)


if drop_the_tables
  table_online.create   rescue nil
  table_offline.create  rescue nil
end

#
# # Map avec en clé l'identifiant ancien du module, par exemple 'suivi_lent'
# # et en valeur le nouvelle identifiant nombre (p.e. 10)
# MODULE_ID_2_ID = Hash.new
# site.dbm_table(:modules, 'absmodules').select(colonnes: [:module_id, :id]).each do |hmod|
#   MODULE_ID_2_ID.merge!(hmod[:module_id] => hmod[:id])
# end
# debug "MODULE_ID_2_ID : #{MODULE_ID_2_ID.pretty_inspect}"

# Boucle sur toutes les données
# -----------------------------
request = 'SELECT * FROM etapes'
dbase_old.results_as_hash = true
all_old_rows = dbase_old.execute(request)

nombre_total_items    = all_old_rows.count
nombre_items_traited  = 0

all_old_rows.each do |row|
  row = row.to_sym
  # debug row.inspect

  if RETRY
    # Si la donnée existe déjà online, on passe cette donnée
    h = table_online.get(row[:id])
    if h != nil
      # Si la date d'actualisation n'a pas changé, on peut passer
      # cette donnée
      if h[:updated_at] == row[:updated_at]
        debug "Rangée ##{row[:id]} laissée telle quelle."
        next
      end
    end
  elsif ONLY_NOT_ENDED
    # On passe les étapes qui ont leur ended_at défini
    row[:ended_at] =
      case row[:ended_at]
      when nil, "NULL", 0, '0' then nil
      else row[:ended_at]
      end
    # debug "row[:ended_at] : #{row[:ended_at].inspect}"
    row[:ended_at] == nil || next
  elsif FIRST_ITEM && LAST_ITEM && (row[:id] < FIRST_ITEM || row[:id] > LAST_ITEM)
    next
  end

  newrow = Hash.new

  # On corrige les différences
  [ :id, :user_id, :icmodule_id,
    :num_etape, :wpropre, :statut,
    :documents,
    :started_at, :ended_at, :updated_at,
    :expected_end, :expected_comments,
  ].each do |oldk|

    # Transformation de la clé si nécessaire
    newk =
      case oldk
      when :anycleold then :versclenew
      when :num_etape then :numero
      when :wpropre   then :travail_propre
      when :statut    then :status
      else oldk
      end

    # Transformation de la valeur si nécessaire
    newvalue =
      if row[oldk].instance_of?(String)
        case row[oldk]
        when "NULL", '', '[]', [] then nil
        else row[oldk]
        end
      else
        row[oldk]
      end

    newvalue =
      case oldk
      when :documents
        if newvalue
          JSON.parse(newvalue).join(' ')
        else
          nil
        end
      when :wpropre
        if newvalue.instance_of? String
          newvalue = newvalue.gsub(/\r\n/,"\n")
        end
        newvalue
      else
        newvalue
      end

    if newvalue.instance_of?(String)
      newvalue =
        case newvalue
        when "NULL", '', '[]', [] then nil
        else newvalue
        end
    end


    newrow.merge!(newk => newvalue)

  end
  # /fin de boucle sur chaque propriété

  # Compléter la donnée
  newrow[:updated_at]   ||= Time.now.to_i
  newrow[:expected_end] ||= newrow[:started_at] +  7.days

  if newrow[:numero] == 999
    newrow[:numero] = 990
  end

  # ID absolu de l'étape de travail
  # On la trouve avec la combinaison du numéro de l'étape et
  # l'identifiant du module absolu
  num =
    case newrow[:id]
    when 26           then 10
    when 53, 107, 279, 388 then 50
    when 282          then 76
    when 424          then 80
    when 390          then 85
    when 392          then 140
    when 285, 391     then 990
    else newrow[:numero]
    end

  icmod   = newrow[:icmodule_id]
  amod_id = dbtable_icmodules.get(icmod)[:abs_module_id]


  case newrow[:id]
  when 393, 394
    # newrow[:module_id] = 7
    amod_id = 7 # au lieu de 4
    rf.write "abs_module_id de icmodule ##{icmod} doit être passé de 4 à 7\n"
  when 395
    amod_id = 8 # au lieu de 4
    rf.write "abs_module_id de icmodule ##{icmod} doit être passé de 4 à 8\n"
  when 448, 449, 450
    amod_id = 6
    rf.write "abs_module_id de icmodule ##{icmod} doit être passé de 4 à 6\n"
  end

  # Cas de la dernière étape
  if newrow[:numero] == 9990
    num = newrow[:numero] = 990
    # Si cette donnée absolu d'étape n'existe pas, il faut la
    # créer
    if dbtable_absetapes.count(where:{numero: 990, module_id: amod_id}) == 0
      dabsetape = {
        numero:     990,
        titre:      'Fin de module',
        module_id:  amod_id,
        travail:    "<%= travail_type 'modules', 'debriefing_fin_module' %>",
        duree:      10,
        objectif:   nil,
        created_at:  Time.now.to_i,
        updated_at:  Time.now.to_i
      }
      site.dbm_table(:modules, 'absetapes', false).insert(dabsetape)
      site.dbm_table(:modules, 'absetapes', true).insert(dabsetape)
    end
  end


  drequest = {
    where: {numero: num, module_id: amod_id},
    # where: "numero = #{num} AND module_id = #{amod_id}",
    colonnes: []
  }
  data_abs_eta  = dbtable_absetapes.select(drequest)
  data_abs_eta.count > 0 || begin
    debug "\n\nDONNÉES ERRONÉES : #{newrow.pretty_inspect}"
    raise "Impossible de trouver les données de l'étape absolue à partir de #{drequest.inspect} (id = #{newrow[:id]})"
  end
  abs_etape_id  = data_abs_eta.first[:id]
  abs_etape_id != nil || begin
    raise "Impossible d'obtenir l'abs_etape_id de #{newrow.inspect}…"
  end
  newrow.merge!(abs_etape_id: abs_etape_id)

  if ONLY_NOT_ENDED
    # Si l'item existe, il faut le détruire
    rowid = newrow[:id]
    if table_offline.count(where: {id: rowid}) > 0
      table_offline.delete(rowid)
    end
    if table_online.count(where: {id: rowid}) > 0
      table_online.delete(rowid)
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
      if newrow.key?(:methode)
        debug "\n# RETRAIT DE LA MÉTHODE POUR ESSAYER"
        lamethode = newrow.delete(:methode)
        # ON l'enregistre dans un fichier pour pouvoir la remettre
        pfile = "./xprev_version/methode_#{newrow[:id]}.txt"
        File.open(pfile,'w'){|f| f.write lamethode}
        retry
      end
    end
  end
  nombre_items_traited += 1

  # debug "\n\nNEW ROW ICMODULE : #{newrow.pretty_inspect}"
  # break # pour seulement essayer

end
# /Fin de boucle sur chaque donnée

if ONLY_NOT_ENDED
  flash "Seules les icétapes avec un ended_at non défini ont été actualisées (sinon il y en a trop). #{nombre_items_traited} icetapes traitées."
elsif FIRST_ITEM && LAST_ITEM
  flash "Élements ajoutés de #{FIRST_ITEM} à #{LAST_ITEM} sur #{nombre_total_items}"
end
