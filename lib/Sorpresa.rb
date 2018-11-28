#enconding: utf-8

module ModeloQytetet
  class Sorpresa
    attr_reader :nombre, :valor, :tipo
    
    def initialize(nombre, valor, tipo)
      @nombre = nombre
      @valor = valor
      @tipo = tipo
    end

    def to_s()
      puts "\nSorpresa: \n\tTexto: #{@nombre} \n\tValor: #{@valor} \n\tTipo: #{@tipo}"
    end
  end
end