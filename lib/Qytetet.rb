#encoding: utf-8

require "singleton"

require_relative "Casilla"
require_relative "Dado"
require_relative "Jugador"
require_relative "MetodosSalirCarcel"
require_relative "Sorpresa"
require_relative "Tablero"
require_relative "TipoCasilla"
require_relative "TipoSorpresa"
require_relative "TituloPropiedad"

module ModeloQytetet
  class Qytetet
    include Singleton
    
    attr_reader :carta_actual, :jugador_actual, :precio_libertad, :jugadores
    
    @@saldo_salida = 1000
    
    def initialize
      @max_jugadores = 4
      @max_casillas = 20
      @max_cartas = 12
      @precio_libertad = 200
      
      @index_mazo = 0
      
      @tablero = nil
      @mazo = Array.new
      @jugadores = Array.new
      @jugador_actual = nil
      @carta_actual = nil
      @dado = Dado.instance
      
      inicializar_tablero
      inicializar_cartas_sorpresa
    end
    
    def self.saldo_salida
      return @@saldo_salida
    end
    
    def aplicar_sorpresa
      tiene_propietario = false
      
      if (@carta_actual.tipo == TipoSorpresa::PAGARCOBRAR)
        @jugador_actual.modificar_saldo(@carta_actual.valor)
        
      elsif (@carta_actual.tipo == TipoSorpresa::IRACASILLA)
        es_carcel = @tablero.es_casilla_carcel(@carta_actual.valor)
        
        if (es_carcel)
          encarcelar_jugador
        else
          nueva_casilla = @tablero.obtener_casilla_numero(@carta_actual.valor)
          tiene_propietario = @jugador_actual.actualizar_posicion(nueva_casilla)
        end
        
      elsif (@carta_actual.tipo == TipoSorpresa::PORCASAHOTEL)
        @jugador_actual.pagar_cobrar_por_casa_y_hotel(@carta_actual.valor)
       
      elsif (@carta_actual.tipo == TipoSorpresa::PORJUGADOR)
        @jugadores.each do |aux|
          if (aux != @jugador_actual)
            aux.modificar_saldo(@carta_actual.valor)
            @jugador_actual.modificar_saldo(-@carta_actual.valor)
          end
        end
      end
      
      if (@carta_actual.tipo == TipoSorpresa::SALIRCARCEL)
        @jugador_actual.carta_libertad = @carta_actual
      else
        @mazo << @carta_actual
      end
      
      if (@carta_actual.tipo == TipoSorpresa::CONVERTIRME)
        i = 0
        while (i < @jugadores.size)
          if (@jugadores[i].eql?(@jugador_actual))
            especulador = @jugador_actual.convertirme(@carta_actual.valor)
            @jugadores[i] = especulador
            @jugador_actual = @jugadores[i]
          end
          i += 1
        end
      end      
      
      puts "\n[!!] Sorpresa activada!."
      puts "\n[!!] #{@carta_actual.nombre}"
      puts "\n[i] Saldo actual: #{@jugador_actual.saldo}"
      
      return tiene_propietario
    end
    
    def cancelar_hipoteca(casilla)
      if (casilla.titulo.propietario == @jugador_actual)
        se_puede_cancelar = casilla.esta_hipotecada
        
        if (se_puede_cancelar)
          puedo_cancelar = @jugador_actual.puedo_pagar_hipoteca(casilla)
          
          if (puedo_cancelar)
            cantidad_a_pagar = casilla.cancelar_hipoteca
            @jugador_actual.modificar_saldo(-cantidad_a_pagar)
            return true
          end
        end
      end
      
      return false
    end
    
    def comprar_titulo_propiedad
      return @jugador_actual.comprar_titulo
    end
    
    def edificar_casa(casilla)
      if (casilla.soy_edificable)
        se_puede_edificar = casilla.se_puede_edificar_casa(@jugador_actual.factor)
        
        if (se_puede_edificar)
          puedo_edificar = @jugador_actual.puedo_edificar_casa(casilla)
          
          if (puedo_edificar)
            coste_edificar_casa = casilla.edificar_casa
            @jugador_actual.modificar_saldo(-coste_edificar_casa)
            return true
          end
        end
      end
      
      return false
    end
    
    def edificar_hotel(casilla)
      if (casilla.soy_edificable)
        se_puede_edificar = casilla.se_puede_edificar_hotel(@jugador_actual.factor)
        
        if (se_puede_edificar)
          puedo_edificar = @jugador_actual.puedo_edificar_hotel(casilla)
          
          if (puedo_edificar)
            coste_edificar_hotel = casilla.edificar_hotel
            @jugador_actual.modificar_saldo(-coste_edificar_hotel)
            return true
          end
        end
      end
      
      return false
    end

    def hipotecar_propiedad(casilla)
      if (casilla.soy_edificable)
        se_puede_hipotecar = !casilla.esta_hipotecada
        
        if (se_puede_hipotecar)
          puedo_hipotecar = @jugador_actual.puedo_hipotecar(casilla)
          
          if (puedo_hipotecar)
            cantidad_recibida = casilla.hipotecar
            @jugador_actual.modificar_saldo(cantidad_recibida)
            return true
          end
        end
      end
      
      return false
    end
    
    def inicializar_juego(nombres)
      inicializar_jugadores(nombres)
      salida_jugadores
    end

    def intentar_salir_carcel(metodo)
      libre = false
      
      if (metodo == MetodosSalirCarcel::TIRANDODADO)
        valor_dado = @dado.tirar
        libre = valor_dado >= 5
        puts "\n[i] Tiras el dado y obtienes: #{valor_dado}"
        if (!libre)
          puts "\n[i] No sales de la carcel."
        end
        
      elsif (metodo == MetodosSalirCarcel::PAGANDOLIBERTAD)
        tengo_saldo = @jugador_actual.pagar_libertad(@precio_libertad)
        libre = tengo_saldo
        if (libre)
          puts "\n[i] Pagas #{@precio_liberdad} para conseguir la liberdad."
        end
      end
      
      if (libre)
        @jugador_actual.encarcelado = false
      end
      
      return libre      
    end
    
    def jugar
      valor_dado = @dado.tirar
      puts "\n[i] #{@jugador_actual.nombre} tira el dado y obtiene: #{valor_dado}"
      
      casilla_posicion = @jugador_actual.casilla_actual
      nueva_casilla = @tablero.obtener_nueva_casilla(casilla_posicion, valor_dado)
      tiene_propietario = @jugador_actual.actualizar_posicion(nueva_casilla)
      
      if (!nueva_casilla.soy_edificable)
        if (nueva_casilla.tipo == TipoCasilla::JUEZ)
          puts "\n[i] Has caido en la casilla numero 15."
          puts "[!!] El juez te manda a la carcel!!"
          encarcelar_jugador
        
        elsif (nueva_casilla.tipo == TipoCasilla::SORPRESA)
          @carta_actual = @mazo.at(@index_mazo % @mazo.size)
          @index_mazo += 1
        end
      end
      
      return tiene_propietario
    end
    
    def obtener_ranking
      ranking = Hash.new
      @jugadores.each do |j|
        capital = j.obtener_capital
        ranking[j.nombre] = capital
      end
      return ranking
    end
    
    def propiedades_hipotecadas_jugador(hipotecadas)
      props = Array.new
      
      if (hipotecadas)
        @casillas.each do |aux|
          if (aux.hipotecada)
            props << aux
          end
        end
      end
      
      if (!hipotecadas)
        @casillas.each do |aux|
          if (!aux.hipotecada)
            props << aux
          end
        end
      end
      
      return props
    end
    
    def siguiente_jugador
      no_repetir = false
      
      for i in 0..@jugadores.size
        if ((@jugadores.at(i) == @jugador_actual) && (i != @jugadores.size-1) && !no_repetir)
          @jugador_actual = @jugadores.at(i+1)
          no_repetir = true
        end
        
        if ((@jugadores.at(i) == @jugador_actual) && (i == @jugadores.size-1) && !no_repetir)
          @jugador_actual = @jugadores.at(0)
          no_repetir = true
        end        
      end
    end
    
    def salida_jugadores
      @jugadores.each do |aux|
        aux.casilla_actual = @tablero.obtener_casilla_numero(0)
      end
      
      jug = 1 + rand(@jugadores.size - 1)
      
      @jugador_actual = @jugadores.at(jug)      
    end
    
    def vender_propiedad(casilla)
      if (casilla.soy_edificable)
        puedo_vender = @jugador_actual.puedo_vender_propiedad(casilla)
        
        if (puedo_vender)
          @jugador_actual.vender_propiedad(casilla)
          return true
        end
      end
      
      return false
    end
    
    def encarcelar_jugador
      puts "\n[!!] Has sido encarcelado!!"
      if (!@jugador_actual.tengo_carta_libertad)
        casilla_carcel = @tablero.carcel
        @jugador_actual.ir_a_carcel(casilla_carcel)
        
      else
        carta = @jugador_actual.devolver_carta_libertad
        @mazo << carta
      end
    end
    
    def inicializar_cartas_sorpresa
      @mazo << Sorpresa.new("Te conviertes en especulador. Valor 3000.", 3000, TipoSorpresa::CONVERTIRME)
      @mazo << Sorpresa.new("Tu perro encuentra una caja con unas joyas. Las vendes y ganas 500 euros.", 500, TipoSorpresa::PAGARCOBRAR)
      @mazo << Sorpresa.new("Llave maestra de la carcel. Tiene un solo uso.", 0, TipoSorpresa::SALIRCARCEL)
      @mazo << Sorpresa.new("Un paseo nunca viene mal, ve a la casilla 14.", 14, TipoSorpresa::IRACASILLA)
      @mazo << Sorpresa.new("Debido a tu gran generosidad regalas a cada jugador un dia en el campo de golf. Te cuesta 125 euros cada uno.", -125, TipoSorpresa::PORJUGADOR)
      @mazo << Sorpresa.new("Eres guapo/a y cada jugador/a te debe dar 100 euros.", 100, TipoSorpresa::PORJUGADOR)
      @mazo << Sorpresa.new("El mantenimiento básico de tus casa y hoteles te cuesta por cada uno 80 euros.", -80, TipoSorpresa::PORCASAHOTEL)
      @mazo << Sorpresa.new("Te conviertes en especulador. Valor 5000.", 5000, TipoSorpresa::CONVERTIRME)
      @mazo << Sorpresa.new("Te invitan a una carrera no ilegal y por tanto vas a la salida.", 0, TipoSorpresa::IRACASILLA)
      @mazo << Sorpresa.new("Te pasas de listo en un control antidrogas y vas a la carcel.", @tablero.carcel.numeroCasilla, TipoSorpresa::IRACASILLA)
      @mazo << Sorpresa.new("Vuelves borracho a casa y al subir las escaleras te caes y te rompes las piernas. Los costes medicos te cuestan 450 euros.", -450, TipoSorpresa::PAGARCOBRAR)
      @mazo << Sorpresa.new("Ganas un concurso de hosteleria y recibes por cada casa y hotel 100 euros.", 100, TipoSorpresa::PORCASAHOTEL)
    end
    
    def inicializar_jugadores(to_add)
      if(to_add.size() <= @max_jugadores)
        for element in to_add do
          @jugadores << Jugador.new(element)
        end
      end
    end
    
    def inicializar_tablero
      @tablero = Tablero.new
    end
    
    def get_jugadores
      for j in @jugadores do
        j.to_s
      end
    end
    
    def show_mazo
      for element in @mazo do
        element.to_s
      end
    end
    
    def show_tablero
      @tablero.to_s
    end
  end
end
