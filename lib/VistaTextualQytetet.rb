#encoding: utf-8

require_relative "Qytetet"
require_relative "Casilla"
require_relative "Jugador"
require_relative "MetodosSalirCarcel"
require_relative "TipoCasilla"

module InterfazTextualQytetet
  class VistaTextualQytetet
    include ModeloQytetet
    
    def initialize
    end
    
    def seleccion_menu(menu)
      begin #Hasta que se hace una seleccionn valida
        valido= true
        
        for m in menu #se muestran las opciones del menu
          puts "\t(#{m[0]}) - #{m[1]}\n"
        end
        
        puts "\n[>] Elige una opcion: "
        captura = gets.chomp
        valido=comprobar_opcion(captura, 0, menu.length-1) #metodo para comprobar la eleccion correcta
       
      end while (! valido)
      
      return Integer(captura)  
    end
    
    def comprobar_opcion(captura,min,max)
      # metodo para comprobar si la opcion introducida es correcta, usado por seleccion_menu
       valido=true
       begin
          opcion = Integer(captura)
          if (opcion<min || opcion>max) #No es un entero entre los validos
            valido = false
            puts "\n[err] El numero debe estar entre min y max.\n"
          end
        rescue Exception => e  #No se ha introducido un entero
          valido = false
          puts"\n[err] Debes introducir un numero.\n\n"
       end 
       
      return valido
    end
  
    def menu_gestion_inmobiliaria
      menuGI = Array.new
      puts "\n[+] Elige la gestion inmobiliaria que deseas hacer:\n"
      
      menuGI << [0, "Atras."]
      menuGI << [1, "Edificar casa."]
      menuGI << [2, "Edificar hotel."]
      menuGI << [3, "Vender propiedad."]
      menuGI << [4, "Hipotecar propiedad."]
      menuGI << [5, "Cancelar hipoteca."]     
      
      salida = seleccion_menu(menuGI)
      
      return salida
    end

    def menu_salir_carcel
      menuSC = Array.new
      puts "\n[i] Te encuentras en la carcel."
      puts "[?] Que quieres hacer?"
      
      menuSC << [0, "Pagar libertad."]
      menuSC << [1, "Tirar dado."]

      return seleccion_menu(menuSC) + 1
    end
    
    def menu_fin_turno
      menuFT = Array.new
      puts "\n[?] Que quieres hacer ahora?\n"
      
      menuFT << [0, "Ver mis propiedades."]
      menuFT << [1, "Gestiones inmobiliarias."]
      menuFT << [2, "Pasar turno."]
      
      return seleccion_menu(menuFT) + 1
    end

    def elegir_quiero_comprar
      quiero_comprar = false
      menuQC = Array.new
      puts "\n[?] Quieres comprar la propiedad?"
      menuQC << [0, "Si."]
      menuQC << [1, "No."]
      
      if(seleccion_menu(menuQC) == 0)
        quiero_comprar = true
      end
      
      return quiero_comprar      
    end
      
    def menu_elegir_propiedad(listaPropiedades) # numero y nombre de propiedades            
      menuEP = Array.new
      numero_opcion = 0
      puts "\n[+] Elige una propiedad:"
      for prop in listaPropiedades
          menuEP << [numero_opcion, prop] # opcion de menu, numero y nombre de propiedad
          numero_opcion=numero_opcion + 1
      end
      salida = seleccion_menu(menuEP) # Método para controlar la elección correcta en el menú 

      return salida
    end  

    def obtener_nombre_jugadores
      nombres=Array.new
      valido = true 
      begin
        puts "[+] Escribe el numero de jugadores (2-4): "
        lectura = gets.chomp #lectura de teclado
        valido = comprobar_opcion(lectura, 2, 4) #método para comprobar la elección correcta
      end while(!valido)

      for i in 1..Integer(lectura)  #pide nombre de jugadores y los mete en un array
         puts "Jugador: #{i.to_s}: "
         nombre = gets.chomp
         nombres << nombre
      end
      
      return nombres
    end

    def mostrar(texto)  #metodo para mostrar el string que recibe como argumento
      puts texto
    end
    
    def info_principio_turno(jugador_actual, casilla_actual)
      puts "\n###########################################\n"
      puts "\n[i] Turno de: #{jugador_actual.nombre} \n"
      puts "\n[i] Casilla actual de #{jugador_actual.nombre}: #{casilla_actual.numeroCasilla}\n"
      puts "[i] Saldo de #{jugador_actual.nombre }: #{jugador_actual.saldo}"
    end
    
    def info(jugador_actual, casilla_actual)
      puts "\n[i] #{jugador_actual.nombre} esta en la casilla numero #{casilla_actual.numeroCasilla}."
      casilla_actual.to_s     
    end
    
    def jugador_liberado(jugador_actual)
      puts "\n[i] #{jugador_actual.nombre} ha sido liberado."
    end
    
    def jugador_encarcelado(jugador_actual)
      puts "\n[i] El jugador #{jugador_actual.nombre} ha sido encarcelado."
    end
    
    def jugador_en_la_carcel(jugador_actual)
      puts "\n[i] El jugador #{jugador_actual.nombre} esta en la carcel."
    end
    
    def pause
      puts "\n[-] Pulsa una tecla para continuar...: "
      gets.chomp
    end
    
    def show_game(juego)
      puts "\n"
      
      puts "[?] Mostrar jugadores?: "
      respuesta = gets.chomp
      if (respuesta == "s")      
        juego.get_jugadores
      end
      puts "\n"
      
      puts "[?] Mostrar cartas?: "
      respuesta = gets.chomp
      if (respuesta == "s")
        juego.show_mazo
      end
      puts "\n"
      
      puts "[?] Mostrar tablero?: "
      respuesta = gets.chomp
      if (respuesta == "s")
        juego.show_tablero
      end
      puts "\n"
      puts "~~~~~~~COMIENZA EL JUEGO~~~~~~~"
      pause
    end
    
    def compra(casilla, jugador)
      puts "\n[!] Enhorabuena, has comprado: #{casilla.titulo.nombre}"
      puts "\n[i] Saldo actual: #{jugador.saldo}"
    end
    
    def mostrar_propiedades(jugador)
      aux = jugador.get_propiedades(3)
      
      if (aux.length > 0)
        puts "\n[i] Propiedades:"
        for s in aux
          puts "\t #{s}"
        end
      
      else
        puts "\n[!] Aun no tienes propiedades."
      end
    end
    
    def texto_inmobiliario(casilla, jugador, modo)
      case modo
        when 1
          puts "\n[i] Has edificado una casa en: #{casilla.titulo.nombre}"
          puts "[i] Casas construidas en la casilla: #{casilla.numeroCasas}"
          puts "[i] Saldo actual: #{jugador.saldo}"

        when 2
          puts "\n[i] Has edificado un hotel en: #{casilla.titulo.nombre}"
          puts "[i] Hoteles construidos en la casilla: #{casilla.numeroHoteles}"
          puts "[i] Saldo actual: #{jugador.saldo}"
      
        when 3
          puts "\n[i] Has vendido la propiedad: #{casilla.titulo.nombre}"
          puts "[i] Saldo actual: #{jugador.saldo}"
          
        when 4
          puts "\n[i] Has hipotecado la propiedad: #{casilla.titulo.nombre}"
          puts "[i] Saldo actual: #{jugador.saldo}"
          
        when 5
          puts "\n[i] Has cancelado la hipoteca la propiedad: #{casilla.titulo.nombre}"
          puts "[i] Saldo actual: #{jugador.saldo}"
        
        when 6
          puts "\n[i] No tienes propiedades donde edificar casas."
          
        when 7
          puts "\n[i] No tienes propiedades donde edificar hoteles."
          
        when 8
          puts "\n[i] No tienes propiedades para vender."
          
        when 9
          puts "\n[i] No tienes propiedades disponibles para hipotecar."
          
        when 10
          puts "\n[i] No tienes propiedades hipotecadas."
          
        when 11
          puts "\n[i] No puedes construir mas casas en esta casilla."
          
        when 12
          puts "\n[i] No puedes construir mas hoteles en esta casilla."
        
      end
    end
    
    def wellcome
      puts "#############################"
      puts "#  BIENVENIDO A QYTETET xD  #"
      puts "#############################"
      puts "\n"
    end
    
    def end_game(ranking, juego)
      puts "\n[!!] Has caido en bancarrota, fin del juego."
      puts "\n[i] RANKING:\n"
      juego.jugadores.each do |j|
        puts "Capital de #{j.nombre}: #{ranking[j.nombre]} \n"
      end
    end   
    
    private :comprobar_opcion, :seleccion_menu
      
  end
end
