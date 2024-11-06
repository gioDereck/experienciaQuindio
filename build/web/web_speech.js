let isInitialized = false;

window.speakText = function (text, lang) {
  console.log("speakText called with:", text, lang);
  if ("speechSynthesis" in window) {
    if (!isInitialized) {
      var initUtterance = new SpeechSynthesisUtterance("");
      window.speechSynthesis.speak(initUtterance);
      window.speechSynthesis.cancel();
      isInitialized = true;
      console.log("Speech synthesis initialized");
    }

    if (window.speechSynthesis.speaking) {
      window.speechSynthesis.cancel();
    }

    var utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = lang;

    utterance.onstart = function () {
      console.log("Speech started");
    };

    utterance.onend = function () {
      console.log("Speech ended");
    };

    utterance.onerror = function (event) {
      console.error("Speech synthesis error:", event.error);
    };

    window.speechSynthesis.speak(utterance);
  } else {
    console.log("Web Speech API no es soportada en este navegador.");
  }
};

window.stopSpeech = function () {
  console.log("stopSpeech called");
  if ("speechSynthesis" in window) {
    window.speechSynthesis.cancel();
  }
};
