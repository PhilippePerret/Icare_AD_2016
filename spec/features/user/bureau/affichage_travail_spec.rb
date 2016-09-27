feature "Affichage du travail dans le bureau" do
  scenario "Dans le cas d'une étape < 50" do
    site.require_objet 'ic_module'
    site.require_objet 'ic_etape'
    IcModule.require_module 'create'
    icmodule = IcModule.create_for(benoit, 1) # pas démarré
    icmodule_id = icmodule.id
    icmodule.set(started_at: NOW - 10.days)
    benoit.set(
      options:      benoit.options.set_bit(16,2),
      icmodule_id:  icmodule.id
      )
    test 'Le div d’aide n’apparait que tant que l’étape est inférieure à 100'
    current_list = Array.new
    [1, 10, 20, 50, 52, 60, 70, 75, 100,  990].each do |num_etape|
      # === ON PASSE BENOIT À L'ÉTAPE VOULUE ===
      icmodule = IcModule.new(icmodule_id)
      icetape = IcModule::IcEtape.create_for( icmodule, num_etape )
      icmodule.set(
        icetape_id: icetape.id,
        icetapes:   current_list.join(' ')
        )
      current_list << icetape.id
      puts "Benoit passe à l'étape #{num_etape} (par icmodule : #{icmodule.icetape.abs_etape.numero})"
      identify_benoit


      La feuille a pour titre TITRE_BUREAU

      # === AFFICHAGE DU TEXTE EXPLICATIF SUR LA PLACE DU TRAVAIL ===
      if num_etape < 100
        La feuille contient la balise 'p', id: 'bureau_cadre_explication_travail'
      else
        La feuille ne contient pas le div 'bureau_cadre_explication_travail'
      end

      # === AFFICHAGE DU TRAVAIL ===
      # TODO

      # === AFFICHAGE DES DOCUMENTS QDD ===
      # On récupère les documents QDD correspondant au module et à l'étape
      drequest = {
        where:    {abs_module_id: icmodule.abs_module.id, abs_etape_id: icetape.abs_etape.id},
        colonnes: [:original_name]
      }
      hdocs = dbtable_icdocuments.select(drequest)
      if hdocs.count > 0
        # puts "Nombre de documents QDD = #{hdocs.count}"
        # puts "hdocs : #{hdocs.inspect}"
        # sleep 20
        list_jid = 'ul.qdd_documents'
        La feuille contient la section 'section_etape_qdd'
        La feuille contient la balise 'ul', class: 'qdd_documents'
        hdocs.each do |hdoc|
          li_id = "li_doc_qdd-#{hdoc[:id]}"
          La feuille contient la balise 'li', id: li_id, dans: list_jid
        end
      end
      # break

      # === AFFICHAGE DE LA MINI-FAQ DE L'ÉTAPE
      # TODO (il y en a ou pas ?)
      drequest = {
        where: {abs_module_id: icmodule.abs_module.id, abs_etape_id: icetape.abs_etape.id},
        colonnes: []
      }
      hqrs = dbtable_minifaq.select(drequest)
      if hqrs.count > 0
        puts "Questions mini-faq : #{hqrs.count}"
        'div#mf_qr_2'
        hqrs.each do |hqr|
          La feuille contient le div "mf_qr_#{hqr[:id]}"
        end
        sleep 60*10
        break
      end

      Benoit clique le link 'Déconnexion'
    end
  end
end
