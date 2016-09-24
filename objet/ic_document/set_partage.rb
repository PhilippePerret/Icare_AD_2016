# encoding: UTF-8
raise_unless_identified

def icdocument
  @icdocument ||= begin
    IcModule::IcEtape::IcDocument.new(site.current_route.objet_id)
  end
end

raise_unless user.admin? || user.id == icdocument.user_id

# 4/12 doivent être mis à 1
# bit 1 (2e) : niveau partage original
# bit 9 (10e) : niveau partage comments
bitoshared = param(:doriginal_sharing).to_i
bitcshared = param(:dcomments_sharing).to_i

opts = icdocument.options
opts = opts.set_bit(4, 1)
opts = opts.set_bit(12, 1)
opts = opts.set_bit(1, bitoshared) # 1: partagé, 2: non partagé
opts = opts.set_bit(9, bitcshared)
icdocument.set(options: opts)

ajout =
  if bitoshared == 2 && bitcshared == 2
    "Il est juste dommage que vous ne les partagiez pas ou plus.<br />Avez-vous pris connaissance de #{lien.aide(30, titre:'la raison du partage')} ?"
  else
    "Un grand merci à vous pour le partage de votre travail."
  end
flash "Niveau de partage défini. #{ajout}"
redirect_to :last_page
