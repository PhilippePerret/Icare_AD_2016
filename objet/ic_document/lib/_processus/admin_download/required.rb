# encoding: UTF-8


# Pour la clarté
def icdocument
  @icdocument ||= instance_objet
end

def icetape
  @icetape ||= icdocument.icetape
end
