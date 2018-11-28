#encoding: utf-8

require_relative "Casilla"
require_relative "Calle"
require_relative "TituloPropiedad"

module ModeloQytetet
  class Tablero
    attr_accessor :carcel, :casillas
    
    def initialize
      @carcel = nil
      @casillas = Array.new
      @MAX_CASILLAS = 20
      inicializar_casillas()
    end
    
    def inicializar_casillas()
      @casillas << Casilla.new(0, TipoCasilla::SALIDA)
            
      aa = TituloPropiedad.new("Plaza Pisaobocata.", 50, -0.1, 200, 250)
      @casillas << Calle.new(1, 100, aa)
      
      @casillas << Casilla.new(2, TipoCasilla::SORPRESA)
      
      bb = TituloPropiedad.new("Santa Iglesia del Pope Emeritus IV.", 50, -0.1, 200, 300)
      @casillas << Calle.new(3, 150, bb)
      
      cc = TituloPropiedad.new("Avenida Turkelo.", 50, -0.1, 200, 350)
      @casillas << Calle.new(4, 200, cc)
      
      @casillas << Casilla.new(5, TipoCasilla::PARKING)
      
      dd = TituloPropiedad.new("Calle Go CSGO.", 65, 0.1, 450, 400)
      @casillas << Calle.new(6, 300, dd)
      
      ee = TituloPropiedad.new("Rotonda Tour de Francia.", 65, 0.1, 450, 450)
      @casillas << Calle.new(7, 350, ee)
      
      @casillas << Casilla.new(8, TipoCasilla::IMPUESTO)
      
      ff = TituloPropiedad.new("Calle Corta.", 65, 0.1, 450, 500)
      @casillas << Calle.new(9, 400, ff)
      
      @carcel = Casilla.new(10, TipoCasilla::CARCEL)
      @casillas << @carcel
      
      gg = TituloPropiedad.new("Calle Larga.", 80, 0.15, 600, 550)
      @casillas << Calle.new(11, 500, gg)
      
      hh = TituloPropiedad.new("Plaza de los Sacos.", 80, 0.15, 600, 600)
      @casillas << Calle.new(12, 550, hh)
      
      @casillas << Casilla.new(13, TipoCasilla::SORPRESA)
      
      ii = TituloPropiedad.new("Esquina de Wito.", 80, 0.15, 600, 650)
      @casillas << Calle.new(14, 600, ii)
      
      @casillas << Casilla.new(15, TipoCasilla::JUEZ)
      
      jj = TituloPropiedad.new("Avenida Mandingo.", 100, 0.2, 800, 700)
      @casillas << Calle.new(16, 700, jj)
      
      kk = TituloPropiedad.new("Negev Square.", 100, 0.2, 800, 750)
      @casillas << Calle.new(17, 750, kk)
      
      @casillas << Casilla.new(18, TipoCasilla::SORPRESA)
    
      map = TituloPropiedad.new("Map de_dust2.", 100, 0.2, 800, 750) 
      @casillas << Calle.new(19, 800, map)
    end
    
    def getcarcel
      return @carcel
    end
    
    def obtener_casilla_numero(numeroCasilla)
      return @casillas.at(numeroCasilla)
    end
        
    def es_casilla_carcel(numeroCasilla)
      return (@casillas.at(numeroCasilla).numeroCasilla == @carcel.numeroCasilla)
    end
    
    def obtener_nueva_casilla(casilla, desplazamiento)
      aux = (casilla.numeroCasilla + desplazamiento) % @MAX_CASILLAS;
      return @casillas.at(aux)
    end
    
    def to_s()
      for i in 0..19
        @casillas[i].to_s
      end
    end
  end
end
