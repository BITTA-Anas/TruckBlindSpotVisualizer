#define BTN1 10
#define BTN2 11
#define BTN3 12

#define LED1 6
#define LED2 7

int lastButton = 0;
int currentMode = 0; 
// 0 = OFF
// 1 = LED1 blink
// 2 = LED2 blink
// 3 = LED1 + LED2 blink

unsigned long lastBlinkTime = 0;
const unsigned long blinkInterval = 300;

void setup() {
  Serial.begin(9600);

  pinMode(BTN1, INPUT);
  pinMode(BTN2, INPUT);
  pinMode(BTN3, INPUT);

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
}

void loop() {

  int buttonPressed = 0;

  if (digitalRead(BTN1) == LOW)
    buttonPressed = 1;
  else if (digitalRead(BTN2) == LOW)
    buttonPressed = 2;
  else if (digitalRead(BTN3) == LOW)
    buttonPressed = 3;

  // Quand un nouveau bouton est appuyé
  if (buttonPressed != 0 && buttonPressed != lastButton) {

    Serial.println(buttonPressed);

    if (buttonPressed == 1) {
      // Mode exclusif pour BTN1
      if (currentMode == 3)
        currentMode = 0;
      else
        currentMode = 3;  // LEDs 1 + 2 blink
    }
    else if (buttonPressed == 2) {
      // Mode exclusif BTN2
      if (currentMode == 2)
        currentMode = 0;
      else
        currentMode = 2;  // LED2 blink
    }
    else if (buttonPressed == 3) {
      // Mode exclusif BTN3
      if (currentMode == 1)
        currentMode = 0;
      else
        currentMode = 1;  // LED1 blink
    }

    lastButton = buttonPressed;
  }

  // Reset bouton quand plus rien n'est appuyé
  if (buttonPressed == 0) {
    lastButton = 0;
  }

  // ---------- CLIGNOTEMENT ----------
  unsigned long currentTime = millis();

  if (currentTime - lastBlinkTime >= blinkInterval) {
    lastBlinkTime = currentTime;

    // LED1
    if (currentMode == 1 || currentMode == 3)
      digitalWrite(LED1, !digitalRead(LED1));
    else
      digitalWrite(LED1, LOW);

    // LED2
    if (currentMode == 2 || currentMode == 3)
      digitalWrite(LED2, !digitalRead(LED2));
    else
      digitalWrite(LED2, LOW);
  }

}
