#encoding: utf-8

require_relative "Casilla"
require_relative "MetodosSalirCarcel"
require_relative "Sorpresa"
require_relative "TipoCasilla"
require_relative "TipoSorpresa"
require_relative "TituloPropiedad"
require_relative "Qytetet"

module ModeloQytetet
  class Jugador
    attr_accessor :casilla_actual, :encarcelado, :saldo, :propiedades, :carta_libertad, :nombre, :factor
    
    def initialize(new_nombre)
      @nombre = new_nombre
      @encarcelado = nil
      @saldo = 7500
      @casilla_actual = nil
      @propiedades = Array.new
      @carta_libertad = nil
      @factor = 1
    end
    
    def crear_jugador
      self.new(nil)
    end
    
    def tengo_propiedades
      return @propiedades.size > 0
    end
    
    def pagar_impuestos(cantidad)
      @saldo += cantidad
    end
    
    def copy_jugador(otro)
      @nombre = otro.nombre
      @encarcelado = otro.encarcelado
      @saldo = otro.saldo
      @casilla_actual = otro.casilla_actual
      @propiedades = otro.propiedades
      @carta_libertad = otro.carta_libertad
    end
    
    def convertirme(fianza)
      return Especulador.new(self, fianza)
    end
    
    def actualizar_posicion(casilla)
      if (casilla.numeroCasilla < @casilla_actual.numeroCasilla)
        modificar_saldo(Qytetet.saldo_salida)
        puts "\n[i] Pasas por la salida y recibes 1000 euros."
        puts "[i] Saldo actual: #{@saldo}"
      end
      
      @casilla_actual = casilla
      
      if (casilla.soy_edificable)
        if (casilla.tengo_propietario) 
          if (!casilla.propietario_encarcelado)
            coste_alquiler = casilla.cobrar_alquiler
            modificar_saldo(-coste_alquiler)
            puts "\n[i] #{@nombre} paga a #{casilla.titulo.propietario.nombre} #{coste_alquiler} de alquiler."
          end
        end
        
        return true
        
        elsif (casilla.tipo == TipoCasilla::IMPUESTO)
          coste = casilla.coste
          pagar_impuestos(coste)
          puts "\n\n[!!] Impuesto!! \n[i] Tienes que pagar: #{coste}"
          puts "[i] Saldo actual: #{@saldo}"
          return true        
        elsif (casilla.tipo == TipoCasilla::PARKING)
          return true
        elsif (casilla.tipo == TipoCasilla::SORPRESA)
          return true
        elsif (casilla.tipo == TipoCasilla::SALIDA)
          return true
        elsif (casilla.tipo == TipoCasilla::JUEZ)
          return true
        elsif (casilla.tipo == TipoCasilla::CARCEL)
          return true
      end

      return false
    end
    
    def comprar_titulo
      if (@casilla_actual.soy_edificable)
        tengo_propietario = @casilla_actual.tengo_propietario
        
        if (!tengo_propietario)
          coste_compra = @casilla_actual.coste
          
          if (coste_compra <= saldo)
            aux = @casilla_actual.set_propietario(self)
            @propiedades << aux
            modificar_saldo(-coste_compra)
            
            return true
          else
            puts "\n[i] No tienes suficiente dinero para comprar el titulo."
          end
        end
      end
      
      return false
    end
    
    def devolver_carta_libertad
      aux = @carta_libertad
      @@carta_libertad = nil
      return aux
    end
    
    def ir_a_carcel(casilla)
      @casilla_actual = casilla
      @encarcelado = true
    end
    
    def modificar_saldo(cantidad)
      @saldo += cantidad
    end
    
    def obtener_capital
      capital = @saldo
      
      @propiedades.each do |aux|
        if (aux.casilla.numeroCasas > 0)
          capital += (aux.casilla.numeroCasas * aux.casilla.precioEdificar)
        end
        
        if (aux.casilla.numeroHoteles > 0)
          capital += (aux.casilla.numeroHoteles * aux.casilla.precioEdificar)
        end
        
        if (aux.hipotecada == true)
          capital -= aux.hipotecaBase
        end
      end
      
      return capital
    end
    
    def obtener_propiedades_hipotecadas(hipotecadas)
      props = Array.new
      
      if (hipotecadas)
        @propiedades.each do |aux|
          if (aux.hipotecada)
            props << aux
          end
        end
      end
      
      if (!hipotecadas)
        @propiedades.each do |aux|
          if (!aux.hipotecada)
            props << aux
          end
        end
      end
      
      return props
    end
    
    def pagar_cobrar_por_casa_y_hotel(cantidad)
      numero_total = cuantas_casas_hoteles_tengo
      modificar_saldo(cantidad * numero_total)
    end
    
    def pagar_libertad(cantidad)
      tengo_saldo = tengo_saldo(cantidad)
      if (tengo_saldo)
        modificar_saldo(-cantidad)
        return true
      end
      
      return false
    end
    
    def puedo_edificar_casa(casilla)
      es_mia = es_de_mi_propiedad(casilla)
      tengo_saldo = false
      
      if (es_mia)
        coste_edificar_casa = casilla.titulo.precioEdificar
        tengo_saldo = tengo_saldo(coste_edificar_casa)
      end
      
      return tengo_saldo
    end

    def puedo_edificar_hotel(casilla)
      es_mia = es_de_mi_propiedad(casilla)
      tengo_saldo = false
      
      if (es_mia)
        coste_edificar_hotel = casilla.titulo.precioEdificar
        tengo_saldo = tengo_saldo(coste_edificar_hotel)
      end
      
      return tengo_saldo      
    end
    
    def puedo_hipotecar(casilla)
      return es_de_mi_propiedad(casilla)     
    end

    def puedo_pagar_hipoteca(casilla)
      return saldo >= casilla.get_coste_hipoteca
    end
    
    def puedo_vender_propiedad(casilla)
      return es_de_mi_propiedad(casilla) && !casilla.esta_hipotecada
    end
    
    def tengo_carta_libertad
      return @carta_libertad != nil
    end
    
    def vender_propiedad(casilla)
      precio_venta = casilla.vender_titulo
      modificar_saldo(precio_venta)
      eliminar_de_mis_propiedades(casilla)      
    end
    
    def cuantas_casas_hoteles_tengo
      counter = 0
      @propiedades.each do |aux|
        counter += aux.casilla.numeroCasas
        counter += aux.casilla.numeroHoteles
      end
      
      return counter 
    end
    
    def eliminar_de_mis_propiedades(casilla)
      @propiedades.each_with_index do |aux, i|
        if (aux.casilla == casilla)
          @propiedades.delete_at(i)
        end
      end    
    end
    
    def es_de_mi_propiedad(casilla)
      es_mia = false
      
      @propiedades.each do |aux|
        if (aux.casilla == casilla)
          es_mia = true
        end
      end
      
      return es_mia
    end
    
    def tengo_saldo(cantidad)
      return @saldo >= cantidad      
    end
    
    def bancarrota
      return @saldo < 0
    end
    
    def get_propiedades(opcion)
      props = Array.new
      
      case opcion
        when 1
          @propiedades.each do |tit|
            if (tit.casilla.numeroCasas < (4 * @factor))
              props << tit.nombre
            end
          end
          
        when 2
          @propiedades.each do |tit|
            if (tit.casilla.numeroHoteles < (4 * @factor))
              props << tit.nombre
            end
          end
          
        when 3
          @propiedades.each do |tit|
            props << tit.nombre
          end
          
        when 4
          props_not_hipo = obtener_propiedades_hipotecadas(false)
          props_not_hipo.each do |tit|
            props << tit.nombre
          end
          
        when 5
          props_not_hipo = obtener_propiedades_hipotecadas(true)
          props_not_hipo.each do |tit|
            props << tit.nombre
          end
      end
      
      return props
    end
      
    def search_casilla(nombre)
      ret = nil

      @propiedades.each do |tit|
        if (tit.nombre == nombre)
          ret = tit.casilla
        end
      end

      return ret
    end
    
    def to_s
      puts "jugador: \n\tNombre: #{@nombre} \n\tSaldo: #{@saldo} \n\tFactor: #{@factor} \n"
    end
    
    private :cuantas_casas_hoteles_tengo, :es_de_mi_propiedad, :eliminar_de_mis_propiedades
    protected :copy_jugador, :pagar_impuestos
  end
end
