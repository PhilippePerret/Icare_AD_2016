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
      'Bases de données'.in_h3 +
      'BASES DE DONNÉES'.in_a(href: 'database/edit').in_div +
      'WATCHERS'.in_a(href: 'watcher/edit').in_div +
      'Gestion Icariens'.in_h3 +
      'Opérations ICARIEN…'.in_a(href: 'admin/users').in_div +
      'Mailing list'.in_a(href: 'admin/mailing').in_div +
      'Visite le site comme…'.in_a(href: 'admin/visit_as').in_div +
      'Actualisations'.in_h3 +
      bouton_check_synchro +
      'Modules d’apprentissage'.in_h3 +
      boutons_modules_apprentissage +
      boutons_edition_etapes_modules +
      'Tests divers'.in_h3 +
      bouton_test_travaux +
      'Opérations sensibles'.in_h3 +
      bouton_erase_user_everywhere
    ).in_div
  end
  def boutons_modules_apprentissage
    if OFFLINE
      'Modules d’apprentissage'.in_a(href: 'abs_module/edit').in_div
    else
      ''
    end
  end
  def boutons_edition_etapes_modules
    OFFLINE ? 'Édition des étapes'.in_a(href: 'abs_etape/1/edit').in_div : ''
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
