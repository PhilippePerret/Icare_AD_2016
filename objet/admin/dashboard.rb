# encoding: UTF-8
=begin

  Extension de la classe Admin pour le tableau de bord de l'administrateur

=end
raise_unless_admin

case param(:opadmin)
when 'check_synchro'
  begin
    # Procède au check de la synchro des sites local/distant
    f = (site.folder_deeper + 'module/synchronisation/synchronisation.rb')
    f.require
  rescue Exception => e
    debug e
    error e.message
  else
    flash "Check de synchro exécutée avec succès."
  ensure
    redirect_to :last_page
  end
when 'erase_user_test'
  # Procédure permettant de détruire un user partout (pour essai
  # avec Marion)
  USER_KILLED_ID = 90
  req = {where: {user_id: USER_KILLED_ID}}
  dbtable_actualites.delete(req)
  dbtable_watchers.delete(req)
  dbtable_icdocuments.delete(req)
  dbtable_icetapes.delete(req)
  dbtable_icmodules.delete(req)
  dbtable_paiements.delete(req)

  reqid = {where: {id: USER_KILLED_ID}}
  [
    [:hot, 'connexions'],
    [:users, 'users'],
    [:modules, 'mini_faq']
  ].each do |base, table|
    site.dbm_table(base, table).delete(reqid)
  end

  # On met le prochain id à la valeur juste supérieure au dernier
  dbtable_users.reset_next_id

  flash "J'ai détruit l'user ##{USER_KILLED_ID} partout"
end
