#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ================= LCD =================
LiquidCrystal_I2C lcd(0x27, 16, 2);

// ================= WiFi =================
#define WIFI_SSID     "BMWM3"
#define WIFI_PASSWORD "@BMWM3@@##"

// ================= Firebase =================
#define API_KEY      "AIzaSyCUyqXV-nxWO-KXLHrsdGhW-gl5GVMk04E"
#define DATABASE_URL "https://iot-parking-app-default-rtdb.europe-west1.firebasedatabase.app/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;

// ================= SERVO SETTINGS =================
#define SERVO_FREQ 50
#define SERVO_RES  16
#define SERVO_CLOSE 1638   // 90 درجة
#define SERVO_OPEN  4915   // 90 درجة

// ================= Servo Pins =================
#define SERVO_IN   18
#define SERVO_OUT  19

// ================= Parking Sensors =================
#define IR1 32
#define IR2 33
#define IR3 25
#define IR4 26
#define IR5 27
#define IR6 14
#define IR7 16
#define IR8 17

int irPins[8] = {IR1, IR2, IR3, IR4, IR5, IR6, IR7, IR8};
bool lastSlotState[8];

// ================= Gate Sensors =================
#define IR_GATE_IN   34
#define IR_GATE_OUT  35

// ================= Variables =================
int freeSlots = 8;
int occupiedSlots = 0;

bool lastGateInState  = HIGH;
bool lastGateOutState = HIGH;

// ================= XOR =================
#define XOR_KEY 123
int protect(int value) { return value ^ XOR_KEY; }

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("BOOT OK");

  // ================= WiFi =================
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\nWiFi Connected");
  Serial.println(WiFi.localIP());

  // ================= Firebase =================
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase SignUp OK");
    signupOK = true;
  } else {
    Serial.println(config.signer.signupError.message.c_str());
  }

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // ================= I2C =================
  Wire.begin(21, 22);

  // ================= Parking Sensors =================
  for (int i = 0; i < 8; i++) {
    pinMode(irPins[i], INPUT_PULLUP);
    lastSlotState[i] = digitalRead(irPins[i]); // قراءة أولية
  }

  // ================= Gate Sensors =================
  pinMode(IR_GATE_IN, INPUT);
  pinMode(IR_GATE_OUT, INPUT);

  // ================= LCD =================
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("IOT Parking");

  // ================= Servo PWM =================
  ledcAttach(SERVO_IN,  SERVO_FREQ, SERVO_RES);
  ledcAttach(SERVO_OUT, SERVO_FREQ, SERVO_RES);
  ledcWrite(SERVO_IN, SERVO_CLOSE);
  ledcWrite(SERVO_OUT, SERVO_CLOSE);

  Serial.println("Setup Complete");
}

void loop() {

  // ================= Count Free Slots =================
  freeSlots = 0;
  for (int i = 0; i < 8; i++) {
    if (digitalRead(irPins[i]) == HIGH) freeSlots++;
  }
  occupiedSlots = 8 - freeSlots;

  // ================= Firebase Update (Slots ONLY) =================
  if (Firebase.ready() && signupOK) {
    for (int i = 0; i < 8; i++) {

      bool currentState = digitalRead(irPins[i]);

      if (currentState != lastSlotState[i]) {

        bool isAvailable = (currentState == HIGH);
        String path = "/parking_slots/slot_0" + String(i + 1) + "/isAvailable";

        // تشفير XOR قبل الإرسال
        int encryptedVal = protect(isAvailable ? 1 : 0);

        if (Firebase.RTDB.setInt(&fbdo, path.c_str(), encryptedVal)) {
          Serial.print("Slot ");
          Serial.print(i + 1);
          Serial.println(isAvailable ? " FREE" : " OCCUPIED");
        } else {
          Serial.print("Firebase Error: ");
          Serial.println(fbdo.errorReason());
        }

        lastSlotState[i] = currentState;
        delay(120); // خفيف
      }
    }
  }

  // ================= Gate Logic (LOCAL فقط) =================
  bool gateInState  = digitalRead(IR_GATE_IN);
  bool gateOutState = digitalRead(IR_GATE_OUT);

  if (lastGateInState == HIGH && gateInState == LOW && freeSlots > 0) {
    ledcWrite(SERVO_IN, SERVO_OPEN);
    delay(3000);
    ledcWrite(SERVO_IN, SERVO_CLOSE);
  }

  if (lastGateOutState == HIGH && gateOutState == LOW) {
    ledcWrite(SERVO_OUT, SERVO_OPEN);
    delay(3000);
    ledcWrite(SERVO_OUT, SERVO_CLOSE);
  }

  lastGateInState  = gateInState;
  lastGateOutState = gateOutState;

  // ================= LCD =================
  lcd.setCursor(0, 0);
  lcd.print("Available: ");
  lcd.print(freeSlots);
  lcd.print("  ");

  lcd.setCursor(0, 1);
  lcd.print("Occupied : ");
  lcd.print(occupiedSlots);
  lcd.print("  ");

  delay(200);
}
