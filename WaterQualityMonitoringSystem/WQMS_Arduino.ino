#include <WaziDev.h>
#include <xlpp.h>
#include <Base64.h>


#define LPP_GENERIC_SENSOR 100


// Copy'n'paste the DevAddr (Device Address): 26011D00
unsigned char devAddr[4] = {0x67, 0x01, 0x1D, 0x00};

// Copy'n'paste the key to your Wazigate: 23158D3BBC31E6AF670D195B5AED5525
unsigned char appSkey[16] = {0x99, 0x15, 0x8D, 0x3B, 0xBC, 0x31, 0xE6, 0xAF, 0x67, 0x0D, 0x19, 0x5B, 0x5A, 0xED, 0x55, 0x25};

// Copy'n'paste the key to your Wazigate: 23158D3BBC31E6AF670D195B5AED5525
unsigned char nwkSkey[16] = {0x99, 0x15, 0x8D, 0x3B, 0xBC, 0x31, 0xE6, 0xAF, 0x67, 0x0D, 0x19, 0x5B, 0x5A, 0xED, 0x55, 0x25};

WaziDev wazidev;

// Calibration factor for the TDS sensor
const float calibrationFactor = 0.5;

float calibration_value = 21.34 - 13.7;
float pH_Value = 0;
unsigned long int avgVal;

float pH_Act;

void setup() {
  Serial.begin(38400);
  wazidev.setupLoRaWAN(devAddr, appSkey, nwkSkey);
  pinMode(pH_Value, INPUT);
}

XLPP xlpp(120);

uint8_t uplink()
{
  uint8_t e;

  // 1.
  // Read sensor values.
  int TurbidityValue = analogRead(A1);// read the input on analog pin A1
  pH_Value = analogRead(A0);  // read the input on analog pin A1
  int analogValue = analogRead(A2); //read analog vale from TDS sensor

  //Sensor Caliberation

  //Turbidity
  float turbidity = map(TurbidityValue, 740, 0, 101, 0);
  turbidity /= 10.0;

  //pH
  float Voltage = 5.0 / 1024 / 6;
  pH_Act = -5.70 * Voltage + calibration_value;

  // TDS
  float voltage = analogValue * (5.0 / 1023.0);
  float tdsVal = (voltage * calibrationFactor) * 1000;

  float getGenericSensor(turbidity, pH_Act, tdsVal);

  // 2.
  // Create xlpp payload for uplink.
  xlpp.reset();
  xlpp.addRelativeHumidity(0, turbidity); // NTU
  xlpp.addTemperature(1, pH_Act); // pH
  xlpp.addRelativeHumidity(2, tdsVal); // ppm

  // 3.
  // Send payload uplink with LoRaWAN.
  serialPrintf("LoRaWAN send ... ");
  e = wazidev.sendLoRaWAN(xlpp.buf, xlpp.len);
  if (e != 0)
  {
    serialPrintf("Err %d\n", e);
    return e;
  }
  serialPrintf("OK\n");
  return 0;
}

uint8_t downlink(uint16_t timeout)
{
  uint8_t e;

  // 1.
  // Receive LoRaWAN downlink message.
  serialPrintf("LoRa receive ... ");
  uint8_t offs = 0;
  long startSend = millis();
  e = wazidev.receiveLoRaWAN(xlpp.buf, &xlpp.offset, &xlpp.len, timeout);
  long endSend = millis();
  if (e)
  {
    if (e == ERR_LORA_TIMEOUT)
      serialPrintf("nothing received\n");
    else 
      serialPrintf("Err %d\n", e);
    return e;
  }
  serialPrintf("OK\n");
  
  serialPrintf("Time On Air: %d ms\n", endSend-startSend);
  serialPrintf("LoRa SNR: %d\n", wazidev.loRaSNR);
  serialPrintf("LoRa RSSI: %d\n", wazidev.loRaRSSI);
  serialPrintf("LoRaWAN frame size: %d\n", xlpp.offset+xlpp.len);
  serialPrintf("LoRaWAN payload len: %d\n", xlpp.len);
  serialPrintf("Payload: ");
  if (xlpp.len == 0)
  {
    serialPrintf("(no payload received)\n");
    return 1;
  }
  printBase64(xlpp.getBuffer(), xlpp.len);
  serialPrintf("\n");

  // 2.
  // Read xlpp payload from downlink message.
  // You must use the following pattern to properly parse xlpp payload!
  int end = xlpp.len + xlpp.offset;
  while (xlpp.offset < end)
  {
    // [1] Always read the channel first ...
    uint8_t chan = xlpp.getChannel();
    serialPrintf("Chan %2d: ", chan);

    // [2] ... then the type ...
    uint8_t type = xlpp.getType();
  }
}


void loop() {

  // Read sensor values.
  int TurbidityValue = analogRead(A1);// read the input on analog pin A1
  pH_Act = analogRead(A0);  // read the input on analog pin A0
  int analogValue = analogRead(A2); //read input on analog pin A2

  //Sensor Caliberation

  //Turbidity
  float turbidity = map(TurbidityValue, 740, 0, 101, 0);
  turbidity /= 10.0;

  //pH
  float Voltage = avgVal * 5.0 / 1024 / 6;
  pH_Act = -5.70 * Voltage + calibration_value;

  // TDS
   float voltage = analogValue * (5.0 / 1023.0);
   float tdsVal = (voltage * calibrationFactor) * 1000;

  //Turbidity
  Serial.print("Turbidity: ");
  Serial.println(turbidity); // NTU

  if (turbidity < 6) {
    Serial.println("COMMENT: Water is clear. Safe to drink");
  }
  if ((turbidity > 5) && (turbidity < 8)){
    Serial.println("COMMENT: Water is cloudy. Wait for water to clear.");
  }
  if (turbidity > 8){
    Serial.println("COMMENT: Water is dirty. May require filtering.");
  }

  //PH SENSOR
  Serial.print("pH: ");
  Serial.println(pH_Act);//pH

  if((pH_Act >= 6.5) && (pH_Act <= 8.5)){
    Serial.println("COMMENT: water PH level is neutral. Safe to drink");
  }

  if((pH_Act >= 1) && (pH_Act <= 6.4)){
    Serial.println("COMMENT: water PH level is acidic. Be careful!!");
  }

  if((pH_Act >= 8.6) && (pH_Act <= 14)){ 
    Serial.println("COMMENT: water PH level is Alkaline. Totally  not safe to drink");
  }
  
  // TDS sensor
  Serial.print("TDS Value from solution is: ");
  Serial.print(tdsVal);
  Serial.println(" ppm");

  //conditional statements
  if (tdsVal <= 5) {
    Serial.println("COMMENT: Please place the sensor in water to get a reading \n");
  } else if (tdsVal <= 150) {
    Serial.println("COMMENT: Water is safe to drink. 'Good bottled water' \n");
  } else if (tdsVal <= 300) {
    Serial.println("COMMENT: Fair and still drinkable \n");
  } else if (tdsVal <= 530) {
    Serial.println("COMMENT: Questionable and might contain some unseen dissolved substances \n");
  } else {
    Serial.println("COMMENT: DO NOT DRINK THIS WATER \n");
  }


delay(2000);

  // error indicator
  uint8_t e;

  // 1. LoRaWAN Uplink
  e = uplink();
  // if no error...
  if (!e) {
    // 2. LoRaWAN Downlink
    // waiting for 6 seconds only!
    downlink(6000);
  }

  serialPrintf("Waiting 1min ...\n");
  delay(6000);
  Serial.println();


}
