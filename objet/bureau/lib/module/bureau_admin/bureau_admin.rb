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
      'Édition des BASES DE DONNÉES'.in_a(href: 'database/edit').in_div +
      'Édition des Modules d’apprentissage'.in_a(href: 'abs_module/edit').in_div +
      'Édition des WATCHERS'.in_a(href: 'watcher/edit').in_div +
      'Mailing list'.in_a(href: 'admin/mailing').in_div +
      'Visite le site comme…'.in_a(href: 'admin/visit_as').in_div
    ).in_div
  end
end #/<< self
end #/Bureau
