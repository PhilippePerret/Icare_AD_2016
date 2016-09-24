# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.


# Mettre à true si on veut conserver toutes les données qui sont
# créées au cours des tests. Ça peut être utile pour vérifier certaines
# créations, lorsqu'un seul test est lancé.
KEEP_BASES_AFTER_TEST = false

# Tables à ré-initialiser
# -----------------------
# On récupère le dernier ID des tables pour détruire à la
# fin toutes les rangées qui ont été ajoutées
$data_tables = {
  users:        {base: :users,    table: 'users'},
  watchers:     {base: :hot,      table: 'watchers'},
  checkform:    {base: :hot,      table: 'checkform'},
  actualites:   {base: :hot,      table: 'actualites'},
  icmodules:    {base: :modules,  table: 'icmodules'},
  icetapes:     {base: :modules,  table: 'icetapes'},
  icdocuments:  {base: :modules,  table: 'icdocuments'},
  paiements:    {base: :users,    table: 'paiements'}
}

# require 'rspec-steps'
# require 'rspec-steps/monkeypatching'

# require 'capybara/rspec'
# Pour les tests avec have_tag etc.
require 'rspec-html-matchers'


require 'capybara/rspec'
require 'capybara-webkit'

# Capybara.javascript_driver = :webkit
# Capybara.javascript_driver = :webkit
Capybara.javascript_driver  = :selenium
Capybara.default_driver     = :selenium

# Pour Chrome
# Le seul problème avec Chrome est qu'on ne peut pas
# screenshoter toute la page, mais seulement la vue
# du port actuelle (taille fenêtre)
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

# Capybara.default_driver = :safari
# Capybara.register_driver :safari do |app|
# options = {
# :js_errors => false,
# :timeout => 360,
# :debug => false,
# :inspector => false,
# }
# Capybara::Selenium::Driver.new(app, :browser => :safari)
# end

# Firefox plante
# Capybara.default_driver = :firefox
# Capybara.register_driver :firefox do |app|
#   options = {
#   :js_errors => true,
#   :timeout => 360,
#   :debug => false,
#   :inspector => false,
#   }
#   Capybara::Selenium::Driver.new(app, :browser => :firefox)
# end

# On requiert tout ce que requiert l'index du site
# Mais est-ce vraiment bien, considérant tout ce qui est indiqué ci-dessus ?
ONLINE  = false
OFFLINE = true
require './lib/required'

require_folder './spec/support'


# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|

  # Pour les tests have_tag etc.
  config.include RSpecHtmlMatchers

  # config.include ModuleFormLikeStepDefinition

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end

  config.before :each do
    # Permet simplement d'afficher les résultats au fur et à mesure,
    # dans Atom (je crois que dans le terminal ça fonctionne déjà
    # comme ça)
    sleep 0.03
  end

  config.before :suite do

    # Indique à l'application qu'on est en mode test
    # TODO Plus tard, il faudra aussi le faire pour les tests
    # online.
    app.set_mode_test true

    ['download', 'mails', '_adm'].each do |fname|
      fp = site.folder_tmp + fname
      fp.remove if fp.exist?
    end

    empty_screenshot_folder

    File.unlink('./debug.log') if File.exist?('./debug.log')

    # On prend le temps de départ qui permettra de savoir les choses
    # qui ont été créées au cours des tests et pourront être
    # supprimées à la fin de la suite de tests
    @start_suite_time = Time.now.to_i

    $data_tables.each do |tid, dtable|
      tbl   = site.dbm_table(dtable[:base], dtable[:table])
      last  = tbl.select(order: 'id DESC', limit: 1).first
      $data_tables[tid][:last_id] = last.nil? ? nil : last[:id]
    end

    # Un Array contenant les instances ou les identifiants des
    # users qu'il faudra détruire à la fin des tests.
    # On peut y mettre indifféremment des Identifiants (Fixnum),
    # des instances user ({User}) ou des Hash de données (contenant
    # au moins :id)
    $users_2_destroy = Array.new

    # On fait un gel du site actuel pour pouvoir le remettre
    # ensuite.
    # SiteHtml.instance.require_module('gel')
    # SiteHtml::Gel::gel('before-test')

  end

  # À faire avant chaque module de test (donc chaque fichier)
  config.before :all do
    User.current = nil
    TEST_START_TIME = Time.now.to_i
  end

  # À exécuter à la toute fin des tests
  config.after :suite do

    # Indique à l'application qu'on N'est PLUS en mode test
    app.set_mode_test false

    # On détruit toutes les données qui ont été ajoutées
    # pendant les test, sauf si KEEP_BASES_AFTER_TEST est vrai
    unless KEEP_BASES_AFTER_TEST
      $data_tables.each do |tid, dtable|
        begin
          dtable[:last_id] != nil || next
          tbl   = site.dbm_table(dtable[:base], dtable[:table])
          tbl.exist? || next
          old_count = tbl.count
          tbl.delete(where: "id > #{dtable[:last_id]}")
          new_count = tbl.count
          # On va remettre l'auto-incrémente à la plus basse valeur
          max_id = site.db_execute(dtable[:base], "SELECT MAX(id) as max_id FROM #{dtable[:table]}")
          max_id = max_id.first[:max_id] || 0

          # puts "Reset AUTO_INCREMENT de #{dtable[:base]}.#{dtable[:table]} (mis à #{max_id + 1})"

          site.db_execute(dtable[:base], "ALTER TABLE #{dtable[:table]} AUTO_INCREMENT=#{max_id + 1}")

          # puts "Nombre de rangées supprimées dans #{dtable[:base]}.#{dtable[:table]} : #{old_count - new_count}"

        rescue Exception => e
          puts "# ERREUR MINEURE avec dtable:#{dtable.inspect} : #{e.message}"
        end
      end
    end

    # # Si la liste n'est pas vide, on détruit tous les
    # # users créés
    # unless $users_2_destroy.empty?
    #   # On transforme la liste en liste d'identifiants
    #   $users_2_destroy.collect! do |ref_u|
    #     case ref_u
    #     when Hash   then ref_u[:id]
    #     when User   then ref_u.id
    #     when Fixnum then ref_u
    #     else
    #       nil
    #     end
    #   end.compact
    #   User.table.delete(where: "id IN (#{$users_2_destroy.join(', ')})")
    # end

    # Destruction de tous les commentaires de page qui ont été produits
    remove_page_comments

  end
  # After suite


  # Pour palier le fait que `page` est une propriété du site, on remplace
  # `page` de Capybara par cette méthode ou ses alias.
  def cpage
    @rspec_page ||= Capybara.current_session
  end
  alias :rspec_page   :cpage
  alias :current_page :cpage
  alias :capy_page    :cpage

  # Méthode à appeler dans le before(:all) de certains tests pour
  # tout ré-initialiser
  def reset_all_variables

    if defined?(User)
      User::instance_variables.each do |iv|
        User.remove_instance_variable(iv)
      end
    end
    if defined?(site)
      site.instance_variables.each{|k|site.instance_variable_set(k,nil)}
      @site = nil
    end

    # @site   = nil
    # @forum  = nil
  end

  # Détermine s'il faut afficher les messages principalement
  # des 'steps définitions' façon rspec (pas cucumber)
  def verbose?
    # Pour le moment, je mets toujours à true, mais ensuite il
    # faudra pouvoir le régler autrement.
    true
  end

  #  Titre d'un test
  # -----------------
  def test titre
    verbose? || return
    puts "\n\e[1m\e[4;30m#{titre}\e[0m"
  end
  def success message
    if verbose?
      message_console message, '32'
    else
      message_point '32'
    end
  end
  def failure message
    if verbose?
      message_console message, '31'
    else
      message_point '31', 'F'
    end
  end
  # Pour une action par exemple (bleu)
  def afaire message
    if verbose?
      message_console message, '35'
    else
      message_point '35'
    end
  end
  def _action message
    if verbose?
      message_console message, '34'
    else
      message_point '34'
    end
  end

  def message_console message, couleur
    verbose? || return
    puts "\e[#{couleur}m#{message}\e[0m"
    sleep 0.1
  end

  # Quand ce n'est pas le mode verbose
  def message_point couleur, point = '.'
    STDOUT.write "\e[#{couleur}m#{point}\e[0m"
    sleep 0.1
  end

  def require_folder folder
    Dir["#{folder}/**/*.rb"].each{ |m| require m }
  end

  # Pour définir la route dans les tests unitaires
  #
  # +route+ peut être formée avec un contexte :
  #   objet/objet_id/method?in=context
  #
  def set_route route
    reg = /([a-zA-Z_]+)(?:\/([0-9]+))?\/([a-zA-Z_]+)(?:\?in=([a-zA-Z_]+))?/
    droute = route.match(reg).to_a
    site.send(:set_params_route, *droute[1..-1])
    site.execute_route
  end


  # Pour catcher les messages débug
  def debug str
    str =
      case str
      when String then str.strip
      when Fixnum, Float then str
      when Hash, Array then str.pretty_inspect
      else
        if str.respond_to?(:message)
          str.message + "\n" + str.backtrace.join("\n")
        else
          str.inspect
        end
      end
    puts "DBG: #{str}\n"
  rescue Exception => e
    # ne rien faire
  end
  # Pour catcher les messages log (par exemple pour le cron)
  def log str
    puts "LOG: #{str.to_s.strip}"
  end



  # ---------------------------------------------------------------------
  #   Concernant la navigation (features)
  # ---------------------------------------------------------------------

  def offline?
    @is_offline = OFFLINE if @is_offline === nil
    @is_offline
  end
  def online?; !offline? end
  def set_offline value = true
    @is_offline = value
  end
  def set_online value = true
    @is_offline = !value
  end

  # Pour pouvoir utiliser `visit home`
  def home
    @home ||= "#{site.local_url}"
  end
  def home_online
    @home_online ||= "#{site.distant_url}"
  end

  # @usage visit_home dans feature/scenario
  #         visite_home online: true
  def visit_home options = nil
    options ||= {}
    options[:online] ||= false
    visit (options[:online] ? home_online : home)
    resize_window
  end

  def visit_route route, options = nil
    options ||= {}
    visit (options[:online] ? home_online : home) + '/' + route
    resize_window
  end
  alias :visite_route :visit_route

  # La fenêtre ouverte par capybara
  def resize_window
    # page.driver.browser.manage.window.resize_to(1300, 600)
    # page.driver.browser.manage.window.resize_to('100%', '100%')
    # page.driver.browser.manage.window.maximize
    # page.driver.browser.manage.window(50)
    page.driver.browser.manage.window.resize_to(1300, 5000)
    page.driver.browser.manage.window.maximize

    # Tentatives (vaines) pour mettre Chrome en premier plan
    #
    # puts page.driver.browser.methods.join("\n")
    # page.driver.browser.manage.window.display
    # puts page.methods.join("\n")
    # page.switch_to_window(page.windows[0])
  end

  # ---------------------------------------------------------------------
  #   Screenshots
  # ---------------------------------------------------------------------
  def shot name
    name = "#{Time.now.to_i}-#{name}"
    page.save_screenshot("./spec/screenshots/#{name}.png")
  end
  def empty_screenshot_folder
    p = './spec/screenshots'
    FileUtils::rm_rf p if File.exists? p
    Dir.mkdir( p, 0777 )
  end

end
