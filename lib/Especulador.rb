#encoding: utf-8

module ModeloQytetet
  class Especulador < Jugador
    def initialize(otro, fianza_)
      @factor = 2
      @fianza = fianza_
      @nombre = otro.nombre
      @encarcelado = otro.encarcelado
      @saldo = otro.saldo
      @casilla_actual = otro.casilla_actual
      @propiedades = otro.propiedades
      @carta_libertad = otro.carta_libertad
    end
    
    def pagar_impuestos(cantidad)
      modificar_saldo(-cantidad/2)
    end
    
    def ir_a_carcel(casilla)
      if (!pagar_fianza(@fianza))
        @casilla_actual = casilla
        @encarcelado = true
      end
    end
    
    def convertirme(fianza)
      return self
    end
    
    def pagar_fianza(cantidad)
      if (@saldo >= cantidad)
        modificar_saldo(-cantidad)
        return true
      else
        return false
      end
    end
    
    def to_s
      puts "jugador: \n\tNombre: #{@nombre} \n\tSaldo: #{@saldo} \n\tFactor: #{@factor} \n\tFianza: #{@fianza}  \n"
    end
    
    protected :pagar_impuestos
    private :pagar_fianza
  end
end
