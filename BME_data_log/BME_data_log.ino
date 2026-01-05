#include <BME280I2C.h> // Include la libreria specifica per il sensore BME280 tramite comunicazione I2C.

#include <Wire.h> // Include la libreria Wire, essenziale per la comunicazione I2C.



// Crea un'istanza (oggetto) della classe BME280I2C.
// Questo oggetto gestirà tutte le interazioni con il sensore.

BME280I2C bme;



// Funzione di setup: viene eseguita una sola volta all'avvio dello sketch.

void setup() {

    Serial.begin(9600);

    Wire.begin();

    while (!Serial);

   

    Serial.println("Avvio sensore BME280...");



    if (!bme.begin()) {

        // ... (Gestione errore)

        while (1);

    }

   

    Serial.println("BME280 connesso con successo!");

   

    delay(100);

}



 void loop() {

    float temp, hum, pres;

    bme.read(pres, temp, hum);

   

    // Formato: Temp,Umid,Pres

    Serial.print(millis());

    Serial.print(" ,    ");

    Serial.print(temp + 273.15, 2);

    Serial.print(" K ,    ");

    Serial.print(hum, 1);

    Serial.print(" % ,    ");

    Serial.print(pres/10, 3); 

   Serial.println(" kPa "); // println invia il carattere di fine riga

    delay(3000);

}