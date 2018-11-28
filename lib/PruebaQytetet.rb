#encoding: utf-8

require_relative "Qytetet"
require_relative "ControladorQytetet"

module ModeloQytetet
  class PruebaQytetet
    include InterfazTextualQytetet

    def self.valorsorpresamayorque0()
      mazo_aux = Array.new
      @mazo.each do |aux|
        if (aux.valor > 0)
          mazo_aux.push(aux)
        end
      end
      return mazo_aux
    end

    def self.sontipoiracasilla()
      mazo_aux = Array.new
      @mazo.each do |aux|
        if (aux.tipo == TipoSorpresa::IRACASILLA)
          mazo_aux.push(aux)
        end
      end
      return mazo_aux
    end

    def self.sontipoarg(tipo)
      mazo_aux = Array.new
      @mazo.each do |aux|
        if (aux.tipo == tipo)
          mazo_aux.push(aux)
        end
      end
      return mazo_aux
    end
    
    def self.showmazo()
      @mazo.each do |aux|
        aux.to_s
      end
    end
    
    def self.main()
      #@game = Qytetet.instance
      #@game.show_mazo
      #@game.show_tablero
      
      juego = ControladorQytetet.new
      juego.execute_game
      end
  end

  PruebaQytetet.main
end
