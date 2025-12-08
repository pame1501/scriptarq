###################################
# Prerequisitos

# Actualiza la lista de paquetes disponibles en los repositorios
sudo apt-get update

# Instalar paquetes necesarios antes de continuar
sudo apt-get install -y wget apt-transport-https software-properties-common

# Obtener versión del sistema operativo
source /etc/os-release

# Descargar la clave del repositorio de Microsoft
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb

# Registrar el repositorio de Microsoft
sudo dpkg -i packages-microsoft-prod.deb

# Borrar el archivo descargado
rm packages-microsoft-prod.deb

# Actualizar nuevamente la lista de paquetes
sudo apt-get update

###################################
# Instalar PowerShell
sudo apt-get install -y powershell

# Empezar PowerShell
pwsh