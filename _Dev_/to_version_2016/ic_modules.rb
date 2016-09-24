# encoding: UTF-8
=begin

  Script pour récupérer les données des ic-modules

  @usage :

    Ajouter dans ./objet/site/home.rb :

        require './_Dev_/to_version_2016/ic_modules.rb'

=end
require 'sqlite3'

# Ancienne base de données SQLite3
pathold = './xprev_version/db/modules.db'
dbase_old = SQLite3::Database.new(pathold)

# On détruit la nouvelle table si elle existe
request = "DROP TABLE IF EXISTS icmodules"
site.db_execute(:modules, request, {online: false})
site.db_execute(:modules, request, {online: true})

# exit 0
sleep 1

# La table online
table_online  = site.dbm_table(:modules, 'icmodules', online = true)
table_offline = site.dbm_table(:modules, 'icmodules', online = false)

# exit 0
sleep 1

table_online.create rescue nil #
table_offline.create

# exit 0

# Map avec en clé l'identifiant ancien du module, par exemple 'suivi_lent'
# et en valeur le nouvelle identifiant nombre (p.e. 10)
MODULE_ID_2_ID = Hash.new
site.dbm_table(:modules, 'absmodules').select(colonnes: [:module_id, :id]).each do |hmod|
  MODULE_ID_2_ID.merge!(hmod[:module_id] => hmod[:id])
end
debug "MODULE_ID_2_ID : #{MODULE_ID_2_ID.pretty_inspect}"

# Boucle sur toutes les données
# -----------------------------
request = 'SELECT * FROM modules'
dbase_old.results_as_hash = true
dbase_old.execute(request).each do |row|
  row = row.to_sym
  # debug row.inspect

  newrow = Hash.new

  # On corrige les différences
  [ :id, :user_id, :module_id, :project_name,
    :next_paiement, :paiements,
    :en_pause, :pauses,
    :etapes, :icetape_id,
    :started_at, :ended_at, :updated_at

  ].each do |oldk|

    # Transformation de la clé si nécessaire
    newk =
      case oldk
      when :anycleold then :versclenew
      when :module_id then :abs_module_id
      when :en_pause  then :options
      when :etapes    then :icetapes
      else oldk
      end

    # Transformation de la valeur si nécessaire
    newvalue =
      case oldk
      when :module_id then
        # On remplace l'identifiant string (p.e. 'suivi_lent')
        # en son nombre
        mid = row.delete(:module_id)
        mid.start_with?(':') && mid = mid[1..-1]
        MODULE_ID_2_ID[mid]
      when :etapes
        # C'est une liste de Hash qui définissent chacun en clé
        # le numéro de l'étape et en valeur l'identifiant icetape
        # de l'étape. Il faut en faire une simple liste des icetapes
        arr_hash = JSON.parse(row[:etapes])
        arr_hash.collect do |hetape|
          hetape.instance_of?(Hash) || hetape = JSON.parse(hetape)
          hetape.values.first
        end.join(' ')
      when :en_pause
        "#{row[:en_pause] ? '2' : '-'}0000000"
      when :ended_at
        # Parfois, la valeur de :ended_at est zéro
        if row[:ended_at].to_s == '0'
          nil
        else
          row[:ended_at]
        end
      when :paiements
        if row[:paiements].nil_if_empty.nil?
          nil
        else
          JSON.parse(row[:paiements]).join(' ')
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

  if !newrow.key?(:options) || newrow[:options][0] == '-'
    # Il faut définir le premier bit des options qui déterminent
    # l'état de l'icmodule
    # 0:non démarré, 1:en cours, 2:en pause, 3:fini, 4:abonné
    bit1 =
      case true
      when newrow[:ended_at] != nil then '3' # achevé
      else '1' # en cours
      end
    opts = newrow[:options] || '0'*8
    opts[0] = bit1
    newrow[:options] = opts
  end

  newrow[:started_at] ||= Time.now.to_i
  newrow.merge!(created_at: newrow[:started_at] - (10000 + rand(10000)))

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

  # debug "\n\nNEW ROW ICMODULE : #{newrow.pretty_inspect}"
  # break # pour seulement essayer

end
# /Fin de boucle sur chaque donnée
