
function Sort-objects($array){
$n=1
while ($n -lt $array.Length) {


$n=$n+1
for ($i=0; $i -lt $array.Length-1 ; $i++){
            if ($array[$i] -gt $array[$i+1]){
                $array[$i], $array[$i+1] = $array[$i+1], $array[$i] 
            }
        }
}
}

$a = 4,1,7,2,6,10,12

Sort-objects $a
Write-Host $a