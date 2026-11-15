// SPDX-License-Identifier: GPL-2.0-only
// Copyright (C) 2026 Jesus Palencia <sinfallas@gmail.com> (Creado en Tecno Consultores)

import * as assert from 'node:assert/strict';

interface W3cCapabilities {
  readonly platformName: 'Android' | 'iOS';
  readonly 'appium:automationName': 'UiAutomator2' | 'XCUITest';
  readonly 'appium:noReset': boolean;
}

const androidCaps: W3cCapabilities = {
  platformName: 'Android',
  'appium:automationName': 'UiAutomator2',
  'appium:noReset': false,
};

const iosCaps: W3cCapabilities = {
  platformName: 'iOS',
  'appium:automationName': 'XCUITest',
  'appium:noReset': false,
};

assert.equal(androidCaps.platformName, 'Android');
assert.equal(iosCaps['appium:automationName'], 'XCUITest');
console.log('mobile-appium-smoke-ok');
