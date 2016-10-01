# encoding: UTF-8
=begin

  Opérations sur les icariens ou un icarien en particulier
  --------------------------------------------------------

  MESSAGES DE SUIVI
  -----------------

  Utiliser la variable @suivi (Array) pour mettre des messages de
  résultat/suivi qui apparaitront au-dessus du formulaire d'opération à
  la fin de l'opération.

=end
raise_unless_admin

class Admin
class Users

  DATA_OPERATIONS = {
    ''          => {hname: 'Choisir l’opération…', short_value: nil, long_value: nil},
    'free_days' => {hname: 'Jours gratuits', short_value: "Nombre de jours gratuits", long_value: "Raison éventuelle du don de jours gratuits (format ERB)."},
    'travail_propre'  => {hname: 'Travail propre', short_value: nil, long_value: "Description du travail propre (format ERB)."},
    'inject_document' => {hname: 'Document envoyé par mail', medium_value: 'Nom du fichier'},
    'etape_change'    => {hname: 'Changement d’étape', short_value: 'Numéro de l’étape', long_value: nil},
    'code_sur_table'  => {hname: 'Exécution code sur données', short_value: nil, medium_value: nil, long_value: "Code à exécuter <strong>sur chaque icarien de la table</strong>, sur la table #{ONLINE ? 'ONLINE' : 'OFFLINE'} puis vous êtes #{ONLINE ? 'ONLINE' : 'OFFLINE'}.<br><br><code>dbtable_users.select.each do |huser|<br>&nbsp;&nbsp;uid = huser[:id]<br>&nbsp;&nbsp;u = User.new(uid)</code>"},
    'arret_module'    => {hname: 'Arrêt d’un module d’apprentissage', long_value: 'Si un texte est écrit ci-dessous, il sera considéré comme le mail à envoyer à l’icarien du module. Dans le cas contraire, le module sera simplement arrêté.'}
  }
class << self

  def resultat
    if @suivi.nil?
      ''
    else
      (
        "=== SUIVI ET RESULTAT DE L’OPÉRATION ===\n\n" +
        @suivi.join("\n")
      ).in_pre(class: 'pre-wrap')
    end
  end

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
  def medium_value
    @medium_value ||= param_opuser[:medium_value].nil_if_empty
  end
  def long_value
    @long_value ||= param_opuser[:long_value].nil_if_empty
  end
  # Icarien visé par l'opération
  def icarien ; @icarien ||= User.new(user_id) end
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
    @suivi = Array.new
    Admin.require_module 'operations_user'
    self.send("exec_#{param_opuser[:ope]}".to_sym)
  end


end #/<< self
end #/Users
end #/Admin

Admin::Users.execute_operation
