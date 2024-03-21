#ifndef UPDATER_H
#define UPDATER_H

#include "vdu_stream_processor.h"
#include <cstdint>
#include "esp_ota_ops.h"

extern void printFmt(const char *format, ...);
extern void print(const char * text);

namespace Updater {
	static constexpr uint8_t unlockCode[] = "unlock";
	static bool isLocked = true;
}

void VDUStreamProcessor::unlock() {
	uint8_t buffer[sizeof(Updater::unlockCode)] = {0};
	uint32_t bytes_remain = readIntoBuffer(buffer, sizeof(buffer) - 1);
	if(bytes_remain) {
		printFmt("Read unlock code failed!\n\r");
		return;
	}
	else if(memcmp(buffer, Updater::unlockCode, sizeof(Updater::unlockCode)) == 0) {
		printFmt("Updater unlocked!\n\r");
		Updater::isLocked = false;
		return;
	}
}

void VDUStreamProcessor::receiveFirmware() {
	uint32_t update_size = 0;
	uint32_t bytes_remain = readIntoBuffer((uint8_t*)&update_size, sizeof(update_size) - 1); // -1 because its 24bits
	if(bytes_remain) {
		printFmt("Read size failed!\n\r");
		return;
	}

	if(Updater::isLocked) {
		printFmt("Updater is locked, bytes will be discarded!\n\r");
		discardBytes(update_size + 1);
		return;
	}
	
	printFmt("Received update size: %u bytes\n\r", update_size);

	printFmt("Receiving VDP firmware update");

	uint32_t start = millis();

	esp_err_t err;
	esp_ota_handle_t update_handle = 0 ;
	const esp_partition_t *update_partition = NULL;
//	const esp_partition_t *configured = esp_ota_get_boot_partition();
//	const esp_partition_t *running = esp_ota_get_running_partition();

	update_partition = esp_ota_get_next_update_partition(NULL);
	err = esp_ota_begin(update_partition, OTA_SIZE_UNKNOWN, &update_handle);
	if (err != ESP_OK) {
		printFmt("esp_ota_begin failed, error=%d\n\r", err);
		discardBytes(update_size + 1);
		return;
	}

	uint32_t remaining_bytes = update_size;
	uint8_t code = 0;
	const size_t buffer_size = 1024;

	while(remaining_bytes > 0) {

		size_t bytes_to_read = buffer_size;

		if(remaining_bytes < buffer_size)
		{
			bytes_to_read = remaining_bytes;
		}

		uint8_t buffer[buffer_size];

		bytes_remain = readIntoBuffer(buffer, bytes_to_read);
		if(bytes_remain) {
			printFmt("\n\rRead buffer failed at byte %u!\n\r", remaining_bytes);
			return;
		}

		for(int i = 0; i < bytes_to_read; i++) {
			code += ((uint8_t*)buffer)[i];
		}

		print(".");
		remaining_bytes -= bytes_to_read;

		err = esp_ota_write( update_handle, (const void *)buffer, bytes_to_read);
		if (err != ESP_OK) {
			printFmt("\n\resp_ota_write failed, error=%d\n'r", err);
			discardBytes(remaining_bytes + 1);
			return;
		}
	}
	print("\n\r");
	
	uint32_t end = millis();
	printFmt("Upload done in %u ms\n\r", end - start);
	printFmt("Bandwidth: %u kbit/s\n\r", update_size / (end - start) * 8);
	
	// checksum check
	auto checksum_complement = readByte_t();
	if (checksum_complement == -1) {
		printFmt("Checksum not received!\n\r");
		return;
	}
	printFmt("checksum_complement: 0x%x\n\r", checksum_complement);
	if(uint8_t(code + (uint8_t)checksum_complement)) {
		printFmt("checksum error!\n\r");
		return;
	}
	printFmt("checksum ok!\n\r");

	err = esp_ota_set_boot_partition(update_partition);
	if (err != ESP_OK) {
		printFmt("esp_ota_set_boot_partition failed! err=0x%x\n\r", err);
		return;
	}

	print("Rebooting in ");
	for(int i = 3; i > 0; i--) {
		printFmt("%d...", i);
		delay(1000);
	}
	print("0!\n\r");
	
	esp_restart();
}

void VDUStreamProcessor::switchFirmware() {
	if (Updater::isLocked) {
		printFmt("Updater is locked!\n\r");
		return;
	}

	esp_err_t err;
	const esp_partition_t *running = esp_ota_get_running_partition();
	const esp_partition_t *update_partition = esp_ota_get_next_update_partition(running);

	// TODO: check if update_partition is valid
	err = esp_ota_set_boot_partition(update_partition);
	if (err != ESP_OK) {
		printFmt("esp_ota_set_boot_partition failed! err=0x%x\n\r", err);
	}
	printFmt("restart!\n\r");
	esp_restart();
}

void VDUStreamProcessor::vdu_sys_updater() {
	auto mode = readByte_t();
	switch(mode) {
		case 0: {
			unlock();
		} break;
		case 1: {
			receiveFirmware();
		} break;
		case 2: {
			switchFirmware();
		} break;
	}
}

#endif // UPDATER_H
