# Kjør på en av maskinene (f.eks. cl1)
Invoke-Command -ComputerName cl1.infrait.sec -ScriptBlock {
    gpresult /r /scope:computer
}