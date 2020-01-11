
# print server hostnames
$oldPrintServer = “OLDSERVERNAME"
$newPrintServer = “NEWSERVERNAME"

# get old printers and set new printers including the default printer 
$oldPrinters = (Get-Printer).Name | where {$_ -match $oldPrintServer} 
if ($oldPrinters.length -gt 1){
    $newPrinters = $oldPrinters.Replace($oldPrintServer, $newPrintServer)
}
$oldDefaultPrinter = (Get-WMIObject -class Win32_Printer -Filter Default=True | Select Name).Name
$newDefaultPrinter = $oldDefaultPrinter.Replace($oldPrintServer, $newPrintServer)

# Define functions
function addPrinters($newPrinters) {
    # add new printers 
    foreach ($new in $newPrinters) {
        echo "adding $new"
        Add-Printer -ConnectionName "$new"
    }
}

function removePrinters($oldPrinters) {
    # remove all old printers 
    foreach ($old in $oldPrinters) {
        echo "removing $old"
        Remove-Printer -Name "$old"
    }
}

function setDefaultPrinter($newDefaultPrinter){
    echo "new default will be $newDefaultPrinter"
    (New-Object -ComObject WScript.Network).SetDefaultPrinter($newDefaultPrinter)
}

# add new and remove the old if there is in fact old printers  
if ($oldPrinters.Length -gt 1) {

    addPrinters($newPrinters)
    removePrinters($oldPrinters)
    setDefaultPrinter($newDefaultPrinter)
    Get-Printer | select name 

}
