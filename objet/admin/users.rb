# encoding: UTF-8
raise_unless_admin

class Admin
class Users

  DATA_OPERATIONS = {
    ''          => {hname: 'Choisir l’opération…', short_value: nil, long_value: nil},
    'free_days' => {hname: 'Jours gratuits', short_value: "Nombre de jours gratuits", long_value: "Raison éventuelle du don de jours gratuits (format ERB)."},
    'travail_propre'  => {hname: 'Travail propre', short_value: nil, long_value: "Description du travail propre (format ERB)."},
    'etape_change'    => {hname: 'Changement d’étape', short_value: 'Numéro de l’étape', long_value: nil}
  }
class << self

  def param_opuser
    @param_opuser ||= param(:opuser) || Hash.new
  end

  # ---------------------------------------------------------------------
  #   DATA DE L'OPÉRATION
  # ---------------------------------------------------------------------
  # Les deux valeurs : soit la courte, soit la longue
  def short_value
    @short_value ||= param_opuser[:short_value].nil_if_empty
  end
  def long_value
    @long_value ||= param_opuser[:long_value].nil_if_empty
  end
  # Icarien visé par l'opération
  def user ; @user ||= User.new(user_id) end
  def user_id ; @user_id ||= param_opuser[:user_id].to_i end

  # ---------------------------------------------------------------------

  # Un menu pour choisir un user
  def menu
    drequest = {
      where: 'id > 1',
      colonnes: [:pseudo, :patronyme]
    }
    dbtable_users.select(drequest).collect do |huser|
      nom = huser[:pseudo]
      huser[:patronyme].nil? || nom += " (#{huser[:patronyme]})"
      "#{huser[:id]} - #{nom}".in_option(value: huser[:id])
    end.join.in_select(id: 'opuser_user_id', name: 'opuser[user_id]', selected: param_opuser[:user_id])
  end

  def execute_operation
    param_opuser[:ope] || return
    Admin.require_module 'operations_user'
    self.send("exec_#{param_opuser[:ope]}".to_sym)
  end


end #/<< self
end #/Users
end #/Admin

Admin::Users.execute_operation
