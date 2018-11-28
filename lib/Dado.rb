#encoding: utf-8

require "singleton"

module ModeloQytetet
  class Dado
    include Singleton
    
    def initialize
      @numero_caras = 6      
    end
    
    def tirar
      return 1 + rand(@numero_caras - 1)
    end
  end
end
