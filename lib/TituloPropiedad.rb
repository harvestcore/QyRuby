#encoding: utf-8

module ModeloQytetet
  class TituloPropiedad    
    attr_accessor :nombre, :hipotecada, :alquilerBase, :factorRevalorizacion, :hipotecaBase, :precioEdificar, :casilla, :propietario
    
    def initialize(unNombre, unAlquilerBase, unFactorRevalorizacion, unaHipotecaBase, unPrecioEdificar)
      @nombre = unNombre
      @hipotecada = false
      @alquilerBase = unAlquilerBase
      @factorRevalorizacion = unFactorRevalorizacion
      @hipotecaBase = unaHipotecaBase
      @precioEdificar = unPrecioEdificar
      @casilla = nil
      @propietario = nil
    end

    def cobrar_alquiler(coste)
      @propietario.modificar_saldo(coste)
    end
    
    def propietario_encarcelado
      return @propietario.encarcelado
    end
    
    def tengo_propietario
      return @propietario != nil
    end
    
    def to_s()
      puts "Titulo Propiedad: \n\tNombre: #{@nombre} \n\tHipotecada: #{@hipotecada} \n\tAlquiler Base: #{@alquilerBase} \n\tFactor Revalorizacion: #{@factorRevalorizacion} \n\tHipoteca Base: #{@hipotecaBase} \n\tPrecio Edificar: #{@precioEdificar}"
    end    
  end
end
