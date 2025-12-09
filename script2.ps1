# script3.ps1
function New-FolderCreation {   #Se define una función que crea una carpeta
    [CmdletBinding()] #permite que la función tenga parámetros, validaciones, ayuda
    param(
        [Parameter(Mandatory = $true)]
        [string]$foldername # La función recibe un solo parámetro, obligatorio, llamado foldername
    )

    # Create absolute path for the folder relative to current location
    #Se crea una ruta absoluta usando la ubicación actual del usuario.
    $logpath = Join-Path -Path (Get-Location).Path -ChildPath $foldername
    if (-not (Test-Path -Path $logpath)) { # Si la carpeta NO existe, entonces la crea.
        New-Item -Path $logpath -ItemType Directory -Force | Out-Null #Evita mostrar contenido "Basura"
    }

    return $logpath #Devolver la ruta creada
}

function Write-Log { #Esta función crea archivo de log 
    [CmdletBinding()] #permite que la función tenga parámetros, validaciones, ayuda
    param(
        # Creación de parámetros
        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [Alias('Names')] # puede crear varios archivos.
        [object]$Name,                    # can be single string or array

        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [string]$Ext, # Se asigna la extensión del archivo

        [Parameter(Mandatory = $true, ParameterSetName = 'Create')]
        [string]$folder, #Indica la carpeta donde se guardarán los archivos.

        [Parameter(ParameterSetName = 'Create', Position = 0)]
        [switch]$Create, #Activador que indica que se usará el modo Create.

        # Message parameter set - Parámetros del modo "Message"
        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [string]$message, #Mensaje a escribir en el archivo.

        [Parameter(Mandatory = $true, ParameterSetName = 'Message')]
        [string]$path, #Ruta completa donde se escribirá el mensaje.

        [Parameter(Mandatory = $false, ParameterSetName = 'Message')]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information', #Nivel de severidad del mensaje (color y categoría).

        [Parameter(ParameterSetName = 'Message', Position = 0)]
        [switch]$MSG #Activador que indica que se usa el modo Message.
    )

    switch ($PsCmdlet.ParameterSetName) { #detecta automáticamente si el usuario llamó el parámetro -Create o -MSG
        "Create" {
            $created = @()

            # Normalize $Name to an array
            $namesArray = @() #Convierte $Name a arreglo, aunque solo tenga 1 valor.
            if ($null -ne $Name) {
                if ($Name -is [System.Array]) { $namesArray = $Name }
                else { $namesArray = @($Name) }
            }

            # Date + time formatting (safe for filenames) / Formatos seguros para nombre de archivos.
            $date1 = (Get-Date -Format "yyyy-MM-dd")
            $time  = (Get-Date -Format "HH-mm-ss")

            # Ensure folder exists and get absolute folder path
            #Llama a la función anterior.
            $folderPath = New-FolderCreation -foldername $folder

            #Bucle: crear archivo por cada nombre
            foreach ($n in $namesArray) {
                # sanitize name to string
                $baseName = [string]$n # Convertir nombre a texto:

                # Construir nombre del archivo
                $fileName = "${baseName}_${date1}_${time}.$Ext"

                # Ruta completa del archivo
                $fullPath = Join-Path -Path $folderPath -ChildPath $fileName

                # Create the file (New-Item -Force will create or overwrite; use -ErrorAction Stop to catch errors)
                try {
                    # If you prefer to NOT overwrite existing file, use: if (-not (Test-Path $fullPath)) { New-Item ... }
                    New-Item -Path $fullPath -ItemType File -Force -ErrorAction Stop | Out-Null

                    # Optionally write a header line (uncomment if desired)
                    # "Log created: $(Get-Date)" | Out-File -FilePath $fullPath -Encoding UTF8 -Append

                    $created += $fullPath #Guardar ruta creada
                }
                catch {
                    Write-Warning "Failed to create file '$fullPath' - $_"
                }
            }

            return $created
        }

        "Message" {
            # Asegurar carpeta del archivo
            $parent = Split-Path -Path $path -Parent
            if ($parent -and -not (Test-Path -Path $parent)) {
                New-Item -Path $parent -ItemType Directory -Force | Out-Null
            }
            #Crear mensaje con fecha y severidad
            $date = Get-Date
            $concatmessage = "|$date| |$message| |$Severity|"
            # Colores en pantalla según severidad
            switch ($Severity) {
                "Information" { Write-Host $concatmessage -ForegroundColor Green }
                "Warning"     { Write-Host $concatmessage -ForegroundColor Yellow }
                "Error"       { Write-Host $concatmessage -ForegroundColor Red }
            }

            # Añadir mensaje al archivo, si el archivo no existe lo crea
            Add-Content -Path $path -Value $concatmessage -Force

            return $path
        }

        default {
            throw "Unknown parameter set: $($PsCmdlet.ParameterSetName)"
        }
    }
}

# ---------- Ejemplo ----------
# Crea una carpeta logs
$logPaths = Write-Log -Name "Name-Log" -folder "logs" -Ext "log" -Create #Devuelve la ruta completa del archivo creado.
$logPaths