/*
Il software di gestione è stato sviluppato in ambiente Arduino IDE,
avvalendosi di librerie specifiche per il protocollo di comunicazione I2C e la gestione dei registri del sensore.

In un Arduino, i pin SDA e SCL sono le linee di comunicazione del protocollo I2C (Inter-Integrated Circuit), 
un bus seriale utilizzato per collegare microcontrollori e periferiche (sensori, display OLED, memorie EEPROM)
utilizzando solo due fili.

- SDA (Serial Data): È la linea dedicata al trasferimento dei dati. È bidirezionale, 
il che significa che sia il master (Arduino) che lo slave (il sensore) possono inviare e ricevere bit su questo singolo cavo.

- SCL (Serial Clock): È la linea del clock. Generata solitamente dal master, 
serve a sincronizzare la trasmissione dei dati tra i dispositivi. 
Determina la velocità con cui i bit vengono letti sulla linea SDA.

*/


#include <Wire.h>                   // Libreria per la gestione del protocollo I2C
#include <Adafruit_Sensor.h>        // Classe base per i sensori Adafruit (standardizzazione)
#include <Adafruit_BME280.h>        // Libreria specifica per i registri del BME280

Adafruit_BME280 bme;                // Istanza dell'oggetto sensore

void setup() {
  Serial.begin(9600);
  while(!Serial);    // Attende l'apertura della seriale

  // Rimuoviamo ogni filtro software o oversampling per vedere la risposta grezza del sensore BME280
  bme.setSampling(Adafruit_BME280::MODE_NORMAL,
                  Adafruit_BME280::SAMPLING_X2,      // Temperatura: campionamento X2
                  Adafruit_BME280::SAMPLING_X16,     // Pressione: campionamento X16
                  Adafruit_BME280::SAMPLING_X1,      // Umidità: campionamento singolo
                  Adafruit_BME280::FILTER_OFF,       //  FILTRO IIR SPENTO (Nessun ritardo)
                  Adafruit_BME280::STANDBY_MS_500);  // Standby minimo tra letture
  
  Serial.println("Sensore configurato.");
}

// FILTER_OFF: Fondamentale. I sensori digitali spesso applicano una media mobile (filtro IIR) per "pulire" il dato. 
// Disattivandolo, otteniamo la risposta grezza del sensore.

void loop() {     // --- ACQUISIZIONE ---
  
  // Leggiamo i valori dai registri interni del sensore e applichiamo delle conversioni comode
  float tempK = bme.readTemperature() + 273.15;     // Conversione Celsius -> Kelvin
  float presKPa = bme.readPressure() / 1000.0F;     // Conversione Pascal -> kilopascal
  float hum = bme.readHumidity();                   // Umidità relativa in percentuale
  
  // Utilizziamo millis() per avere un riferimento temporale preciso
  unsigned long timeStamp = millis(); 

  // --- OUTPUT FORMATTATO ---
  Serial.print("Tempo(ms): ");
  Serial.print(timeStamp);
  Serial.print(" , Temp(K): ");
  Serial.print(tempK, 1);      // 1 cifra decimale
  Serial.print(" , Umidita(%): ");
  Serial.print(hum, 1);        // 1 cifra decimale 
  Serial.print(" , Press(kPa): ");
  Serial.println(presKPa, 3);  // 3 cifre decimali 
  
  // --- TIMING ---
  delay(1000); // Frequenza di campionamento f = 1 Hz
}