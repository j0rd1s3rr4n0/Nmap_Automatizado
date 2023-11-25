#!/bin/bash

# Definición de colores para mejorar la presentación del script
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
grayColour="\e[0;37m\033[1m"

# Función para verificar y realizar la instalación de nmap si es necesario
install_nmap() {
  if ! command -v nmap &> /dev/null; then
    echo -e "$greenColour[+]$grayColour Instalando nmap..."
    sudo apt-get install nmap -y > /dev/null 2>&1 || sudo dnf install nmap -y > /dev/null 2>&1 || sudo pacman -S nmap -y > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "$redColour[!]$grayColour Fallo al instalar nmap. Por favor, instálalo manualmente."
      exit 1
    fi
  fi
}

# Función para realizar un ping a una IP ingresada por el usuario
get_target_ip() {
  local target_ip
  read -rep "$greenColour[?]$grayColour Introduce la IP: " target_ip

  if ! ping -c 1 "$target_ip" > /dev/null 2>&1; then
    echo -e "$redColour[!]$grayColour La IP no está activa."
    get_target_ip
  fi

  echo "$target_ip"
}

# Función para manejar errores durante el escaneo personalizado
handle_custom_scan_error() {
  echo -e "$redColour[!]$grayColour Error durante el escaneo personalizado. Asegúrate de proporcionar parámetros válidos."
}

# Función para realizar escaneos interactivos
perform_interactive_scan() {
  local target_ip="$1"
  echo -e "\nSeleccione el tipo de escaneo:"
  echo "1) Escaneo rápido pero ruidoso"
  echo "2) Escaneo Normal"
  echo "3) Escaneo silencioso (Puede tardar un poco más de lo normal)"
  echo "4) Escaneo de servicios y versiones"
  echo "5) Escaneo personalizado"
  echo "6) Exportar resultados a un archivo (formato Nmap)"
  echo "7) Volver al menú principal"
  read -rep "$greenColour[?]$grayColour Seleccione una opción: " scan_option

  case $scan_option in
    1)
      # Escaneo rápido pero ruidoso
      nmap -p- --open --min-rate 5000 -T5 -sS -Pn -n -v "$target_ip" | grep -E "^[0-9]+\/[a-z]+\s+open\s+[a-z]+"
      ;;
    2)
      # Escaneo normal
      nmap -p- --open "$target_ip" | grep -E "^[0-9]+\/[a-z]+\s+open\s+[a-z]+"
      ;;
    3)
      # Escaneo silencioso
      nmap -p- -T2 -sS -Pn -f "$target_ip" | grep -E "^[0-9]+\/[a-z]+\s+open\s+[a-z]+"
      ;;
    4)
      # Escaneo de servicios y versiones
      nmap -sV -sC "$target_ip"
      ;;
    5)
      # Escaneo personalizado
      custom_scan "$target_ip"
      ;;
    6)
      # Exportar resultados a un archivo (formato Nmap)
      export_results "$target_ip"
      ;;
    7)
      # Volver al menú principal
      return
      ;;
    *)
      echo -e "$redColour[!]$grayColour Opción no válida"
      ;;
  esac
}

# Función para realizar un escaneo personalizado
custom_scan() {
  local target_ip="$1"
  local custom_params
  read -rep "$greenColour[?]$grayColour Introduce los parámetros del escaneo personalizado (por ejemplo, -p 80,443 -sV): " custom_params

  # Manejar errores durante el escaneo personalizado
  nmap "$custom_params" "$target_ip" || handle_custom_scan_error
}

# Función para exportar resultados a un archivo (formato Nmap)
export_results() {
  local target_ip="$1"
  local export_file
  read -rep "$greenColour[?]$grayColour Introduce el nombre del archivo de exportación (sin extensión): " export_file

  # Exportar resultados en varios formatos de Nmap
  echo -e "\nSeleccione el formato de exportación:"
  echo "1) Formato normal de Nmap (.nmap)"
  echo "2) Formato XML de Nmap (.xml)"
  echo "3) Volver al menú anterior"
  read -rep "$greenColour[?]$grayColour Seleccione una opción: " export_option

  case $export_option in
    1)
      nmap -p- --open --min-rate 5000 -T5 -sS -Pn -n -v -oN "$export_file.nmap" "$target_ip"
      echo -e "$greenColour[+]$grayColour Resultados exportados a '$export_file.nmap'"
      ;;
    2)
      nmap -p- --open --min-rate 5000 -T5 -sS -Pn -n -v -oX "$export_file.xml" "$target_ip"
      echo -e "$greenColour[+]$grayColour Resultados exportados a '$export_file.xml'"
      ;;
    3)
      # Volver al menú anterior
      return
      ;;
    *)
      echo -e "$redColour[!]$grayColour Opción no válida"
      ;;
  esac
}

# Verificar que el script se esté ejecutando como root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "$redColour[!]$grayColour Debes ejecutar el script como root -> (sudo $0)"
  exit 1
fi

# Funciones mejor organizadas y comentarios más detallados
install_nmap
clear
target_ip=$(get_target_ip)

while true; do
  # Menú de opciones para el usuario
  echo -e "\n1) Realizar escaneo interactivo"
  echo "2) Salir"
  read -rep "$greenColour[?]$grayColour Seleccione una opción: " main_option

  case $main_option in
    1)
      perform_interactive_scan "$target_ip"
      ;;
    2)
      break
      ;;
    *)
      echo -e "$redColour[!]$grayColour Opción no válida"
      ;;
  esac
done

# Función para manejar la interrupción del script (Ctrl+C)
finish() {
  echo -e "\n$redColour[!]$grayColour Cerrando el script..."
  exit
}

# Asignar la función finish al evento de interrupción (Ctrl+C)
trap finish SIGINT
