# encoding: UTF-8
class Bureau
class << self
  def _section_administrateur
    (
      liens_editions
    ).in_section(id: 'bureau_administrateur')
  end
  def liens_editions
    (
      'BASES DE DONNÉES'.in_a(href: 'database/edit').in_div +
      boutons_modules_apprentissage +
      'WATCHERS'.in_a(href: 'watcher/edit').in_div +
      'Mailing list'.in_a(href: 'admin/mailing').in_div +
      'Visite le site comme…'.in_a(href: 'admin/visit_as').in_div +
      bouton_check_synchro
    ).in_div
  end
  def boutons_modules_apprentissage
    if OFFLINE
      'Modules d’apprentissage'.in_a(href: 'abs_module/edit').in_div
    else
      ''
    end
  end
  def bouton_check_synchro
    if OFFLINE
      'Check SYNCHRO'.in_a(href: 'admin/dashboard?opadmin=check_synchro').in_div
    else
      ''
    end
  end
end #/<< self
end #/Bureau
