#encoding: utf-8

require_relative "TipoCasilla"

module ModeloQytetet
  class Casilla
    attr_accessor :numeroCasilla, :tipo
    
    def initialize(unNumeroCasilla, unTipo)
      if (unTipo == TipoCasilla::IMPUESTO)
        @coste = 1000
      else
        @coste = 0
      end
      
      @numeroCasilla = unNumeroCasilla
      @tipo = unTipo
    end
    
    def soy_edificable
      return @tipo == TipoCasilla::CALLE
    end
    
    def to_s
      puts "\nCasilla: \n\tNumeroCasilla: #{@numeroCasilla} \n\tTipo: #{@tipo}"
    end
  end
end
