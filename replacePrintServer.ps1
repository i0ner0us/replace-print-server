
# print server hostnames
$oldPrintServer = “OLDPRINTSERVER" # change name to reflect old print server
$newPrintServer = “NEWPRINTSERVER" # change name to reflect new print server

# get old printers and set new printers including the default printer 
$oldPrinters = (Get-Printer).Name | where {$_ -match $oldPrintServer} 
if ($oldPrinters.length -gt 1){
    $newPrinters = $oldPrinters.Replace($oldPrintServer, $newPrintServer)
}

# get the old default printer and replace old print server name 
# if the current default printer is in fact on the old server
$oldDefaultPrinter = (Get-WMIObject -class Win32_Printer -Filter Default=True | Select Name).Name
if ($oldDefaultPrinter -contains $oldPrintServer){
    $newDefaultPrinter = $oldDefaultPrinter.Replace($oldPrintServer, $newPrintServer)
}

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
        #verify that the printer is installed before we remove the old printer
        $tmp = (Get-Printer).Name
        $new = $old.Replace($oldPrintServer,$newPrintServer)
        
        if ($tmp -contains $new){
            echo "removing $old"
            Remove-Printer -Name "$old"
        }
        else{
            echo "new printer missing: will not remove $old"
        }
    }
}

function setDefaultPrinter($newDefaultPrinter){
    echo "new default will be $newDefaultPrinter"
    (New-Object -ComObject WScript.Network).SetDefaultPrinter($newDefaultPrinter)
}

# add new and remove the old if there is in fact old printers  
if ($oldPrinters.Length -gt 1) {
    # add new printers first before anything
    addPrinters($newPrinters)
    
    # check to be sure that the new default printer was successfully added
    # map the new default printer if it exist
    $tmp = (Get-Printer).Name
    if ($tmp -contains $oldDefaultPrinter) {
        setDefaultPrinter($newDefaultPrinter)
        } 
    
    # verify that all the old printers were replaced with new printers before removing the old
    removePrinters($oldPrinters)

}
