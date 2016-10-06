#!/usr/bin/env ruby
# encoding: UTF-8

=begin

  Les actions du cron-job sont définies dans le fichier :

    ./CRON/lib/cron/instance/actions.rb
    
=end

def log_fatal_error
  @log_fatal_error ||= begin
    rf = File.join(FOLDER_CRON, 'cron_fatal_error.log')
    File.open(rf, 'a'){|f| f.write "\n\n\n=== CRON JOB - ERREUR FATALE #{Time.now} ===\n"}
    rf
  end
end
begin

  FOLDER_CRON = File.dirname(File.expand_path(__FILE__))
  FOLDER_LIB  = File.join(FOLDER_CRON, 'lib')
  require File.join(FOLDER_LIB,'required')

  # On se place à la racine du site
  Dir.chdir(APP_FOLDER) do
    ONLY_REQUIRE = true
    require './lib/required'
    # ==========================
            cron.exec
            cron.stop
    # ==========================
  end

rescue Exception => e
  backtrace = e.backtrace.join("\n")
  fatal_error = "ERREUR FATALE #{Time.now.strftime('%d %m %Y - %H:%M')}\n\n#{e.message}\n#{backtrace}"
  File.open(log_fatal_error, 'a'){|f| f.write fatal_error}
end
