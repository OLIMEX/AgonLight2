;; Terminal
restore:
	jp _cpm_restore
const:
	jp _term_status
conin:
	jp _term_in
conout:
	jp _term_out

;; Disk
home:
	jp _drive_home
settrk:
	jp _drive_trk
setsec:
	jp _drive_sec
setdma:
	jp _drive_dma
read:
	jp _drive_read
write:
	jp _drive_write
select:
	jp _drive_change
