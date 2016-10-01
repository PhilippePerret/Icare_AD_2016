# encoding: UTF-8
=begin

=end
class QuaiDesDocs
class << self

  # ---------------------------------------------------------------------
  #
  #   Méthodes d'helper
  #
  # ---------------------------------------------------------------------

  # Contenu de l'accueil lorsqu'il est visité par un non icarien
  def section_non_icarien
    <<-HTML
<p class="big air">
  Nous sommes désolés, mais seuls les icariennes et icariens ont accès au <strong>Quai des docs</strong>.
</p>
<p class="right">
  #{'→ Postuler pour devenir icarienne ou icarien'.in_a(href: 'signup')}
</p>
    HTML
  end

end #/<< self
end #/QuaiDesDocs
