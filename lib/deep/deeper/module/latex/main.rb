# encoding: UTF-8
=begin

  Extension de la classe `SuperFile` pour produire un
  document PDF en passant par un document LaTex. Ou
  même simplement produire un document LaTex.

  L'extension a été inaugurée pour être utilisée avec
  la commande `kramdown <path> pdf`.

=end
class SuperFile

  # = main =
  #
  # Méthode principale pour transformer le document en
  # document PDF.
  #
  def to_pdf options = nil

    # La première chose à faire est de transformer le
    # document en document latex
    self.to_latex options

    # Ensuite on le compile dans son dossier pour
    # produire un PDF qu'on va déplacer au même niveau
    # avant de détruire le fichier.

  end

  # = main =
  #
  # Méthode principale pour transformer le document
  # courant en document LaTex. On utilise pour ça
  # la méthode kramdown
  #
  def to_latex options = nil

    # On utilise Kramdown pour produire un code
    # LaTex.
    # TODO: Est-ce que ça ne va pas concerner seulement les
    # fichier Markdown ? Que faire avec les fichiers ERB ou
    # autres ?
    # 
    site.require_module 'kramdown'
    code_latex = self.kramdown( output_format: :latex )

  end

end
