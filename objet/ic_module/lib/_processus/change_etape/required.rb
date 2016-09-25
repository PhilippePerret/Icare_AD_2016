# encoding: UTF-8

def icmodule  ; @icmodule   ||= instance_objet      end
def icetape   ; @iceatpe    ||= owner.icetape       end
def absmodule ; @absmodule  ||= icmodule.abs_module end
def absetape  ; @absetape   ||= icetape.abs_etape   end


def next_abs_etape
  @next_abs_etape ||= begin
    site.require_objet 'abs_etape'
    AbsModule::AbsEtape.new(next_abs_etape_id)
  end
end
def next_abs_etape_id
  @next_etape_id ||= param(:next_etape).to_i
end


def next_etape_designation
  "#{next_abs_etape.numero} : “#{next_abs_etape.titre}”"
end

# Pour savoir si l'étape précédente doit compte pour une vraie
# étape. Pour le moment, je ne me sers pas encore de ça
def prev_etape_is_real?
  param(:prev_etape_is_real) == 'on'
end
