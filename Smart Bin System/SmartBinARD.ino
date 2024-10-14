#include <Servo.h>
#include <SPI.h>
#include <MFRC522.h>

// RFID Pins
#define SS_PIN 10
#define RST_PIN 9

// Ultrasonic pins
#define ECHO_PIN 6
#define TRIG_PIN 7

String UID = "00 30 FF E9"; // RFID key
byte lock = 0;

Servo servo; // Servo motor

MFRC522 rfid(SS_PIN, RST_PIN);

void setup() {
  Serial.begin(9600);
  servo.write(70);
  servo.attach(5);
  SPI.begin();
  rfid.PCD_Init();

  pinMode(TRIG_PIN, OUTPUT);
  digitalWrite(TRIG_PIN, LOW);
  pinMode(ECHO_PIN, INPUT);
}

// Define a new function that reads and converts the raw reading to distance (cm)
float distance_centimetre() {
  long duration, distance;

  // Send sound pulse
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Listen for echo
  duration = pulseIn(ECHO_PIN, HIGH, 30000); // Timeout after 30ms
  if (duration == 0) {
    // Timeout occurred, consider this as no reading
    return -1.0;
  }
  
  distance = duration / 58.2; // Convert duration to distance in cm

  return distance;
}

void loop() {
  float distance = distance_centimetre();
  // Monitor fill level
  if (distance >= 0) {
    Serial.print("Current Wastelevel: ");
    Serial.print(distance, 2);
    Serial.println(" cm");
  } else {
    Serial.println("No reading from the sensor.");
  }
  
  delay(2000);

  // Lock bin
  if (distance > 0 && distance <= 7 && lock == 0) {
    servo.write(70);
    delay(2000);
    lock = 1;
  }

  // Read RFID card
  if (!rfid.PICC_IsNewCardPresent()) return;
  if (!rfid.PICC_ReadCardSerial()) return;

  Serial.println("NUID tag is :" + UID);
  String ID = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    ID.concat(String(rfid.uid.uidByte[i] < 0x10 ? " 0" : " "));
    ID.concat(String(rfid.uid.uidByte[i], HEX));
    delay(300);
  }
  ID.toUpperCase();

  // Unlock bin
  if (ID.substring(1) == UID && lock == 1) {
    servo.write(160);
    delay(1500);
    lock = 0;
  } else {
    delay(1500);
  }
}
