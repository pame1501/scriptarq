function Start-ProgressBar #definición de la función
{
    [CmdletBinding()] #habilita características de “cmdlet”
    param #define los parámetros que la función recibirá
    (
        [Parameter(Mandatory = $true)] #el parámetro siguiente es obligatorio
        [string]$Title, #Declara un parámetro llamado Title
        [Parameter(Mandatory = $true)] #el parámetro siguiente es obligatorio
        [int]$Timer #Declara un parámetro llamado Timer
    )

    for ($i = 1; $i -le $Timer; $i++) #Inicia un bucle for que seguirá mientras $i sea menor o igual a $Timer, después de cada iteración, $i aumenta en 1
    {
        Start-Sleep -Seconds 1 #Hace una pausa de 1 segundo. Sirve para que la barra de progreso avance lentamente, simule el paso de tiempo

        $percent = [int](($i / $Timer) * 100) #Calcula el porcentaje de avance de la barra: 
                                            #El resultado se guarda en la variable $percent. ($i / $Timer) da un número decimal entre 0 y 1 y lo multiplica por 100 ese será el valor que representa qué tan avanzado va el “progreso”.

        Write-Progress -Activity $Title -Status "$i" -PercentComplete $percent # se define el título de la barra, se usa el número actual $i, para que se vea un contador y el porcentaje de progreso calculado, para que la barra gráfica se ajuste al avance real.
    }
}
