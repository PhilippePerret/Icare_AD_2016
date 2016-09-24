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
      if num_etape < 100
        La feuille contient la balise 'p', id: 'bureau_cadre_explication_travail'
      else
        La feuille ne contient pas le div 'bureau_cadre_explication_travail'
      end
      Benoit clique le link 'Déconnexion'
    end
  end
end
