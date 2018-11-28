#encoding: utf-8

module ModeloQytetet
  class Calle < Casilla
    attr_accessor :numeroCasilla, :coste, :numeroHoteles, :numeroCasas, :tipo, :titulo
    
    def initialize(unNumeroCasilla, unCoste, titulo)
      @numeroCasilla = unNumeroCasilla
      @coste = unCoste
      @tipo = TipoCasilla::CALLE
      @titulo = titulo
      @titulo.casilla = self
      @numeroHoteles = 0
      @numeroCasas = 0
    end
    
    def calcular_valor_hipoteca
      return @titulo.hipotecaBase + (@numeroCasas * 0.5 * @titulo.hipotecaBase + @numeroHoteles * @titulo.hipotecaBase)
    end
      
    def cancelar_hipoteca
      @titulo.hipotecada = false
      return get_coste_hipoteca
    end
    
    def get_coste_hipoteca
      return calcular_valor_hipoteca + calcular_valor_hipoteca * 0.1
    end
    
    def cobrar_alquiler
      coste_alquiler_base = @titulo.alquilerBase
      coste_alquiler = coste_alquiler_base + (@numeroCasas * 0.5 + @numeroHoteles * 2)
      @titulo.cobrar_alquiler(coste_alquiler)
      
      return coste_alquiler
    end
    
    def edificar_casa
      @numeroCasas += 1
      return @titulo.precioEdificar
    end
    
    def edificar_hotel
      @numeroHoteles += 1
      return @titulo.precioEdificar
    end
    
    def hipotecar
      @titulo.hipotecada = true
      return calcular_valor_hipoteca
    end

    def propietario_encarcelado
      return @titulo.propietario_encarcelado
    end
    
    def se_puede_edificar_casa(factor)
      return @numeroCasas < (4*factor)
    end
    
    def se_puede_edificar_hotel(factor)
      return @numeroHoteles < (4*factor)
    end
    
    def esta_hipotecada
      return @titulo.hipotecada == true
    end
    
    def set_propietario(propietario)
      @titulo.propietario = propietario
      return @titulo
    end
    
    def soy_edificable
      return @tipo == TipoCasilla::CALLE
    end
       
    def tengo_propietario
      return @titulo.tengo_propietario
    end
    
    def vender_titulo
      @titulo.propietario = nil
      @numeroCasas = 0
      @numeroHoteles = 0
      precio_compra = (@coste + (@numeroCasas + @numeroHoteles) * @titulo.factorRevalorizacion)
      return (precio_compra + @titulo.factorRevalorizacion * precio_compra)
    end
    
    def to_s
      puts "\nCasilla: \n\tNumero Casilla: #{@numeroCasilla} \n\tCoste: #{@coste} \n\tNumero Hoteles: #{@numeroHoteles} \n\tNumero Casas: #{@numeroCasas} \n\tTipo: #{@tipo}"
        @titulo.to_s
    end
  end
end
