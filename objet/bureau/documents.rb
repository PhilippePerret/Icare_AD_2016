# encoding: UTF-8
raise_unless_identified


# = main =
#
# Méthode principale pour afficher la liste des documents QDD de
# l'user courant
#
# Avant, c'était la route 'quai_des_docs/list' qui était utilisée
def liste_documents_quai_des_docs
  if has_documents_qdd?
    site.require_objet 'quai_des_docs'
    QuaiDesDocs.require_module 'listings'
    filtre_docs = {user_id: user.id}
    QuaiDesDocs.as_ul(filtre: filtre_docs.dup, full: true)
  else
    'Vous n’avez aucun document déposé sur le Quai des docs de l’atelier.'.in_p(class: 'italic')
  end
end

def has_documents_qdd?
  dbtable_icdocuments.count(where: "user_id = #{user.id} AND (SUBSTRING(options,6,1) = '1' OR SUBSTRING(options,14,1) = '1')") > 0
end

# = main =
#
# Méthode faisant la liste des derniers documents commentés et
# permettant de les recharger
def liste_derniers_documents_commented
  if has_documents_commented?

  else
    'Vous n’avez eu aucun document commenté dans les 2 mois qui précèdent.'.in_p(class: 'italic')
  end
end

# Retourne TRUE si des documents sont trouvés dans le dossier temporaire
# des download
def has_documents_commented?
  false
end
