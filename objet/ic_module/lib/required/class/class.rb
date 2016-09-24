# encoding: UTF-8
class IcModule

  extend MethodesMainObjet

  class << self

    def table ; @table ||= site.dbm_table(:modules, 'icmodules') end
    
  end #/<<self

end #/IcModule
