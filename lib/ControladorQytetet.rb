#encoding: utf-8

require_relative "Qytetet"
require_relative "Casilla"
require_relative "Jugador"
require_relative "MetodosSalirCarcel"
require_relative "TipoCasilla"
require_relative "VistaTextualQytetet"
require_relative "Especulador"

module InterfazTextualQytetet
  class ControladorQytetet
    include ModeloQytetet
    
    def initialize
      @vista = VistaTextualQytetet.new
      @juego = Qytetet.instance
    end
    
    def jugador_en_bancarrota
      return @jugador_actual.bancarrota
    end
    
    def jugador_encarcelado
      return @jugador_actual.encarcelado
    end
    
    def endgame
      ranking = @juego.obtener_ranking
      @vista.end_game(ranking, @juego)
      exit
    end
    
    def pasar_turno
      @juego.siguiente_jugador
      @jugador_actual = @juego.jugador_actual
    end
    
    def gestiones_inmobiliarias
      atras = "Atras."
      
      begin
        opcion = @vista.menu_gestion_inmobiliaria
        case opcion
          when 1
            props = @jugador_actual.get_propiedades(1)
            props << atras
            if (props.length > 1)
              propiedad_elegida = @vista.menu_elegir_propiedad(props)
              if (propiedad_elegida < props.length - 1)
                casilla_elegida = @jugador_actual.search_casilla(props.at(propiedad_elegida))
                if (casilla_elegida.numeroCasas < (4*@jugador_actual.factor))
                  @juego.edificar_casa(casilla_elegida)
                  @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 1)
                else
                  @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 11)
                end
              end
            else
              @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 6)
            end
            
          when 2
            props = @jugador_actual.get_propiedades(2)
            props << atras
            if (props.length > 1)
              propiedad_elegida = @vista.menu_elegir_propiedad(props)
              if (propiedad_elegida < props.length - 1)
                casilla_elegida = @jugador_actual.search_casilla(props.at(propiedad_elegida))
                if (casilla_elegida.numeroHoteles < (4*@jugador_actual.factor))
                  @juego.edificar_hotel(casilla_elegida)
                  @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 2)
                else
                  @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 12)
                end
              end
            else
              @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 7)
            end
            
          when 3
            props = @jugador_actual.get_propiedades(3)
            props << atras
            if (props.length > 1)
              propiedad_elegida = @vista.menu_elegir_propiedad(props)
              if (propiedad_elegida < props.length - 1)
                casilla_elegida = @jugador_actual.search_casilla(props.at(propiedad_elegida))
                @juego.vender_propiedad(casilla_elegida)
                @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 3)
              end
            else
              @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 8)
            end
           
          when 4
            props = @jugador_actual.get_propiedades(4)
            props << atras
            if (props.length > 1)
              propiedad_elegida = @vista.menu_elegir_propiedad(props)
              if (propiedad_elegida < props.length - 1)
                casilla_elegida = @jugador_actual.search_casilla(props.at(propiedad_elegida))
                @juego.hipotecar_propiedad(casilla_elegida)
                @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 4)
              end
            else
              @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 9)
            end
            
          when 5
            props = @jugador_actual.get_propiedades(5)
            props << atras
            if (props.length > 1)
              propiedad_elegida = @vista.menu_elegir_propiedad(props)
              if (propiedad_elegida < props.length - 1)
                casilla_elegida = @jugador_actual.search_casilla(props.at(propiedad_elegida))
                @juego.cancelar_hipoteca(casilla_elegida)
                @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 5)
              end
            else
              @vista.texto_inmobiliario(casilla_elegida, @jugador_actual, 10)
            end
        end
      end while (opcion != 0)
    end
    
    def gestion_carcel
      metodo = @vista.menu_salir_carcel
      
      case metodo
        when 1
          if (@juego.intentar_salir_carcel(MetodosSalirCarcel::PAGANDOLIBERTAD))
            @vista.jugador_liberado(@jugador_actual)
          end
          
        when 2
          if (@juego.intentar_salir_carcel(MetodosSalirCarcel::TIRANDODADO))
            @vista.jugador_liberado(@jugador_actual)
          end
      end
    end
    
    def fin_turno
      begin
        que_hacer = @vista.menu_fin_turno
        
        case que_hacer
          when 1
            @vista.mostrar_propiedades(@jugador_actual)
            
          when 2
            gestiones_inmobiliarias
            
          when 3
            return true
        end
      end while (que_hacer != 3)
      
      return false
    end
    
    def update_game
      @jugador_actual = @juego.jugador_actual
      @casilla_actual = @juego.jugador_actual.casilla_actual
    end
    
    def check_bancarrota
      if (jugador_en_bancarrota)
        endgame
      end
    end
    
    def turno_jugador
      update_game
      @vista.info_principio_turno(@jugador_actual, @casilla_actual)
      @vista.pause
      
      if (jugador_encarcelado)
        gestion_carcel
      end
      
      if (!jugador_encarcelado)
        jugada = @juego.jugar
        
        if (jugada)
          update_game
          @vista.info(@jugador_actual, @casilla_actual)
          @vista.pause
        end
        
        if (@casilla_actual.tipo == TipoCasilla::JUEZ)
          @jugador_actual.ir_a_carcel(@juego.carcel)
          update_game
          @vista.info_principio_turno(@jugador_actual, @casilla_actual)
          @vista.pause
        end
        
        if (!jugador_en_bancarrota && !jugador_encarcelado)
          if (@casilla_actual.tipo == TipoCasilla::CALLE)
            if (@casilla_actual.titulo.propietario == nil)
              if (@vista.elegir_quiero_comprar)
                compra = @juego.comprar_titulo_propiedad
                if (compra)
                  @vista.compra(@casilla_actual, @jugador_actual)
                  check_bancarrota
                  terminar_turno = fin_turno
                else
                  terminar_turno = fin_turno
                end
                check_bancarrota
              else
                terminar_turno = fin_turno
              end
            else
              terminar_turno = fin_turno
            end
          end
          
          if(@casilla_actual.tipo == TipoCasilla::SORPRESA)
            sorpresa_aplicada = @juego.aplicar_sorpresa
            check_bancarrota
            if (sorpresa_aplicada)
              if (!jugador_encarcelado)
                check_bancarrota
                if (!jugador_en_bancarrota)
                  if (@casilla_actual.tipo == TipoCasilla::CALLE)
                    if (@casilla_actual.titulo.propietario == nil)
                      if (@vista.elegir_quiero_comprar)
                        compra = @juego.comprar_titulo_propiedad
                        if (compra)
                          @vista.compra(@casilla_actual, @jugador_actual)
                          check_bancarrota
                          terminar_turno = fin_turno
                        else
                          terminar_turno = fin_turno
                        end
                        check_bancarrota
                      else
                        terminar_turno = fin_turno
                      end
                    else
                      terminar_turno = fin_turno
                    end
                  else
                    terminar_turno = fin_turno
                  end
                end
              end
            end
            terminar_turno = fin_turno
          end
          
          if (@casilla_actual.tipo == TipoCasilla::CARCEL && !jugador_encarcelado)
            terminar_turno = fin_turno       
          end
          
          if (@casilla_actual.tipo == TipoCasilla::PARKING)
            terminar_turno = fin_turno       
          end
          
          if (@casilla_actual.tipo == TipoCasilla::IMPUESTO)
            terminar_turno = fin_turno       
          end
          
          if (@casilla_actual.tipo == TipoCasilla::SALIDA)
            terminar_turno = fin_turno       
          end
          
          if (@jugador_actual.tengo_propiedades && !terminar_turno)
            terminar_turno = fin_turno
          end
        end
        
        if (jugador_en_bancarrota)
          return true
        end
      end
      
      return false
    end
    
    def desarrollo_juego
      fin = false
      
      begin
        if (turno_jugador)
          fin = true
        end
        
        pasar_turno
      end while (!false)
      
    end
    
    def elegir_propiedad(propiedades) # lista de propiedades a elegir
      @vista.mostrar("\tCasilla\tTitulo");
      listaPropiedades= Array.new
      
      for prop in propiedades  # crea una lista de strings con numeros y nombres de propiedades
        listaPropiedades << "\t #{prop.numeroCasilla} \t #{prop.titulo.nombre}"
      end
      
      seleccion = @vista.menu_elegir_propiedad(listaPropiedades)  # elige de esa lista del menu
      
      return propiedades.at(seleccion)
    end
    
    def inicializacion_juego
      @vista.wellcome
      @juego.inicializar_juego(@vista.obtener_nombre_jugadores)
      @jugador_actual = @juego.jugador_actual
      @casilla_actual = @jugador_actual.casilla_actual
      
      @vista.show_game(@juego)
    end
    
    def execute_game
      inicializacion_juego
      desarrollo_juego
    end
  end
end
