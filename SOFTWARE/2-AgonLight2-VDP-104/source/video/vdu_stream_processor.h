#ifndef VDU_STREAM_PROCESSOR_H
#define VDU_STREAM_PROCESSOR_H

#include <memory>
#include <Stream.h>

#include "agon.h"
#include "agon_ps2.h"
#include "buffer_stream.h"
#include "types.h"
#include "viewport.h"

class VDUStreamProcessor {
	private:
		std::shared_ptr<Stream> inputStream;
		std::shared_ptr<Stream> outputStream;
		std::shared_ptr<Stream> originalOutputStream;

		int16_t readByte_t(uint16_t timeout);
		int32_t readWord_t(uint16_t timeout);
		int32_t read24_t(uint16_t timeout);
		uint8_t readByte_b();
		uint32_t readIntoBuffer(uint8_t * buffer, uint32_t length, uint16_t timeout);
		uint32_t discardBytes(uint32_t length, uint16_t timeout);

		void vdu_colour();
		void vdu_gcol();
		void vdu_palette();
		void vdu_mode();
		void vdu_graphicsViewport();
		void vdu_plot();
		void vdu_resetViewports();
		void vdu_textViewport();
		void vdu_origin();
		void vdu_cursorTab();

		void vdu_sys();
		void vdu_sys_video();
		void sendGeneralPoll();
		void vdu_sys_video_kblayout();
		void sendCursorPosition();
		void sendScreenChar(uint16_t x, uint16_t y);
		void sendScreenPixel(uint16_t x, uint16_t y);
		void sendTime();
		void vdu_sys_video_time();
		void sendKeyboardState();
		void vdu_sys_keystate();
		void vdu_sys_mouse();
		void vdu_sys_scroll();
		void vdu_sys_cursorBehaviour();
		void vdu_sys_udg(char c);

		void vdu_sys_audio();
		void sendAudioStatus(uint8_t channel, uint8_t status);
		uint8_t loadSample(uint16_t bufferId, uint32_t length);
		uint8_t createSampleFromBuffer(uint16_t bufferId, uint8_t format);
		void setVolumeEnvelope(uint8_t channel, uint8_t type);
		void setFrequencyEnvelope(uint8_t channel, uint8_t type);

		void vdu_sys_sprites(void);
		void receiveBitmap(uint8_t cmd, uint16_t width, uint16_t height);
		void createBitmapFromBuffer(uint16_t bufferId, uint8_t format, uint16_t width, uint16_t height);

		void vdu_sys_hexload(void);
		void sendKeycodeByte(uint8_t b, bool waitack);

		void vdu_sys_buffered();
		uint32_t bufferWrite(uint16_t bufferId, uint32_t size);
		void bufferCall(uint16_t bufferId, uint32_t offset);
		void bufferClear(uint16_t bufferId);
		std::shared_ptr<WritableBufferStream> bufferCreate(uint16_t bufferId, uint32_t size);
		void setOutputStream(uint16_t bufferId);
		uint32_t getOffsetFromStream(uint16_t bufferId, bool isAdvanced);
		std::vector<uint16_t> getBufferIdsFromStream();
		int16_t getBufferByte(uint16_t bufferId, uint32_t offset);
		bool setBufferByte(uint8_t value, uint16_t bufferId, uint32_t offset);
		void bufferAdjust(uint16_t bufferId);
		bool bufferConditional();
		void bufferJump(uint16_t bufferId, uint32_t offset);
		void bufferCopy(uint16_t bufferId, std::vector<uint16_t> sourceBufferIds);
		void bufferConsolidate(uint16_t bufferId);
		void bufferSplitInto(uint16_t bufferId, uint16_t length, std::vector<uint16_t> newBufferIds, bool iterate);
		void bufferSplitByInto(uint16_t bufferId, uint16_t width, uint16_t chunkCount, std::vector<uint16_t> newBufferIds, bool iterate);
		void bufferSpreadInto(uint16_t bufferId, std::vector<uint16_t> newBufferIds, bool iterate);
		void bufferReverseBlocks(uint16_t bufferId);
		void bufferReverse(uint16_t bufferId, uint8_t options);

		void vdu_sys_updater();
		void unlock();
		void receiveFirmware();
		void switchFirmware();

	public:
		uint16_t id = 65535;

		VDUStreamProcessor(std::shared_ptr<Stream> input, std::shared_ptr<Stream> output, uint16_t bufferId) :
			inputStream(input), outputStream(output), originalOutputStream(output), id(bufferId) {}
		VDUStreamProcessor(Stream *input) :
			inputStream(std::shared_ptr<Stream>(input)), outputStream(inputStream), originalOutputStream(inputStream) {}

		inline bool byteAvailable() {
			return inputStream->available() > 0;
		}
		inline uint8_t readByte() {
			return inputStream->read();
		}
		inline void writeByte(uint8_t b) {
			if (outputStream) {
				outputStream->write(b);
			}
		}
		void send_packet(uint8_t code, uint16_t len, uint8_t data[]);

		void sendMouseData(MouseDelta * delta);

		void processAllAvailable();
		void processNext();

		void vdu(uint8_t c);

		void wait_eZ80();
		void sendModeInformation();
};

// Read an unsigned byte from the serial port, with a timeout
// Returns:
// - Byte value (0 to 255) if value read, otherwise -1
//
int16_t VDUStreamProcessor::readByte_t(uint16_t timeout = COMMS_TIMEOUT) {
	auto t = millis();

	while (millis() - t <= timeout) {
		if (byteAvailable()) {
			return readByte();
		}
	}
	return -1;
}

// Read an unsigned word from the serial port, with a timeout
// Returns:
// - Word value (0 to 65535) if 2 bytes read, otherwise -1
//
int32_t VDUStreamProcessor::readWord_t(uint16_t timeout = COMMS_TIMEOUT) {
	auto l = readByte_t(timeout);
	if (l >= 0) {
		auto h = readByte_t(timeout);
		if (h >= 0) {
			return (h << 8) | l;
		}
	}
	return -1;
}

// Read an unsigned 24-bit value from the serial port, with a timeout
// Returns:
// - Value (0 to 16777215) if 3 bytes read, otherwise -1
//
int32_t VDUStreamProcessor::read24_t(uint16_t timeout = COMMS_TIMEOUT) {
	auto l = readByte_t(timeout);
	if (l >= 0) {
		auto m = readByte_t(timeout);
		if (m >= 0) {
			auto h = readByte_t(timeout);
			if (h >= 0) {
				return (h << 16) | (m << 8) | l;
			}
		}
	}
	return -1;
}

// Read an unsigned byte from the serial port (blocking)
//
uint8_t VDUStreamProcessor::readByte_b() {
	while (inputStream->available() == 0);
	return readByte();
}

// Read a given number of bytes from the serial port into a buffer
// Returns number of remaining bytes
// which should be zero if all bytes were read
// but will be non-zero if the read timed out
//
uint32_t VDUStreamProcessor::readIntoBuffer(uint8_t * buffer, uint32_t length, uint16_t timeout = COMMS_TIMEOUT) {
	uint32_t remaining = length;
	if (buffer == nullptr) {
		debug_log("readIntoBuffer: buffer is null\n\r");
		return remaining;
	}
	auto t = xTaskGetTickCountFromISR();
	auto now = t;
	auto timeCheck = pdMS_TO_TICKS(timeout);

	while (remaining > 0) {
		now = xTaskGetTickCountFromISR();
		if (now - t > timeCheck) {
			debug_log("readIntoBuffer: timed out\n\r");
			return remaining;
		}
		auto available = inputStream->available();
		if (available > 0) {
			if (available > remaining) {
				available = remaining;
			}
			// debug_log("readIntoBuffer: reading %d bytes\n\r", available);
			inputStream->readBytes(buffer, available);
			buffer += available;
			remaining -= available;
			t = now;
		}
	}
	return remaining;
}

// Discard a given number of bytes from input stream
// Returns 0 on success, or the number of bytes remaining if timed out
//
uint32_t VDUStreamProcessor::discardBytes(uint32_t length, uint16_t timeout = COMMS_TIMEOUT) {
	uint32_t remaining = length;
	auto bufferSize = 64;
	auto readSize = bufferSize;
	auto buffer = make_unique_psram_array<uint8_t>(bufferSize);

	while (remaining > 0) {
		if (remaining < readSize) {
			readSize = remaining;
		}
		if (readIntoBuffer(buffer.get(), readSize, timeout) != 0) {
			// timed out
			return remaining;
		}
		remaining -= readSize;
	}
	return remaining;
}

// Send a packet of data to the MOS
//
void VDUStreamProcessor::send_packet(uint8_t code, uint16_t len, uint8_t data[]) {
	writeByte(code + 0x80);
	writeByte(len);
	for (int i = 0; i < len; i++) {
		writeByte(data[i]);
	}
}

void VDUStreamProcessor::sendMouseData(MouseDelta * delta = nullptr) {
	auto mouse = getMouse();
	uint16_t mouseX = 0;
	uint16_t mouseY = 0;
	uint8_t buttons = 0;
	uint8_t wheelDelta = 0;
	uint16_t deltaX = 0;
	uint16_t deltaY = 0;
	if (delta) {
		deltaX = delta->deltaX;
		deltaY = delta->deltaY;
	}
	if (mouse) {
		auto mStatus = mouse->status();
		auto mousePos = toCurrentCoordinates(mStatus.X, mStatus.Y);
		mouseX = mousePos.X;
		mouseY = mousePos.Y;
		buttons = mStatus.buttons.left << 0 | mStatus.buttons.right << 1 | mStatus.buttons.middle << 2;
		wheelDelta = mStatus.wheelDelta;
	}
	debug_log("sendMouseData: %d %d %d %d %d %d %d %d %d %d\n\r", mouseX, mouseY, buttons, wheelDelta, deltaX, deltaY);
	uint8_t packet[] = {
		(uint8_t) (mouseX & 0xFF),
		(uint8_t) ((mouseX >> 8) & 0xFF),
		(uint8_t) (mouseY & 0xFF),
		(uint8_t) ((mouseY >> 8) & 0xFF),
		(uint8_t) buttons,
		(uint8_t) wheelDelta,
		(uint8_t) (deltaX & 0xFF),
		(uint8_t) ((deltaX >> 8) & 0xFF),
		(uint8_t) (deltaY & 0xFF),
		(uint8_t) ((deltaY >> 8) & 0xFF),
	};
	send_packet(PACKET_MOUSE, sizeof packet, packet);
}
// Process all available commands from the stream
//
void VDUStreamProcessor::processAllAvailable() {
	while (byteAvailable()) {
		vdu(readByte());
	}
}

// Process next command from the stream
//
void VDUStreamProcessor::processNext() {
	if (byteAvailable()) {
		vdu(readByte());
	}
}

#include "vdu.h"

#endif // VDU_STREAM_PROCESSOR_H
