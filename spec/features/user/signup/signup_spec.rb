# encoding: UTF-8

feature "Inscription d'un user" do
  def data_signup
    @data_signup ||= begin
      pseudo = random_pseudo
      umail  = "#{pseudo.downcase}@chez.com"
      {
        _prefix:            'user_',
        pseudo:             pseudo,
        mail:               umail,
        mail_confirmation:  umail,
        naissance:  {type: :select, value: 1970 + rand(10)},
        sexe:   {type: :select, value: 'un homme'},
        password: "monmotdepasse",
        password_confirmation: "monmotdepasse",
        captcha: 366
      }
    end
  end
  before(:all) do
    benoit.reset_all
  end
  scenario "Un user peut trouver le formulaire d'inscription" do
    test 'Benoit peut trouver le formulaire d’inscription'
    visit_home
    La feuille contient la section 'header'
    La feuille contient le link 'Poser sa candidature'
    La feuille contient le link 'S\'identifier'
    shot 'accueil'
    Benoit clique le link 'Poser sa candidature'
    La feuille a pour titre 'Candidature Icare'
    La feuille ne contient pas le link 'Poser sa candidature'
    La feuille contient le link 'S\'identifier'
    La feuille contient le formulaire 'form_user_signup'
  end


  scenario 'Benoit remplit le formulaire d’inscription et le soumet' do
    test 'Benoit remplit le formulaire d’inscription et le soumet'
    start_time = Time.now.to_i - 1
    upseudo = data_signup[:pseudo]
    umail   = data_signup[:mail]

    nb = User.table.count(where: {pseudo: upseudo})
    expect(nb).to eq 0
    success "#{upseudo} n'est pas inscrit."


    visit_home
    benoit.clique_le_lien('Poser sa candidature')
    la_page_a_pour_titre('Candidature Icare')
    la_page_a_le_formulaire('form_user_signup')
    x = page.execute_script("return $('span#xcap').html()").to_i
    y = page.execute_script("return $('span#ycap').html()").to_i
    captcha_value = (x + y).to_s
    # puts "x = #{x}, y = #{y}, captcha_value = #{captcha_value}"
    benoit.remplit_le_formulaire('form_user_signup').
      avec(data_signup.merge(captcha: captcha_value)).
      et_le_soumet('S\'inscrire')
    la_page_napas_derreur

    # === PREMIÈRES VÉRIFICATIONS ===
    la_page_a_pour_titre 'Suite de l’inscription'
    # L'user a dû être créé dans la table
    nb = User.table.count(where: {pseudo: data_signup[:pseudo]})
    expect(nb).to eq 1
    huser = User.table.get(where: {pseudo: data_signup[:pseudo]})
    # puts "user in table : #{huser.inspect}"

    newu = User.new(huser[:id])

    success "#{upseudo} est inscrit."
    dactu = {
      user_id: huser[:id],
      message: "Inscription de <strong>#{upseudo}</strong>.",
      created_after: start_time
    }
    l_actualite(dactu).existe

    options = huser[:options]
    expect(options[2]).not_to eq '1'
    success "Les options indiquent que le mail n'est pas confirmé"

    newu.recoit_le_mail(
      subject:      'Bienvenue !',
      message:      ["#{upseudo}, bienvenue à l'atelier Icare !"],
      sent_after:   start_time
    )
    newu.recoit_le_mail(
      subject:      'Merci de confirmer votre mail',
      message:      ['Merci de bien vouloir confirmer votre adresse-mail'],
      sent_after:   start_time
    )

    # ---------------------------------------------------------------------
    #   Deuxième partie de l'inscription
    # ---------------------------------------------------------------------

    fname_presentation  = 'Présentation de MDI.odt'
    fpresentation = File.expand_path(File.join('spec','asset','document',fname_presentation))
    fname_motivation    = 'Motivation de MDI.odt'
    fmotivation   = File.expand_path(File.join('spec','asset','document', fname_motivation))
    within('form#form_documents_et_modules') do
      page.find('ul#abs_modules li#absmodule-1').click
      page.find('ul#abs_modules li#absmodule-3').click
      page.find('ul#abs_modules li#absmodule-5').click
      attach_file 'documents_presentation[presentation]', fpresentation
      attach_file 'documents_presentation[motivation]', fmotivation
      page.click_button('Finaliser l’inscription')
    end
    success 'Benoit choisit trois modules d’apprentissage'
    # sleep 1

    # === VÉRIFICATION DE L'ENREGISTREMENT COMPLET (modules et documents) ===
    La feuille a pour titre "Bienvenue à l'atelier Icare, #{data_signup[:pseudo]} !"
    le_dossier_user = le_dossier("./tmp/download/user-#{huser[:id]}-signup")
    le_dossier_user.existe(success: "Un dossier temporaire a été créé pour l'inscription de #{upseudo}")
    le_dossier_user.contient_le_fichier('Presentation_de_MDI.odt')
    le_dossier_user.contient_le_fichier('Motivation_de_MDI.odt')
    table_documents = site.dbm_table(:modules, 'icdocuments')
    hdocs = table_documents.select(where: "created_at > #{start_time}")
    presentation_docid = nil
    motivation_docid   = nil
    fname_presentation_normalized = fname_presentation.as_normalized_filename
    fname_motivation_normalized   = fname_motivation.as_normalized_filename
    hdocs.each do |hdoc|
      case hdoc[:original_name]
      when fname_presentation_normalized
        presentation_docid = hdoc[:id]
        success 'Une donnée documents est enregistrée pour le document présentation'
      when fname_motivation_normalized
        motivation_docid = hdoc[:id]
        success 'Une donnée documents est enregistrée pour le document motivation'
      else raise "Un autre document a bizarrement été instancié : #{hdoc[:original_name]}"
      end
    end
    presentation_docid && motivation_docid || begin
      messerr = Array.new
      presentation_docid || messerr << 'le document présentation n’a pas été enregistré'
      motivation_docid   || messerr << 'le document motivation n’a pas été enregistré'
      raise messerr.pretty_join
    end

    dwatcher = {user_id: newu.id, objet: 'ic_document', objet_id: presentation_docid, processus: 'admin_download'}
    le_watcher(dwatcher).
      existe(success: 'Un watcher a été enregistré pour télécharger le document présentation')
    dwatcher.merge!(objet_id: motivation_docid)
    le_watcher(dwatcher).
      existe(success: 'Un watcher a été enregistré pour télécharger le document motivation')

    wdata = {user_id: newu.id, objet: 'user', processus: 'valider_inscription', data: '1 3 5'}
    le_watcher(wdata).existe(
      success: 'Le watcher permettant à l’administration de valider l’inscription existe.'
    )

    data_mail = {
      sent_after:   start_time,
      subject:      'Nouvelle inscription',
      message:      ['Phil, je t\'informe d\'une nouvelle inscription', "#{newu.pseudo}", "##{newu.id}", "#{newu.mail}"]
    }
    Phil recoit le mail data_mail

  end

  scenario 'Bureau administrateur après inscription' do
    test 'L’administrateur trouve les watchers de cette nouvelle inscription'

    # S'assurer qu'on ait au moins une inscription
    if dbtable_watchers.count(where: {processus: 'valider_inscription'}) == 0
      puts "Je dois simuler une inscription."
      sim = Simulate.new
      sim.inscription test: true
    end

    # On récupère la première inscription qu'on trouve
    hwatcher = dbtable_watchers.select(where:{processus: 'valider_inscription'}).first
    user_id = hwatcher[:user_id]
    hdocs = dbtable_icdocuments.select(where: {user_id: user_id, abs_module_id: 0}, colonnes: [])
    puts "hdocs : #{hdocs.inspect}"
    docs_ids = hdocs.collect{|h| h[:id]}
    puts "docs_ids : #{docs_ids.inspect}"
    watchers_docs = dbtable_watchers.select(where: "objet_id IN (#{docs_ids.join(', ')})")
    puts "watchers_docs : #{watchers_docs.inspect}"

    identify_phil
    La feuille a pour titre TITRE_BUREAU
    # sleep 60
    La feuille contient la liste 'watchers-user-1', class: 'notifications'
    La feuille contient le formulaire "form_watcher-#{hwatcher[:id]}", dans: 'ul#watchers-user-1',
      success: 'Les notifications contienne le formulaire pour valider/refuser l’inscription'
    watchers_docs.each do |wdata|
      La feuille contient le formulaire "form_watcher-#{wdata[:id]}", dans: 'ul#watchers-user-1',
        success: "Une notification permet de downloader le document ##{wdata[:objet_id]}."
    end

  end


end
