#include <Arduino_FreeRTOS.h>
#include <semphr.h>

// Capteur gauche
#define TRIG_G 9
#define ECHO_G 10

// Capteur droit
#define TRIG_D 11
#define ECHO_D 12

SemaphoreHandle_t serialMutex;

// Prototype
int mesureDistance(int trigPin, int echoPin);

// ---------- TASK CAPTEUR GAUCHE ----------
void TaskCapteurGauche(void *pvParameters) {
  (void) pvParameters;

  for (;;) {
    int distance = mesureDistance(TRIG_G, ECHO_G);

    if (xSemaphoreTake(serialMutex, portMAX_DELAY)) {
      Serial.print("Gauche : ");
      Serial.print(distance);
      Serial.println(" cm");
      xSemaphoreGive(serialMutex);
    }

    vTaskDelay(pdMS_TO_TICKS(200));
  }
}

// ---------- TASK CAPTEUR DROIT ----------
void TaskCapteurDroit(void *pvParameters) {
  (void) pvParameters;

  for (;;) {
    int distance = mesureDistance(TRIG_D, ECHO_D);

    if (xSemaphoreTake(serialMutex, portMAX_DELAY)) {
      Serial.print("Droite : ");
      Serial.print(distance);
      Serial.println(" cm");
      xSemaphoreGive(serialMutex);
    }

    vTaskDelay(pdMS_TO_TICKS(200));
  }
}

// ---------- SETUP ----------
void setup() {
  pinMode(TRIG_G, OUTPUT);
  pinMode(ECHO_G, INPUT);
  pinMode(TRIG_D, OUTPUT);
  pinMode(ECHO_D, INPUT);

  Serial.begin(9600);

  serialMutex = xSemaphoreCreateMutex();

  xTaskCreate(
    TaskCapteurGauche,
    "CapteurGauche",
    128,
    NULL,
    1,
    NULL
  );

  xTaskCreate(
    TaskCapteurDroit,
    "CapteurDroit",
    128,
    NULL,
    1,
    NULL
  );
}

// ---------- LOOP (inutilisé avec FreeRTOS) ----------
void loop() {
}

// ---------- FONCTION MESURE ----------
int mesureDistance(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 30000);
  int distance = duration * 0.034 / 2;

  if (distance <= 0 || distance > 400) distance = 400;
  return distance;
}
