# encoding: UTF-8
class Simulate

    # Simule une inscription
    # ----------------------
    #
    # La méthode :
    #   - consigne dans @watchers le watcher de validation de l'inscription
    #   - définit la valeur @user_id, IDentifiant de l'user créé.
    #
    # +args+
    #   :test               On fait le test de la procédure en l'exécutant
    #   :mail_confirmed     Si true (default), le mail est marqué confirmé
    #
    def inscription args

      test_procedure = args[:test] || args.delete(:test_only_first)

      pseu    = args[:pseudo]         || random_pseudo
      upwd    = args[:password]       || "unmotdepasse"
      sexe    = args[:sexe]           || 'F'
      modules = args.delete(:modules) || '1 3 7'
      args.key?(:mail_confirmed) || args.merge!(mail_confirmed: true)
      mailconf = args.delete(:mail_confirmed)
      duser = data_for_new_user(pseudo: pseu, sexe: sexe, password: upwd, mail_confirmed: mailconf)

      # TODO IL RESTERAIT A FAIRE LES DEUX DOCUMENTS DE PRÉSENTATION, POUR AVOIR
      # UNE INSCRIPTION COMPLÈTE
      
      @user_id = dbtable_users.insert(duser)
      @user = User.new(@user_id)
      _action "L'user #{@user.pseudo} (##{@user.id}) s'inscrit (avec succès)."

      if test_procedure
        expect(@user).not_to be_recu
        expect(@user).to be_alessai
        mail_is_confirmed = @user.options[2].to_i == 1
        message_mail =
          if mailconf
            if mail_is_confirmed
              'Son mail a bien été confirmé'
            else
              raise "Le mail de #{@user.pseudo} aurait dû être corrigé."
            end
          else
            if mail_is_confirmed
              raise "Le mail de #{@user.pseudo} ne devrait pas être corrigé."
            else
              'Son mail n’est pas confirmé, comme voulu.'
            end
          end
        success "#{@user.pseudo} n'est pas reçu et est à l'essai. #{message_mail}"
      end

      # Par prudence, comme l'auto-incrémente est toujours remis à la valeur
      # du plus grand ID, on supprime tous les éléments qui peuvent appartenir
      # à cet user.
      {
        watchers:     dbtable_watchers,
        actualites:   dbtable_actualites,
        icmodules:    dbtable_icmodules,
        icetapes:     dbtable_icetapes,
        icdocuments:  dbtable_icdocuments,
        paiements:    dbtable_paiements
      }.each do |nom_tbl, tbl|
        dreq = {where: {user_id: self.user_id}}
        before_count = tbl.count(dreq)
        tbl.delete(dreq)
        after_count = tbl.count(dreq)
        if after_count < before_count
          nb = before_count - after_count
          s  = nb > 1 ? 's' : ''
          "#{nb} enregistrement#{s} supprimé#{s} dans la table #{nom_tbl} pour user ##{self.user_id}"
        end
      end

      # On crée le watcher pour valider l'inscription
      site.require_objet 'watcher'
      dwatcher = {
        objet:        'user',
        user_id:      @user_id,
        objet_id:     @user_id,
        processus:    'valider_inscription',
        data:         modules
      }
      @watcher_id = dbtable_watchers.insert(dwatcher)
      @watchers << dbtable_watchers.get(@watcher_id)

      if test_procedure
        expect(@user).to have_watcher(processus: 'valider_inscription', objet: 'user')
        success "#{@user.pseudo} a bien un watcher de validation de son inscription."
      end

    end
    # Inscription

end
