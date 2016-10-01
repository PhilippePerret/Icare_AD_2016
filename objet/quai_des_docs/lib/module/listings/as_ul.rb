# encoding: UTF-8
=begin

  Module permettant de construire des listings à partir du quai
  des docs.

  Il a été mis en module séparé pour pouvoir être utilisé par
  l'affichage du listing des documents d'une étape donné dans le
  bureau d'un icarien

=end
class QuaiDesDocs
class << self

  # +options+
  #   :filtre     Le filtre à appliquer sur la liste des documents
  #               à voir.
  #               Ce filtre peut s'appliquer sur :
  #               :etape      ID absolu unique de l'étape absolu des
  #                           documents à voir
  #               :created_between
  #                           Array composé de
  #                             [timesecond départ, timesecond fin]
  #   :avertissement  Si True, on ajoute un message en tête de liste
  #                   pour indiquer qu'il faut respecter la confidentialité
  #                   des documents.
  #                   Défault: true
  #   :all            Si true (false par défaut), on considère tous les
  #                   documents, même ceux qui ne sont pas partagés.
  #   :full           Si true, on ajoute au formulaire pour télécharger le
  #                   document un formulaire pour le coter (si l'user courant
  #                   n'est pas l'auteur du document) ou pour en re-définir le
  #                   partage (cf. IcDocument#form_cote_or_partage)
  # RETURN
  #   Le code HTML de la liste UL des documents ou NIL dans le cas
  #   où aucun document ne correspondait au filtre. C'est la méthode
  #   appelante qui doit gérer ce cas.
  #
  # NOTES
  #   * Seuls les documents ayant atteint la fin de leur cycle doivent
  #     être pris en considération dans ce listing. Leur statut minimal
  #     doit donc être
  #   * Dans tous les cas, si l'user courant est à l'essai, on indique
  #     sa limite de documents.
  #
  def as_ul options = nil
    options ||= Hash.new

    # Paramètres de premier niveau
    filtre = options.delete(:filtre) || Hash.new
    options.key?(:avertissement) || options.merge!(avertissement: true)
    with_avertissement  = options.delete(:avertissement)
    even_not_shared     = !!options.delete( :all )
    full_card           = !!options.delete(:full)

    # ATTENTION : options sera ré-initialisé plus bas

    # --- Construction du filtre ---
    list_request = {
      where: Array.new
    }
    # On doit toujours considérer seulement les documents arrivés
    # en fin de cycle.
    list_request[:where] << "(SUBSTRING(options,6,1) = '1' OR SUBSTRING(options,14,1) = '1')"

    abs_etape_id = filtre.delete(:etape)
    if abs_etape_id
      list_request[:where] << "abs_etape_id = #{abs_etape_id}"
    end

    created_between = filtre.delete(:created_between)
    if created_between
      list_request[:where] << "created_at BETWEEN #{created_between.first} AND #{created_between.last}"
    end

    user_id = filtre.delete(:user_id)
    if user_id
      list_request[:where] << "user_id = #{user_id}"
    end


    list_request[:where] = list_request[:where].join(' AND ')
    # --- Fin de définition du filtre ---

    options = {
      as: options[:as] || :instance
    }

    list_documents_filtred = QuaiDesDocs.list(list_request, options)

    # L'avertissement
    # ---------------
    # Il ne doit être mis que si ce n'est pas une liste des
    # documents de l'auteur qui est demandé
    avertissement_respect_auteur =
      if user_id == user.id
        'Vous pouvez redéfinir vos partages dans ce listing qui présente tous vos documents.'.in_div(class: 'small italic')
      elsif with_avertissement
        avertissement.to_html.in_div(class: 'cadre warning')
      else
        ''
      end

    if list_documents_filtred.count > 0
      avertissement_respect_auteur +
      list_documents_filtred.collect do |idoc|
        (
          idoc.form_download                          +
          (full_card ? idoc.bloc_infos : '')          +
          (full_card ? idoc.form_cote_or_partage : '')
        ).in_li(id: "li_doc_qdd-#{idoc.id}", class: 'li_doc_qdd')
      end.join.in_ul(class: 'qdd_documents')
    else
      nil
    end
  end


end #/ << self
end #/QuaiDesDocs
