# encoding: UTF-8
=begin

  Script pour récupérer les données de la minifaq

  @usage :

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/mini_faq.rb'

=end
require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/modules.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe
request = "DROP TABLE IF EXISTS mini_faq"
site.db_execute(:modules, request, {online: false})
site.db_execute(:modules, request, {online: true})

begin
  request = "SELECT 1 FROM mini_faq;"
  site.db_execute(:modules, request, {online: true})
  raise "La table mini_faq ONLINE n'a pas été supprimée. Il faut la supprimer à la main."
rescue
  true
end

# La table online
table_online  = site.dbm_table(:modules, 'mini_faq', online = true)
table_offline = site.dbm_table(:modules, 'mini_faq', online = false)

table_online.create rescue nil
table_offline.create

# Map avec en clé l'identifiant ancien du module, par exemple 'suivi_lent'
# et en valeur le nouvelle identifiant nombre (p.e. 10)
MODULE_ID_2_ID = Hash.new
dbtable_absmodules.select(colonnes: [:module_id, :id]).each do |hmod|
  MODULE_ID_2_ID.merge!(hmod[:module_id] => hmod[:id])
end


# Boucle sur toutes les données
# -----------------------------
request = 'SELECT * FROM mini_faq'
dbase_old.results_as_hash = true
all_old_rows = dbase_old.execute(request)

nombre_total_items    = all_old_rows.count
debug "nombre_total_items (mini-faq) : #{nombre_total_items}"
nombre_items_traited  = 0

all_old_rows.each do |row|
  row = row.to_sym
  # debug row.inspect

  next if row[:id] == 25

  newrow = Hash.new

  # On corrige les différences
  [ :id, :pseudo, :user_id, :module_id,
    :num_etape,
    :created_at,
    :question, :reponse, :content,
  ].each do |oldk|

    # Transformation de la clé si nécessaire
    newk =
      case oldk
      when :anycleold then :versclenew
      when :num_etape then :numero
      when :module_id then :abs_module_id
      when :pseudo    then :user_pseudo
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
      when :is_something
        :then_do_anything
      when :module_id
        nval = MODULE_ID_2_ID[newvalue[1..-1]]
        nval != nil || raise("Impossible de trouver l'ID Fixnum du module id #{newvalue}")
        nval
      when :user_id
        if newvalue.nil?
          newrow[:user_pseudo] = 'Benoit'
          2
        else
          newvalue
        end
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

  # Il faut déterminer l'identifiant absolu de l'étape, en fonction
  # du numéro d'étape et de l'identifiant du module
  case newrow[:id]
  when 24 then newrow[:numero] = 1
  when 26 then newrow[:numero] = 10
  end
  res = dbtable_absetapes.get(where: {numero: newrow[:numero], module_id: newrow[:abs_module_id]})
  res != nil || begin
    debug "\n\nNEW ROW AVANT RAISE : #{newrow.pretty_inspect}"
    raise("Impossible de trouver l'étape de numéro #{newrow[:numero]} et de module ##{newrow[:abs_module_id]}")
  end
  abs_etape_id = res[:id]

  # Obtenir l'user_id de l'auteur de la q

  newrow.merge!(
    abs_etape_id:   abs_etape_id,
    updated_at:     newrow[:created_at]
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

  nombre_items_traited += 1

  # debug "\n\nNEW ROW MINI-FAQ : #{newrow.pretty_inspect}"
  # break # pour seulement essayer

end
# /Fin de boucle sur chaque donnée


flash "#{nombre_total_items} questions mini-faq ont été créées."
