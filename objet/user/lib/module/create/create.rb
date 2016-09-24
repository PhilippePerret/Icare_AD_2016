# encoding: UTF-8
=begin

  Extension de la classe User pour créer l'utilisateur après son inscription
  valide.

=end

site.require_objet 'watcher'

class User
  class << self
    attr_reader :finalisation_inscription_reussie
    # Méthode appelée automatiquement par la route user/create
    #
    # Cette méthode à 2 vocations :
    #   - créer le user s'inscrivant
    #   - recevoir ses documents de présentation et son choix de modules
    #
    # Au premier passage (lorsque param(:user) est défini, et que param(:signup)
    # ne l'est pas ou n'est pas à 'fin'), on crée l'user.
    # Au deuxième passage, on consigne les documents et les modules choisis
    #
    # RETURN True si tout s'est bien passé, false dans le cas contraire
    #
    def create ; app.benchmark('-> User::create')
      @finalisation_inscription_reussie = false
      res =
        if param(:user).instance_of?(Hash) && param(:signup).nil?
          create_new_user
        elsif param(:signup) == 'fin'
          res = documents_et_modules_inscription
          @finalisation_inscription_reussie = res
        else
          raise 'La méthode User::create est appelée sans les bons arguments.'
        end
      app.benchmark('<- User::create')
      return res
    end
    #/create
end #/ << self
end #/User

def titre_choix_modules
  <<-HTML
<h4>Choix des modules d'apprentissage</h4>
<p class="small">
  Merci de choisir ci-dessous les modules pour lesquels vous postulez. Dans le doute, n'hésitez pas à #{lien.contact("contacter Phil")} pour en discuter avec lui.
</p>
  HTML
end

def titre_documents_presentation
  <<-HTML
<h4>Vos documents de présentation</h4>
<p>
  Afin de finalier votre inscription, vous devez transmettre vos documents de présentation.
</p>
  HTML
end

def liste_modules_checkboxable
  site.require_objet('abs_module')
  cbs_modules = ''
  AbsModule.each_instance(order: 'tarif ASC') do |amod|
    href    = "abs_module/#{amod.id}/show"
    cb_name = "modules[#{amod.id}]"
    cb_id   = "modules-#{amod.id}"
    mod_detail  = 'Détail'.in_a(href: href, class: 'small', target: :new).in_span(class: 'link')
    mod_name    = amod.name.in_span(class: 'name')
    mod_tarif   = "#{amod.tarif} €#{amod.type_suivi? ? ' / mois' : ''}".in_span(class: 'tarif')
    mod_libelle = "#{mod_detail}#{mod_name} #{mod_tarif}"
    mod_libelle = mod_libelle.in_checkbox(name: cb_name, id: cb_id)
    cbs_modules << mod_libelle.in_li(class: 'absmodule', id: "absmodule-#{amod.id}")
  end
  # /fin boucle sur toutes les instances modules
  cbs_modules = cbs_modules.in_ul(id:'abs_modules')
  return cbs_modules
end

class SiteHtml
  # Puisque l'user créé ne va pas être mis en user courant (car son mail
  # doit d'abord être confirmé), on le met dans cette variable pour
  # pouvoir être utilisé à l'affichage du message de bienvenue.
  attr_accessor :user_prov
end

class User
  # ---------------------------------------------------------------------
  #   Classe User
  # ---------------------------------------------------------------------
  class << self

    attr_reader :new_user

    # Premier passage : création de l'user
    #
    # NO RETURN
    def create_new_user
      app.benchmark('-> User::create_new_user')
      newuser = User.new
      @new_user = newuser
      if newuser.create
        # On login l'user provisoirement, mais il faudra qu'il
        # confirme son adresse mail à la session suivante
        newuser.login
        # On fait l'annonce de cette nouvelle inscription (noter)
        # qu'elle est faite avant d'avoir pris les documents et
        # les modules choisis
        site.require_objet 'actualite'
        SiteHtml::Actualite.create(:signup)
      end
      app.benchmark('<- User::create_new_user')
    end

    # Deuxième méthode, pour finaliser l'inscriptioin avec le choix
    # des modules et l'envoi des documents de présentation.
    #
    # Doit retourner FALSE en cas d'échec de la finalisation
    #
    def documents_et_modules_inscription
      app.benchmark('-> User::check_finalisation_inscription')
      traite_documents_presentation || (return false)
      traite_modules_choisis || (return false)
      app.benchmark('<- User::check_finalisation_inscription')
    rescue Exception => e
      debug e
      error e.message
    else
      true
    end

    # Traitement des documents de présentation
    #
    def traite_documents_presentation
      site.require_objet 'ic_document'
      temp_docs_folder = site.folder_tmp + "download/user-#{user.id}-signup"
      {
        presentation: {required: true,  hname: "Présentation"},
        motivation:   {required: true,  hname: "Motiviation"},
        extrait:      {required: false, hname: "Extrait"}
      }.each do |doc_id, ddata|
        case traite_document_presentation(doc_id, temp_docs_folder)
        when IcModule::IcEtape::IcDocument
          # L'opération a réussi
        when NilClass
          !ddata[:required] || raise("Le document “#{ddata[:hname]}” est absolument requis.")
        when FalseClass
          raise "Le document “#{ddata[:hname]}” n'a pas pu être uploadé."
        end
      end
    end

    # Traite le document d'identifiant +doc_ic+ (p.e. 'presentation') et
    # le met dans le dossier temporaire +temp_docs_folder+
    #
    # RETURN
    #   True  en cas de succès
    #   Nil   si le document n'existe pas
    def traite_document_presentation doc_id, temp_docs_folder
      doc_file      = temp_docs_folder + "#{doc_id}"
      doc_tempfile  = param(:documents_presentation)[doc_id]
      retour = doc_file.upload(doc_tempfile, {normalize_filename: true, nil_if_empty: true})
      retour || (return retour)
      # Sinon, on peut continuer en créant une instance de IcModule::IcEtape::IcDocument
      # qu'on retourne.
      icdocument = IcModule::IcEtape::IcDocument.create(doc_file)
      user.add_watcher(objet: 'ic_document', objet_id: icdocument.id, processus: 'admin_download')
      return icdocument
    end

    # Traitement des modules choisis
    #
    # Un watcher est créé qui doit permettre à l'administrateur
    # de choisir un module pour l'icarien.
    def traite_modules_choisis
      # C'est en fait
      liste_modules = param(:modules).keys.collect{|n|n.to_s.to_i}
      # Problème si aucun module choisi
      liste_modules.count > 0 || raise('Il faut choisir au moins 1 module.')
      # Création du watcher
      SiteHtml::Watcher.create(
        user_id:    user.id,
        objet:      'user',
        objet_id:   user.id,
        processus:  'valider_inscription',
        data:       liste_modules.join(' ')
      )
    rescue Exception => e
      debug e
      error e.message
    else
      true
    end

  end # << self

  # ---------------------------------------------------------------------
  #   Instance User
  # ---------------------------------------------------------------------
  def create
    app.benchmark('-> User#create')
    if data_valides?

      # Les données sont valides on peut vraiment créer le
      # nouvel utilisateur.
      save_all_data

      # On envoie un mail à l'utilisateur pour confirmer son
      # inscription.
      begin
        pmail = User.folder_modules + 'create/mail_bienvenue.erb'
        send_mail(
          subject: 'Bienvenue !',
          message: pmail.deserb(self),
          formated: true
        )
      rescue Exception => e
        debug "### PROBLÈME À L'ENVOI DU MAIL DE BIENVENUE"
        debug e
      end

      # On envoie à l'utilisateur un message pour qu'il confirme
      # son adresse-mail.
      begin
        pmail = User.folder_modules + 'create/mail_confirmation.erb'
        send_mail(
          subject: 'Merci de confirmer votre mail',
          message: pmail.deserb(self),
          formated: true
        )
      rescue Exception => e
        debug "### PROBLÈME À L'ENVOI DU MAIL DE CONFIRMATION"
        debug e
      end

      # On envoie un mail à l'administration pour informer
      # de l'inscription
      begin
        pmail = User.folder_modules + 'create/mail_admin.erb'
        send_mail_to_admin(
          subject:  'Nouvelle inscription',
          message:  pmail.deserb(self),
          formated: true
        )
      rescue Exception => e
        debug "### PROBLÈME À L'ENVOI DU MAIL D'ANNONCE DE NOUVELLE INSCRIPTION"
        debug e
      end
      true
    else
      # Les données sont invalides, on doit rediriger vers
      # la page du formulaire d'inscription (user/signup)
      # Il y a peut-être un contexte, comme lorsque l'on crée
      # l'user pour un programme UN AN.
      # redirect_to 'user/signup'
      redirection = "user/signup"
      unless site.current_route.context.nil?
        redirection += "?in=#{site.current_route.context}"
      end
      redirect_to redirection
      false
    end
  ensure
    app.benchmark('<- User#create')
  end

  # Méthode qui sauve toutes les données de l'user d'un coup
  # Note : pour le moment, on n'utilise cette méthode que dans
  # ce module consacré à la création.
  # Cela renvoie l'ID, en tout cas si tout a bien fonctionné.
  def save_all_data
    @id = User::table_users.insert(data_to_save)
  end

  # Les données inégrales à sauver
  def data_to_save
    now = Time.now.to_i
    @data_to_save ||= {
      pseudo:       real_pseudo,
      patronyme:    patronyme,
      sexe:         sexe,
      mail:         mail,
      cpassword:    cpassword,
      salt:         random_salt,
      session_id:   app.session.session_id,
      options:      '0'*10,
      created_at:   now,
      updated_at:   now
    }
  end

  # Retourne le pseudo avec toujours la première
  # lettre capitalisée (mais on ne touche pas aux autres)
  def real_pseudo
    pseudo[0].upcase + pseudo[1..-1]
  end

  # Retourne true si les données sont valides
  def data_valides?
    app.benchmark('-> User#data_valides?')
    debug "param(:user) : #{param(:user).inspect}"
    debug "form_data : \n#{form_data.inspect}"
    # Validité du PSEUDO
    @pseudo = form_data[:pseudo].nil_if_empty
    ! @pseudo.nil? || raise( "Il faut fournir le pseudo." )
    ! pseudo_exist?(@pseudo) || raise("Ce pseudo est déjà utilisé, merci d'en choisir un autre")
    @pseudo.length < 40 || raise("Le pseudo doit faire moins de 40 caractères.")
    @pseudo.length >= 3 || raise("Le pseudo doit faire au moins 3 caractères.")

    reste = @pseudo.gsub(/[a-zA-Z_\-]/,'')
    reste == "" || raise("Le pseudo ne doit comporter que des lettres, traits plats et tirets. Il comporte les caractères interdits : #{reste.split.pretty_join}")
    # Validité du patronyme
    @patronyme = form_data[:patronyme].nil_if_empty
    if site.signup_patronyme_required || !@patronyme.nil?
      raise "Il faut fournir le patronyme." if @patronyme.nil?
      raise "Le patronyme ne doit pas faire plus de 255 caractères." if @patronyme.length > 255
      raise "Le patronyme ne doit pas faire moins de 3 caractères." if @patronyme.length < 3
    else
      # La table a toujours besoin du patronyme
      @patronyme ||= @pseudo
    end

    # Validité du mail
    @mail = form_data[:mail].nil_if_empty
    raise "Il faut fournir votre mail." if @mail.nil?
    raise "Ce mail est trop long." if @mail.length > 255
    raise "Ce mail n'a pas un bon format de mail." if @mail.gsub(/^[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_\.\-]{1,6}$/,'') != ""
    raise "Ce mail existe déjà… Vous devez déjà être inscrit…" if mail_exist?( @mail )
    raise "La confirmation du mail ne correspond pas." if @mail != form_data[:mail_confirmation]

    # Validité du mot de passe
    @password = form_data[:password].nil_if_empty
    raise "Il faut fournir un mot de passe." if @password.nil?
    raise "Le mot de passe ne doit pas excéder les 40 caractères." if @password.length > 40
    raise "Le mot de passe doit faire au moins 8 caractères." if @password.length < 8
    raise "La confirmation du mot de passe ne correspond pas." if @password != form_data[:password_confirmation]

    # On variabilise les choses non testées
    @sexe = form_data[:sexe].nil_if_empty
    raise "Le sexe devrait être défini." if @sexe.nil?
    raise "Le sexe n'a pas la bonne valeur." unless ['F', 'H'].include?(@sexe)

    if site.captcha_value
      captcha = form_data[:captcha].nil_if_empty
      captcha != nil || raise('Il faut fournir le captcha pour nous assurer que vous n’êtes pas un robot.')
      app.captcha_valid?(captcha) || raise('Le captcha est mauvais, seriez-vous un robot ?')
    end

  rescue Exception => e
    debug e
    error e.message
  else
    true
  ensure
    app.benchmark('<- User#data_valides?')
  end

  # Les données en paramètres (dans le formulaire)
  def form_data
    @form_data ||= param(:user)
  end

  # Retourne le mot de passe crypté
  def cpassword
    @cpassword ||= begin
      require 'digest/md5'
      Digest::MD5.hexdigest("#{@password}#{mail}#{random_salt}")
    end
  end

  # Retourne un nouveau sel pour le mot de passe crypté
  # C'est un mot de 10 lettres minuscules choisies au hasard
  def random_salt
    @random_salt ||= 10.times.collect{ |itime| (rand(26) + 97).chr }.join('')
  end

  # Return true si le pseudo existe
  def pseudo_exist? pseudo
    return table_users.count(where: "pseudo = '#{pseudo}'") > 0
  end

  # Return True si le mail +mail+ se trouve déjà dans la table
  def mail_exist? mail
    return table_users.count(where: "mail = '#{mail}'") > 0
  end

end
