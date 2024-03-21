#ifndef AGON_PS2_H
#define AGON_PS2_H

#include <vector>

#include <fabgl.h>

#include "agon.h"

fabgl::PS2Controller		_PS2Controller;		// The keyboard class

uint8_t			_keycode = 0;					// Last pressed key code
uint8_t			_modifiers = 0;					// Last pressed key modifiers
uint16_t		kbRepeatDelay = 500;			// Keyboard repeat delay ms (250, 500, 750 or 1000)		
uint16_t		kbRepeatRate = 100;				// Keyboard repeat rate ms (between 33 and 500)

bool			mouseEnabled = false;			// Mouse enabled
uint8_t			mSampleRate = MOUSE_DEFAULT_SAMPLERATE;	// Mouse sample rate
uint8_t			mResolution = MOUSE_DEFAULT_RESOLUTION;	// Mouse resolution
uint8_t			mScaling = MOUSE_DEFAULT_SCALING;	// Mouse scaling
uint16_t		mAcceleration = MOUSE_DEFAULT_ACCELERATION;	// Mouse acceleration
uint32_t		mWheelAcc = MOUSE_DEFAULT_WHEELACC;	// Mouse wheel acceleration

// Forward declarations
//
bool zdi_mode ();
void zdi_enter ();
void zdi_process_cmd (uint8_t key);

// Get keyboard instance
//
inline fabgl::Keyboard* getKeyboard() {
	return _PS2Controller.keyboard();
}

// Get mouse instance
//
inline fabgl::Mouse* getMouse() {
	return _PS2Controller.mouse();
}

// Keyboard and mouse setup
//
void setupKeyboardAndMouse() {
	_PS2Controller.begin();
	auto kb = getKeyboard();
	kb->setLayout(&fabgl::UKLayout);
	kb->setCodePage(fabgl::CodePages::get(1252));
	kb->setTypematicRateAndDelay(kbRepeatRate, kbRepeatDelay);
}

// Set keyboard layout
//
void setKeyboardLayout(uint8_t region) {
	auto kb = getKeyboard();
	switch(region) {
		case 1:	kb->setLayout(&fabgl::USLayout); break;
		case 2:	kb->setLayout(&fabgl::GermanLayout); break;
		case 3:	kb->setLayout(&fabgl::ItalianLayout); break;
		case 4:	kb->setLayout(&fabgl::SpanishLayout); break;
		case 5:	kb->setLayout(&fabgl::FrenchLayout); break;
		case 6:	kb->setLayout(&fabgl::BelgianLayout); break;
		case 7:	kb->setLayout(&fabgl::NorwegianLayout); break;
		case 8:	kb->setLayout(&fabgl::JapaneseLayout);break;
		default:
			kb->setLayout(&fabgl::UKLayout);
			break;
	}
}

// Get keyboard key presses
// returns true only if there's a new keypress update
//
bool getKeyboardKey(uint8_t *keycode, uint8_t *modifiers, uint8_t *vk, uint8_t *down) {
	auto kb = getKeyboard();
	fabgl::VirtualKeyItem item;

	if(consoleMode) {
		if (DBGSerial.available()) {
			_keycode = DBGSerial.read();			
			if(!zdi_mode()) {
				if(_keycode == 0x1A) {
					zdi_enter();
					return false;
				}
			}
			else {
				zdi_process_cmd(_keycode);
				return false;

			}
			*keycode = _keycode;
			*modifiers = 0;
			*vk = 0;
			*down = 1;
			return true;			
		}
	}
	
	if (kb->getNextVirtualKey(&item, 0)) {
		if (item.down) {
			switch (item.vk) {
				case fabgl::VK_LEFT:
					_keycode = 0x08;
					break;
				case fabgl::VK_TAB:
					_keycode = 0x09;
					break;
				case fabgl::VK_RIGHT:
					_keycode = 0x15;
					break;
				case fabgl::VK_DOWN:
					_keycode = 0x0A;
					break;
				case fabgl::VK_UP:
					_keycode = 0x0B;
					break;
				case fabgl::VK_BACKSPACE:
					_keycode = 0x7F;
					break;
				default:
					_keycode = item.ASCII;	
					break;
			}
			// Pack the modifiers into a byte
			//
			_modifiers = 
				item.CTRL		<< 0 |
				item.SHIFT		<< 1 |
				item.LALT		<< 2 |
				item.RALT		<< 3 |
				item.CAPSLOCK	<< 4 |
				item.NUMLOCK	<< 5 |
				item.SCROLLLOCK << 6 |
				item.GUI		<< 7
			;
		}
		*keycode = _keycode;
		*modifiers = _modifiers;
		*vk = item.vk;
		*down = item.down;

		return true;
	}

	return false;
}

// Simpler keyboard read for CP/M Terminal Mode
//
bool getKeyboardKey(uint8_t *ascii) {
	auto kb = getKeyboard();
	fabgl::VirtualKeyItem item;

	// Read the keyboard and transmit to the Z80
	//
	if (kb->getNextVirtualKey(&item, 0)) {
		if (item.down) {
			*ascii = item.ASCII;
			return true;
		}
	}

	return false;
}

// Wait for shift key to be released, then pressed (used for paged mode)
// 
bool wait_shiftkey(uint8_t *ascii, uint8_t* vk, uint8_t* down) {
	auto kb = getKeyboard();
	fabgl::VirtualKeyItem item;

	// Wait for shift to be released
	//
	do {
		kb->getNextVirtualKey(&item, 0);
	} while (item.SHIFT);

	// And pressed again
	//
	do {
		kb->getNextVirtualKey(&item, 0);
		*ascii = item.ASCII;
		*vk = item.vk;
		*down = item.down;
		if (item.ASCII == 27) {	// Check for ESC
			return false;
		}
	} while (!item.SHIFT);

	return true;
}

void getKeyboardState(uint16_t *repeatDelay, uint16_t *repeatRate, uint8_t *ledState) {
	bool numLock;
	bool capsLock;
	bool scrollLock;
	getKeyboard()->getLEDs(&numLock, &capsLock, &scrollLock);
	*ledState = scrollLock | (capsLock << 1) | (numLock << 2);
    *repeatDelay = kbRepeatDelay;
    *repeatRate = kbRepeatRate;
}

void setKeyboardState(uint16_t delay, uint16_t rate, uint8_t ledState) {
	auto kb = getKeyboard();
	if (delay >= 250 && delay <= 1000) kbRepeatDelay = (delay / 250) * 250;	// In steps of 250ms
	if (rate >=  33 && rate <=  500) kbRepeatRate  = rate;
	if (ledState != 255) {
		kb->setLEDs(ledState & 4, ledState & 2, ledState & 1);
	}
    kb->setTypematicRateAndDelay(kbRepeatRate, kbRepeatDelay);
}

bool updateMouseEnabled() {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	mouseEnabled = mouse->isMouseAvailable();
	return mouseEnabled;
}

bool enableMouse() {
	if (mouseEnabled) {
		return true;
	}
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	mouse->resumePort();
	return updateMouseEnabled();
}

bool disableMouse() {
	if (!mouseEnabled) {
		return true;
	}
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	mouse->suspendPort();
	mouseEnabled = false;
	return true;
}

bool setMouseSampleRate(uint8_t rate) {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	// sampleRate: valid values are 10, 20, 40, 60, 80, 100, and 200 (samples/sec)
	if (rate == 0) rate = MOUSE_DEFAULT_SAMPLERATE;
	auto rates = std::vector<uint16_t>{ 10, 20, 40, 60, 80, 100, 200 };
	if (std::find(rates.begin(), rates.end(), rate) == rates.end()) {
		debug_log("vdu_sys_mouse: invalid sample rate %d\n\r", rate);
		return false;
	}

	if (mouse->setSampleRate(rate)) {
		mSampleRate = rate;
		return true;
	}
	return false;
}

bool setMouseResolution(int8_t resolution) {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	if (resolution == -1) resolution = MOUSE_DEFAULT_RESOLUTION;
	if (resolution > 3) {
		debug_log("setMouseResolution: invalid resolution %d\n\r", resolution);
		return false;
	}

	if (mouse->setResolution(resolution)) {
		mResolution = resolution;
		return true;
	}
	return false;
}

bool setMouseScaling(uint8_t scaling) {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	if (scaling == 0) scaling = MOUSE_DEFAULT_SCALING;
	if (scaling > 2) {
		debug_log("setMouseScaling: invalid scaling %d\n\r", scaling);
		return false;
	}

	if (mouse->setScaling(scaling)) {
		mScaling = scaling;
		return true;
	}
	return false;
}

bool setMouseAcceleration(uint16_t acceleration) {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	if (acceleration == 0) acceleration = MOUSE_DEFAULT_ACCELERATION;

	// get current acceleration
	auto & currentAcceleration = mouse->movementAcceleration();

	// change the acceleration
	currentAcceleration = acceleration;

	return false;
}

bool setMouseWheelAcceleration(uint32_t acceleration) {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	if (acceleration == 0) acceleration = MOUSE_DEFAULT_WHEELACC;

	// get current acceleration
	auto & currentAcceleration = mouse->wheelAcceleration();

	// change the acceleration
	currentAcceleration = acceleration;

	return false;
}

bool resetMousePositioner(uint16_t width, uint16_t height, fabgl::VGABaseController * display) {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	// setup and then terminate absolute positioner
	// this will set width/height of mouse area for updateAbsolutePosition calls
	mouse->setupAbsolutePositioner(width, height, true, display);
	mouse->terminateAbsolutePositioner();
	return true;
}

bool setMousePos(uint16_t x, uint16_t y) {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	auto & status = mouse->status();
	status.X = x;
	status.Y = y;
	return true;
}

bool resetMouse() {
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	// reset parameters for mouse
	// set default sample rate, resolution, scaling, acceleration, wheel acceleration
	setMouseSampleRate(0);
	setMouseResolution(-1);
	setMouseScaling(0);
	setMouseAcceleration(0);
	setMouseWheelAcceleration(0);
	return mouse->reset();
}

bool mouseMoved(MouseDelta * delta) {
	if (!mouseEnabled) {
		return false;
	}
	auto mouse = getMouse();
	if (!mouse) {
		return false;
	}
	if (mouse->deltaAvailable()) {
		mouse->getNextDelta(delta, -1);
		mouse->updateAbsolutePosition(delta);
		return true;
	}
	return false;
}

#endif // AGON_PS2_H
