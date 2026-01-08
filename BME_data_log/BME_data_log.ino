#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>

/*
 * CONFIGURAZIONE HARDWARE
 * Se non funziona, prova a cambiare l'indirizzo I2C da 0x76 a 0x77 nella bme.begin()
 */

Adafruit_BME280 bme; // I2C

void setup() {
  Serial.begin(9600);
  while(!Serial);    // Attendi l'apertura della seriale

  Serial.println(F("BME280 Test Alta Velocità"));

  // Tenta indirizzo 0x76 (comune sensori cinesi). Se fallisce prova 0x77.
  if (!bme.begin(0x76)) {  
      Serial.println("Sensore non trovato a 0x76! Provo 0x77...");
      if (!bme.begin(0x77)) {
        Serial.println("ERRORE: Sensore non trovato. Controlla i cavi.");
        while (1);
      }
  }

  // --- SETUP FISICO CRITICO ---
  // Rimuoviamo ogni filtro software o oversampling per vedere la risposta grezza
  bme.setSampling(Adafruit_BME280::MODE_NORMAL,
                  Adafruit_BME280::SAMPLING_X2, // Temperatura: campionamento singolo
                  Adafruit_BME280::SAMPLING_X16, // Pressione: campionamento singolo
                  Adafruit_BME280::SAMPLING_X1, // Umidità: campionamento singolo
                  Adafruit_BME280::FILTER_OFF,  // <--- FILTRO IIR SPENTO (Nessun ritardo)
                  Adafruit_BME280::STANDBY_MS_500); // Standby minimo tra letture
  // ----------------------------
  
  Serial.println("Sensore configurato: NO FILTER, RAW DATA.");
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

  // Campionamento rapido (10 Hz)
  delay(1000);
}