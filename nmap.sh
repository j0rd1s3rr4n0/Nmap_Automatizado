#!/bin/bash

if [ $(id -u) -ne 0 ]; then
	echo "[!] Debes ser root para ejecutar el script -> (sudo $0)"
exit 1
fi

test -f /usr/bin/nmap
if [ "$(echo $?)" == "0" ]; then
	read -p "Introduce la IP: " ip
	
	while true; do
  	echo "1) Escaneo rapido pero ruidoso"
  	echo "2) Escaneo Normal"
  	echo "3) Escaneo silencioso (Puede tardar un poco mas de lo normal)"
  	echo "4) Escaneo de serviciosos y versiones"
  	echo "5) Salir"
  	read -p "Selecciona una opción: " opcion
  	case $opcion in
    1)
      clear && echo "Escaneando..." && nmap -p- --open --min-rate 5000 -T5 -sS -Pn -n -v $ip | grep -E "^[0-9]+\/[a-z]+\s+open\s+[a-z]+"
      ;;
    2)
      clear && echo "Escaneando..." && nmap -p- --open $ip
      ;;
    3)
      clear && echo "Escaneando..." && nmap -p- -T2 -sS -Pn -f $ip
      ;;
    4)
	  clear && echo "Escaneando..." && nmap -sV -sC $ip		
	  ;;
	5)
      break
      ;;
    *)
      echo "[!] Opcion no encontrada"
      ;;
  	esac
 done

else
	echo "Hay que instalar dependencias" && apt update >/dev/null && apt install nmap -y >/dev/null && echo "Dependencias instaladas"
fi

finish() {
    echo -e "[*] Cerrando el script..."
    exit 0
}

trap finish SIGINT