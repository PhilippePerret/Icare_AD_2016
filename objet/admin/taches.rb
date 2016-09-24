# encoding: UTF-8
raise_unless_admin
Admin::require_module 'taches'

def tache_id
  @tache_id ||= param(:tid).to_i_inn
end

if tache_id != nil
  case param(:op)
  when 'stop_tache'
    Admin::Taches::Tache::new(tache_id).stop
  end
end
