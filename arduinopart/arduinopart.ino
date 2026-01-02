/************************************************************
 *  SYSTEME ADAS – SAFE OFF AU DEMARRAGE
 *  BTN1 / BTN2 : inchangés
 *  BTN3 : active / désactive TOUT
 ************************************************************/

// ================== BOUTONS ==================
const int BTN1 = 2;
const int BTN2 = 3;
const int BTN3 = 4;

// ================== ULTRASONS ==================
#define TRIG_LEFT 6
#define ECHO_LEFT 7
#define TRIG_RIGHT 8
#define ECHO_RIGHT 9

// ================== ACTIONNEURS ==================
#define BUZZER_PIN 10
#define RELAY_LEFT 11
#define RELAY_RIGHT 12

// ================== PARAMETRES ==================
const int MAX_DETECT_CM = 10;
const int CRITICAL_CM = 5;
const unsigned long US_GAP_US = 600;
const unsigned long LOOP_MS = 80;

// ================== ETATS ==================
bool lastDangerLeft = false;
bool lastDangerRight = false;

bool lastState1 = HIGH;
bool lastState2 = HIGH;
bool lastState3 = HIGH;

bool safetyMode = false;

long lastLeft = -1;
long lastRight = -1;

// =================================================
// INITIALISATION ETAT SAFE (IMPORTANT)
// =================================================
void initSafeState() {
  safetyMode = false;
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(RELAY_LEFT, LOW);
  digitalWrite(RELAY_RIGHT, LOW);
  lastLeft = -1;
  lastRight = -1;
}

// =================================================
// MESURE ULTRASON
// =================================================
long measureDistanceCm(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(3);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  unsigned long duration = pulseIn(echoPin, HIGH, 45000);
  if (duration == 0) return -1;

  long cm = duration * 0.034 / 2;
  if (cm < 2 || cm > 300) return -1;

  return cm;
}

// =================================================
// FILTRAGE
// =================================================
long smooth(long prev, long cur) {
  if (cur < 0) return prev;
  if (prev < 0) return cur;
  return (prev + cur) / 2;
}

// =================================================
// BUZZER
// =================================================
void buzzerByDistance(long dist) {
  static unsigned long lastToggle = 0;
  static bool state = false;
  unsigned long now = millis();

  if (dist < 0 || dist > MAX_DETECT_CM) {
    digitalWrite(BUZZER_PIN, LOW);
    state = false;
    lastToggle = now;
    return;
  }

  if (dist <= CRITICAL_CM) {
    digitalWrite(BUZZER_PIN, HIGH);
    state = true;
    return;
  }

  int interval;
  if (dist > 8) interval = 600;
  else if (dist > 6) interval = 300;
  else interval = 150;

  if (now - lastToggle >= (unsigned long)interval) {
    state = !state;
    digitalWrite(BUZZER_PIN, state ? HIGH : LOW);
    lastToggle = now;
  }
}

// =================================================
// CHECK BUTTON (PRINCIPE ORIGINAL)
// =================================================
void checkButton(int pin, bool &lastState, int value) {
  bool currentState = digitalRead(pin);

  if (lastState == HIGH && currentState == LOW) {

    // BTN1 / BTN2 : inchangés
    if (value == 1 || value == 2) {
      Serial.println(value);
    }

    // BTN3 : SAFE ON / OFF
    if (value == 3) {
      safetyMode = !safetyMode;
      Serial.println(3);

      if (!safetyMode) {
        initSafeState();  // 🔒 retour état sûr
      }
    }

    delay(200);  // anti-rebond
  }

  lastState = currentState;
}

// =================================================
// SETUP
// =================================================
void setup() {
  pinMode(BTN1, INPUT_PULLUP);
  pinMode(BTN2, INPUT_PULLUP);
  pinMode(BTN3, INPUT_PULLUP);

  pinMode(TRIG_LEFT, OUTPUT);
  pinMode(ECHO_LEFT, INPUT);
  pinMode(TRIG_RIGHT, OUTPUT);
  pinMode(ECHO_RIGHT, INPUT);

  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(RELAY_LEFT, OUTPUT);
  pinMode(RELAY_RIGHT, OUTPUT);

  initSafeState();

  Serial.begin(115200);
  Serial.println("SYSTEME PRET | SAFE OFF");
}

// =================================================
// LOOP
// =================================================
void loop() {

  // Boutons (inchangés)
  checkButton(BTN1, lastState1, 1);
  checkButton(BTN2, lastState2, 2);
  checkButton(BTN3, lastState3, 3);

  // SAFE OFF → rien ne tourne
  if (!safetyMode) return;

  static unsigned long lastLoop = 0;
  if (millis() - lastLoop < LOOP_MS) return;
  lastLoop = millis();

  long rawLeft = measureDistanceCm(TRIG_LEFT, ECHO_LEFT);
  delayMicroseconds(US_GAP_US);
  long rawRight = measureDistanceCm(TRIG_RIGHT, ECHO_RIGHT);

  lastLeft = smooth(lastLeft, rawLeft);
  lastRight = smooth(lastRight, rawRight);

  bool dangerLeft = (lastLeft > 0 && lastLeft <= MAX_DETECT_CM);
  bool dangerRight = (lastRight > 0 && lastRight <= MAX_DETECT_CM);

  digitalWrite(RELAY_LEFT, dangerLeft ? HIGH : LOW);
  digitalWrite(RELAY_RIGHT, dangerRight ? HIGH : LOW);

  // ===== NOTIFICATION QT (changement d'état) =====
  if (dangerLeft != lastDangerLeft) {
    Serial.println(dangerLeft ? "DANGER LEFT" : "CLEAR LEFT");
    lastDangerLeft = dangerLeft;
  }

  if (dangerRight != lastDangerRight) {
    Serial.println(dangerRight ? "DANGER RIGHT" : "CLEAR RIGHT");
    lastDangerRight = dangerRight;
  }

  long minDist = -1;
  if (dangerLeft && dangerRight) minDist = min(lastLeft, lastRight);
  else if (dangerLeft) minDist = lastLeft;
  else if (dangerRight) minDist = lastRight;

  buzzerByDistance(minDist);

  // ----- DEBUG DISTANCES -----
  Serial.print("L=");
  Serial.print(lastLeft);
  Serial.print("cm  R=");
  Serial.print(lastRight);
  Serial.print("cm  | ");

  if (minDist < 0)
    Serial.println("SAFE");
  else
    Serial.println(minDist);
}
