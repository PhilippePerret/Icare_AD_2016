# encoding: UTF-8
=begin
  Module qui s'occupe de chercher les documents du trimestre courant
  et de les afficher.
=end
class QuaiDesDocs
class << self

  def listing_documents
    QuaiDesDocs.require_module 'listings'
    page.html_separator(40) +
    ul_documents_trimestre
  end

  def ul_documents_trimestre
    filtre = {created_between: [start_of_trimestre.to_i, end_of_trimestre.to_i]}
    args = {
      infos_document: true,
      filtre: filtre,
      avertissement: (annee_courante == annee_of_time && trimestre_courant == trimestre_of_time)
    }
    QuaiDesDocs.as_ul(args) || 'Aucun document pour ce trimestre'.in_p(class: 'big air')
  end

  def documents_du_trimestre_courant
    @documents_du_trimestre_courant ||= begin
      site.require_objet 'ic_document'
      condwhere = Array.new
      condwhere << "( SUBSTRING(options,2,1) = '1' OR SUBSTRING(options,10,1) = '1' )"
      condwhere << "created_at BETWEEN #{start_of_trimestre.to_i} AND #{end_of_trimestre.to_i}"
      condwhere = condwhere.join(' AND ')
      debug "condwhere : #{condwhere.inspect}"
      dbtable_icdocuments.select(where: condwhere, colonnes:[]).collect do |hdoc|
        IcModule::IcEtape::IcDocument.new(hdoc[:id])
      end
    end
  end

end #/<< self
end #/QuaiDesDocs
