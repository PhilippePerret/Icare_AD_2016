# encoding: UTF-8
class Ajax
  class << self

    def output
      STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
      STDOUT.write (data || Hash.new).to_json
    end

    # Ajoute une donnée à retourner
    #
    # TODO Plus tard, faire un merge "intelligent" avec les messages,
    # pour que les nouveaux messages ou erreurs n'écrasent pas les
    # messages ou erreurs existants.
    def << hdata
      @data ||= Hash.new
      @data.merge!( hdata )
    end

    # Données à retourner à la requête
    def data
      @data ||= Hash.new
      # S'il y a des messages, il faut les ajouter
      if app.notice.output != ''
        flash @data[:message] if @data.key?(:message)
        @data.merge!(message: app.notice.output)
      end
      if app.error.output != ''
        error @data[:error] if @data.key?(:error)
        @data.merge!(error: app.error.output)
      end
      return @data
    end

  end # /<< self
end #/Ajax
