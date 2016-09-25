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
      'Opérations ICARIEN…'.in_a(href: 'admin/users').in_div +
      'BASES DE DONNÉES'.in_a(href: 'database/edit').in_div +
      boutons_modules_apprentissage +
      'WATCHERS'.in_a(href: 'watcher/edit').in_div +
      'Mailing list'.in_a(href: 'admin/mailing').in_div +
      'Visite le site comme…'.in_a(href: 'admin/visit_as').in_div +
      bouton_check_synchro +
      bouton_erase_user_everywhere +
      bouton_test_travaux
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
  def bouton_erase_user_everywhere
    'ERASE USER (ID dans admin/dashboard)'.in_a(class: 'warning', href: 'admin/dashboard?opadmin=erase_user_test').in_div
  end
  def bouton_test_travaux
    'Test travaux des étapes et des travaux-types'.in_a(href: 'admin/dashboard?opadmin=check_all_deserbage_travaux').in_div
  end
end #/<< self
end #/Bureau
