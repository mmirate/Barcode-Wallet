using Toybox.Application as App;
using Toybox.Application.Properties as Properties;
using Toybox.WatchUi as Ui;
using Toybox.System as System;

module Settings {

	var debug = false;
	var version = 1;
	var token;
	var displayLabel;
	var displayValue;
	var forceBacklight;
	var codes = null;
	var size = -1;
	var usePosition = false;
	var vibrate = true;
	var currentIndex = null;
	var currentCode = null;
	var state = :UNKNOWN; // UNKNOWN, READY, ERROR, LOADING, NO_TOKEN
	var responseCode = null;
	var zoom = false;

	function getToken() {
		return _getProperty("token");
	}

	function hasToken() {
		return !isNullOrEmpty(getToken());
	}
	
	function setCurrentIndex(index) {
		System.println("Change currentIndex to "+ Settings.currentIndex);		
		currentIndex = index;
		currentCode = _getCurrentCode();
		App.getApp().setProperty("currentIndex", index);
		state = :READY;
	}
	
	function _getCurrentCode() {
		if(0 <= currentIndex && currentIndex < codes.size()) {
			return codes[currentIndex];
		}
		return null;
	}

	function load() {
		size = _getProperty("size");
		codes = _loadCodes();
		token = _getProperty("token");
		usePosition = _getProperty("usePosition");
		vibrate = _getProperty("vibrate");
		version = _getProperty("version");
		debug = _getProperty("debug");
		displayLabel = _getProperty("displayLabel");
		displayValue = _getProperty("displayValue");
		forceBacklight = _getProperty("forceBacklight");
		currentIndex = App.getApp().getProperty("currentIndex");
		if (currentIndex == null) {
			currentIndex = 0;
		}
		validateCurrentIndex();
		currentCode = _getCurrentCode();
	}

	function _loadCodes() {
		codes = [];
		var i = 0;
		var code = _loadCode(i);
		while (code != null && (size <= 0 || i < size)) {
			codes.add(code);
			i++;
			code = _loadCode(i);
		}
		System.println(codes.size() + " codes loaded.");
		return codes;
	}
	
	function storeCodes(newCodes) {
		codes = newCodes;
		var i = 0;
		while(i<codes.size()) {
			_storeCode(codes[i]);
			i++;
		}
		while(_loadCode(i) != null) {
			_removeCode(i);
			i++;
		}
		validateCurrentIndex();
	}

	function validateCurrentIndex() {
		if (currentIndex > codes.size()-1) {
			setCurrentIndex(codes.size()-1);
		}
		if(currentIndex < 0) {
			setCurrentIndex(0);
		} else {
			System.println("Settings.currentIndex = "+ Settings.currentIndex);
		}
	}

	function _storeCode(code) {
		if (App has :Storage) {
			App.Storage.setValue(
				"code#" + code.id,
				{
					"version" => code.version,
					"label" => code.label,
					"value" => code.value,
					"width" => code.width,
					"height"=> code.height,
					"data"  => code.data,
				}
			);
		} else {
			var app = App.getApp();
			app.setProperty("code#" + code.id + "-version", code.version);
			app.setProperty("code#" + code.id + "-label", code.label);
			app.setProperty("code#" + code.id + "-value", code.value);
			app.setProperty("code#" + code.id + "-width", code.width);
			app.setProperty("code#" + code.id + "-height", code.height);
			app.setProperty("code#" + code.id + "-data", code.data);
		}
	}

	function _loadCode(id) {
		if (App has :Storage) {
			var code = App.Storage.getValue("code#" + id);
			if (code != null) {
				return new Code(id, code["version"], code["label"], code["value"], code["width"], code["height"], code["data"]);
			}
		} else {
			var app = App.getApp();
			var version = app.getProperty("code#" + id + "-version");
			var label = app.getProperty("code#" + id + "-label");
			var value = app.getProperty("code#" + id + "-value");
			var width = app.getProperty("code#" + id + "-width");
			var height= app.getProperty("code#" + id + "-height");
			var data  = app.getProperty("code#" + id + "-data");
			if (data != null) {
				return new Code(id, version, label, value, width, height, data);
			}
		}
		return null;
	}

	function _removeCode(id) {
		if (App has :Storage) {
			App.Storage.deleteValue("code#" + id);
		} else {
			var app = App.getApp();
			app.setProperty("code#" + id + "-data", null);
		}
	}

	function _setProperty(key, value) {
		if (App has :Properties) {
			Properties.setValue(key, value);
		} else {
			var app = App.getApp();
			app.setProperty(key, value);
		}
	}

	function _getProperty(key) {
		if (App has :Properties) {
			return App.Properties.getValue(key);
		} else {
			var app = App.getApp();
			return app.getProperty(key);
		}
	}
}