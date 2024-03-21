$port = $args[0]

if($null -eq $port) {
	$ports = [System.IO.Ports.SerialPort]::getportnames()
	$portcount = ($ports | measure-object).count
	if($portcount -gt 1) {
		Write-Output "Too many COM ports active for automatic selection"
		Write-Output "Please specify a COM port as argument:"
		Write-Output $ports
		exit
	}
	$port = $ports
}

$message = "Using {0}" -f $port
Write-Output $message
.\esptool.exe --chip esp32 --port $port --baud 921600  --before default_reset --after hard_reset write_flash  -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 "bootloader.bin" 0x8000 "partitions.bin" 0x10000 "firmware.bin" 