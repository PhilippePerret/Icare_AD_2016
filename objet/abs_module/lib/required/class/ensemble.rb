# encoding: UTF-8
class AbsModule
class << self
  # Retourne la liste (Array) des instances de module absolu
  def list
    @list ||= begin
      table.select(colonnes:[]).collect{|hmod| new(hmod[:id])}
    end
  end

  def each drequest = nil
    drequest ||= Hash.new
    table.select(drequest).each do |hmod|
      # debug "hmod = #{hmod.inspect}"
      yield hmod
    end
  end

  def each_instance drequest = nil
    drequest ||= Hash.new
    drequest[:colonnes] ||= []
    drequest.merge!(order: 'tarif ASC')
    table.select(drequest).each do |hmod|
      amodule = new(hmod[:id])
      yield amodule
    end
  end

end #/<< self
end #/AbsModule
