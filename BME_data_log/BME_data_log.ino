#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>

Adafruit_BME280 bme; // I2C

void setup() {
  Serial.begin(9600);
  while(!Serial);    // Attende l'apertura della seriale

  // Rimuoviamo ogni filtro software o oversampling per vedere la risposta grezza
  bme.setSampling(Adafruit_BME280::MODE_NORMAL,
                  Adafruit_BME280::SAMPLING_X2, // Temperatura: campionamento X2
                  Adafruit_BME280::SAMPLING_X16, // Pressione: campionamento X16
                  Adafruit_BME280::SAMPLING_X1, // Umidità: campionamento singolo
                  Adafruit_BME280::FILTER_OFF,  //  FILTRO IIR SPENTO (Nessun ritardo)
                  Adafruit_BME280::STANDBY_MS_500); // Standby minimo tra letture
  
  Serial.println("Sensore configurato.");
}

void loop() {
  // Lettura diretta
  float temp = bme.readTemperature();
  float pres = bme.readPressure();
  float hum = bme.readHumidity();

  Serial.print(millis());
  Serial.print(" ,    ");
  Serial.print(temp + 273.15, 2);
  Serial.print(" K ,    ");
  Serial.print(hum, 1);
  Serial.print(" % ,    ");
  Serial.print(pres / 1000.0F, 3); // Pascal -> kPa
  Serial.println(" kPa");

  delay(1000);
}