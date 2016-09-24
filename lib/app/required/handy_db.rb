# encoding: UTF-8
=begin

  Méthodes pratiques pour les bases

=end

# Table des users

def dbtable_users         ; @dbtusers   ||= sdbtbl_users('users')     end
def dbtable_paiements     ; @dbtpaimnts ||= sdbtbl_users('paiements') end
def dbtable_watchers      ; @dbtwtchrs  ||= sdbtbl_hot('watchers')    end
def dbtable_actualites    ; @dbtactus   ||= sdbtbl_hot('actualites')  end
def dbtable_checkform     ; @dbtblchkf  ||= sdbtbl_hot('checkform')   end

def dbtable_absmodules    ; @dbtabsmods ||= sdbt_mods('absmodules')   end
def dbtable_absetapes     ; @dbtabsetps ||= sdbt_mods('absetapes')    end
def dbtable_abswtypes     ; @dbtabswtyp ||= sdbt_mods('abs_travaux_type')  end
alias :dbtable_travaux_types :dbtable_abswtypes
def dbtable_icmodules     ; @dbticmods  ||= sdbt_mods('icmodules')    end
def dbtable_icetapes      ; @dbticetps  ||= sdbt_mods('icetapes')     end
def dbtable_icdocuments   ; @dbticdocs  ||= sdbt_mods('icdocuments')  end

# ---------------------------------------------------------------------
#   Fonctionnelles
# ---------------------------------------------------------------------
def sdbtbl base, name ; site.dbm_table(base, name) end
def sdbtbl_users name ; site.dbm_table(:users, name) end
def sdbtbl_hot name ; site.dbm_table(:hot, name) end
def sdbt_mods name ; site.dbm_table(:modules, name)  end
