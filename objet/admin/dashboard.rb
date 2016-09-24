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
end
