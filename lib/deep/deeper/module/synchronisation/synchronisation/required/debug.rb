# encoding: UTF-8
=begin
Noter que les librairies en sont pas chargées pour la synchro,
donc il faut implémenter ces méthodes
=end
def debug str
  @reffile ||= begin
    r = File.open(path_log_synchro, 'a')
    r.write("\n\n\n==== SYNCHRO #{Time.now} ===\n\n")
    r
  end
  @reffile.puts str
end
def path_log_synchro
  @path_log_synchro ||= begin
    f = File.join(folder_log, 'debug_synchro.log')
    File.unlink f if File.exist? f
    f
  end
end
def folder_log
  @folder_log ||= begin
    d = File.join('.', 'tmp', 'log')
    # On crée le dossier s'il n'existe pas
    `mkdir -p "#{d}"`
    d
  end
end
