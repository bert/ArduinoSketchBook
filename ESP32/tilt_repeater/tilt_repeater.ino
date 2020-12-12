// ESP32 Tilt Repeater
// By David Gray

#include "BLEDevice.h"
#include "BLEBeacon.h"
#include "esp_deep_sleep.h"

// User Settings
int SCAN_TIME = 5;              // Duration to scan for bluetooth devices (in seconds).
int TIME_TO_SLEEP = 60;         // Duration ESP32 will go to sleep between scans (in seconds).
int fastSleep = 4;              // Scan more often if no Tilts are found. TIME_TO_SLEEP(60) / fastSleep(4) = scan every 15 seconds. Use 0 to disable.
int repeatColour = 0;           // Choose Tilt colour to repeat. 0=All, 1=Red, 2=Green, 3=Black, 4=Purple, 5=Orange, 6=Blue, 7=Yellow, 8=Pink.
bool Celsius = true;            // Use Celcius while logging to serial.

int uS_TO_S_FACTOR = 1000000;
BLEAdvertising *pAdvertising;
BLEScan* pBLEScan;

void setBeacon(String TiltUUID, float TiltMajor, int TiltMinor) {
  BLEBeacon oBeacon = BLEBeacon();
  oBeacon.setManufacturerId(0x4C00); // fake Apple 0x004C LSB (ENDIAN_CHANGE_U16!)
  BLEUUID bleUUID = BLEUUID(TiltUUID.c_str());
  bleUUID = bleUUID.to128();
  oBeacon.setProximityUUID(BLEUUID( bleUUID.getNative()->uuid.uuid128, 16, true ));

  oBeacon.setMajor(TiltMajor); // Temp in Freedumb units
  oBeacon.setMinor(TiltMinor); // Gravity * 1000
  BLEAdvertisementData oAdvertisementData = BLEAdvertisementData();
  BLEAdvertisementData oScanResponseData = BLEAdvertisementData();
  
  oAdvertisementData.setFlags(0x04); // BR_EDR_NOT_SUPPORTED 0x04
  
  std::string strServiceData = "";
  
  strServiceData += (char)26;     // Len
  strServiceData += (char)0xFF;   // Type
  strServiceData += oBeacon.getData();
  oAdvertisementData.addData(strServiceData);
  
  pAdvertising->setAdvertisementData(oAdvertisementData);
  pAdvertising->setScanResponseData(oScanResponseData);
}

int parseTilt(String DevData) {
  String DevUUID, DevColour, DevTempData, DevGravityData;
  int colourInt;
  float DevTemp, DevGravity;

  // Determine the Colour
  colourInt = DevData.substring(6, 7).toInt();

  switch (colourInt) {
    case 1:
      DevColour = "Red";
      break;
    case 2:
      DevColour = "Green";
      break;
    case 3:
      DevColour = "Black";
      break;
    case 4:
      DevColour = "Purple";
      break;
    case 5:
      DevColour = "Orange";
      break;
    case 6:
      DevColour = "Blue";
      break;
    case 7:
      DevColour = "Yellow";
      break;
    case 8:
      DevColour = "Pink";
      break;
  }

  if (repeatColour != 0 && repeatColour != colourInt) {
    Serial.print(DevColour);
    Serial.println(" Tilt is being ignored.");
    return 0;
  }

  //Generate the UUID
  DevUUID += DevData.substring(0, 8);
  DevUUID += "-";
  DevUUID += DevData.substring(8, 12);
  DevUUID += "-";
  DevUUID += DevData.substring(12, 16);
  DevUUID += "-";
  DevUUID += DevData.substring(16, 20);
  DevUUID += "-";
  DevUUID += DevData.substring(20, 32);

  // Get the temperature
  DevTempData = DevData.substring(32, 36);
  DevTemp = strtol(DevTempData.c_str(), NULL, 16); // Temp in Freedumb units

  // Get the gravity
  DevGravityData = DevData.substring(36, 40);
  DevGravity = strtol(DevGravityData.c_str() , NULL, 16);

  Serial.println("--------------------------------");
  Serial.print("Colour: ");
  Serial.println(DevColour);
  Serial.print("Temp: ");
  if (Celsius) {
     Serial.print((DevTemp-32.0) * (5.0/9.0));
     Serial.println(" C");
  }
  else {
    Serial.print(DevTemp);
    Serial.println(" F");
  }
  Serial.print("Gravity: ");
  float DevGravityFormatted = (DevGravity / 1000);
  Serial.println(DevGravityFormatted, 3);
  Serial.println(DevData);
  Serial.println("--------------------------------");

  BLEDevice::init("");
  //Adjust Power 3 is default, 9 is max
  esp_err_t errRc = esp_ble_tx_power_set(ESP_BLE_PWR_TYPE_DEFAULT, ESP_PWR_LVL_P9);
  esp_ble_tx_power_set(ESP_BLE_PWR_TYPE_ADV, ESP_PWR_LVL_P9);

  pAdvertising = BLEDevice::getAdvertising();
  setBeacon(DevUUID, DevTemp, DevGravity);
  pAdvertising->start();
  Serial.print("Advertizing ");
  Serial.print(DevColour);
  Serial.println(" Tilt");
  delay(100);
  pAdvertising->stop();
  BLEDevice::deinit(0);
  return 2;
}


void setup()
{
  int deviceCount, tiltCount = 0;
  int colourFound = 1;
  Serial.begin(115200);

  BLEDevice::init("");
  //Adjust Power 3 is default, 9 is max
  esp_err_t errRc = esp_ble_tx_power_set(ESP_BLE_PWR_TYPE_DEFAULT, ESP_PWR_LVL_P9);
  esp_ble_tx_power_set(ESP_BLE_PWR_TYPE_SCAN, ESP_PWR_LVL_P9);

  pBLEScan = BLEDevice::getScan();
  pBLEScan->setActiveScan(true);
  Serial.println();
  Serial.println("Scanning...");
  BLEScanResults foundDevices = pBLEScan->start(SCAN_TIME);
  deviceCount = foundDevices.getCount();
  Serial.print(deviceCount);
  Serial.println(" Devices Found.");
  pBLEScan->stop();
  BLEDevice::deinit(0);

  for (uint32_t i = 0; i < deviceCount; i++)
  {
    BLEAdvertisedDevice Device = foundDevices.getDevice(i);
    String DevString, DevData;
    DevString = Device.toString().c_str();
    DevData = DevString.substring(63);

    if (DevData.substring(7, 32) == "0c5b14b44b5121370f02d74de") { // Tilt found
      tiltCount++;
      Serial.print("Device #");
      Serial.print(i);
      Serial.println(" is a Tilt");
      int tiltSuccess = parseTilt(DevData);
      if (tiltSuccess == 2) {
        colourFound = 2;
      }
      if (!tiltSuccess && colourFound != 2) {
        colourFound = 0;
      }
    }
  }

  if (!tiltCount || !colourFound) {
    Serial.println("No Tilts Repeated.");
    esp_sleep_enable_timer_wakeup((TIME_TO_SLEEP/fastSleep) * uS_TO_S_FACTOR);
  }
  else {
    esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
  }

  esp_deep_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_OFF);
  
  Serial.print("Going to sleep for ");
  if (!tiltCount || !colourFound) {
    Serial.print(TIME_TO_SLEEP/fastSleep);
  }
  else {
    Serial.print(TIME_TO_SLEEP);
  }
  Serial.println(" seconds ");
  Serial.flush(); 

  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_SLOW_MEM, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_FAST_MEM, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_OFF);
  esp_deep_sleep_start();
}

void loop ()
{

}
