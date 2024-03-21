#ifndef AUDIO_SAMPLE_H
#define AUDIO_SAMPLE_H

#include <memory>
#include <unordered_map>

#include "types.h"
#include "audio_channel.h"
#include "buffer_stream.h"

struct audio_sample {
	audio_sample(std::vector<std::shared_ptr<BufferStream>>& streams, uint8_t format) : blocks(streams), format(format), index(0), blockIndex(0) {}
	~audio_sample();
	int8_t getSample();
	void rewind() {
		index = 0;
		blockIndex = 0;
	}
	void checkIndexes() {
		if (blockIndex >= blocks.size()) {
			blockIndex = 0;
			index = 0;
		}
		if (index >= blocks[blockIndex]->size()) {
			index = 0;
		}
	}
	uint32_t getDuration() {
		uint32_t duration = 0;
		for (auto block : blocks) {
			duration += block->size();
		}
		return duration / 16;
	}
	std::vector<std::shared_ptr<BufferStream>>& blocks;
	uint8_t			format;			// Format of the sample data
	uint32_t		index;			// Current index inside the current sample block
	uint32_t		blockIndex;		// Current index into the sample data blocks
	std::unordered_map<uint8_t, std::weak_ptr<audio_channel>> channels;	// Channels playing this sample
};

audio_sample::~audio_sample() {
	// iterate over channels
	for (auto channelPair : this->channels) {
		auto channelRef = channelPair.second;
		if (!channelRef.expired()) {
			auto channel = channelRef.lock();
			debug_log("audio_sample: removing sample from channel %d\n\r", channel->channel());
			// Remove sample from channel
			channel->setWaveform(AUDIO_WAVE_DEFAULT, nullptr);
		}
	}
	debug_log("audio_sample cleared\n\r");
}

int8_t audio_sample::getSample() {
	// our blocks might have changed, so we need to check if we're still in range
	checkIndexes();

	auto block = blocks[blockIndex];
	int8_t sample = block->getBuffer()[index++];
	
	// Insert looping magic here
	if (index >= block->size()) {
		// block reached end, move to next, or loop
		index = 0;
		blockIndex++;
	}

	if (format == AUDIO_FORMAT_8BIT_UNSIGNED) {
		sample = sample - 128;
	}

	return sample;
}

#endif // AUDIO_SAMPLE_H
