# encoding: UTF-8
=begin

Récupération des témoignages


L'astuce est de jouer le script dans Atom avec CMD + CTRL + R, comme si
c'était un test. Cela charge tout le site.

require './_Dev_/to_version_2016/temoignages.rb'

=end
debug "-> temoignages.rb"
require 'sqlite3'

table_online  = site.dbm_table(:cold, 'temoignages', online = true)
table_offline = site.dbm_table(:cold, 'temoignages', online = false)

request = "DROP TABLE IF EXISTS temoignages"
site.db_execute(:cold, request, {online: false})
site.db_execute(:cold, request, {online: true})

table_online.create
table_offline.create

pathold = './xprev_version/db/cold_data.db'
dbase_old = SQLite3::Database.new(pathold)

dbase_old.results_as_hash = true
dbase_old.execute('SELECT * FROM temoignages;').each do |h|
  h = h.to_sym
  debug h.pretty_inspect
  dtem = {
    id: h[:id],
    content: h[:content],
    user_id: h[:user_id], user_pseudo: h[:user_pseudo],
    created_at: h[:created_at], updated_at: h[:updated_at]
  }
  table_online.insert(dtem)
  table_offline.insert(dtem)

  debug "\nInsertion du témoignage ##{h[:id]}\n"
end

debug "<- temoignages.rb"
