import serial
import time
import os

# --- Configurazione ---
PORTA_SERIALE = '/dev/ttyACM0'      # Necessari per la comunicazione seriale diretta
BAUD_RATE = 9600
NOME_FILE_LOG = 'dati_bme_live.csv'     # grafico_dinamico.py legge questo tipo di file
# ---------------------

def inizializza_file_csv(filename):
    # Scrive l'intestazione solo se il file non esiste o è vuoto
    # L'intestazione deve corrispondere all'output dell'Arduino (TIMESTAMP, T, H, P)
    # Dato che il collegamento è fragile, sconsiglio la modifica di questo blocco
    intestazione = "Tempo relativo (ms) , Temperatura (C), Umidita (%), Pressione (kPa)\n"
    
    if not os.path.exists(filename) or os.stat(filename).st_size == 0:
        with open(filename, 'w') as f: # Usa 'w' (write) per creare e scrivere
            f.write(intestazione)
        print(f"File '{filename}' creato con intestazione.")

# --- Esecuzione Principale ---
inizializza_file_csv(NOME_FILE_LOG)

try:
    # 1. Inizializza la connessione seriale
    ser = serial.Serial(PORTA_SERIALE, BAUD_RATE, timeout=1)
    time.sleep(2) 
    
    ser.reset_input_buffer()

    print(f"Connesso a {PORTA_SERIALE} a {BAUD_RATE} baud. Scrittura su {NOME_FILE_LOG}")
    print("Inizio acquisizione dati. Premi Ctrl+C per interrompere.")

    # 2. Apriamo il file una sola volta in modalità append ('a')
    with open(NOME_FILE_LOG, 'a') as file_log:
        
        while True:
            # Legge la riga completa inviata dall'Arduino
            if ser.in_waiting > 0:
                linea = ser.readline().decode('utf-8').strip()
                
                if linea:
                    # Verifica che la linea non sia l'intestazione (se per caso l'Arduino la ri-invia)
                    if not linea.upper().startswith("TIMESTAMP"): 
                        
                        # 3. Scrivi la riga (che è già formattata come CSV) nel file.
                        # La funzione println() di Arduino assicura che il dato finisca con '\n' (nuova riga).
                        file_log.write(linea + '\n') 
                        file_log.flush() # Forza la scrittura sul disco immediatamente (meno efficiente ma più sicuro in caso di crash)
                        # Purtroppo crasha spesso la comunicazione, credo sia un problema di Ubuntu, quindi sconsiglio la modifica

                        # 4. Analisi e Output a Console
                        try:
                            # Assumendo il formato: TIMESTAMP, Temp, Umid, Pres
                            parts = linea.split(',')
                            if len(parts) == 4:
                                timestamp, temp_str, hum_str, pres_str = parts
                                
                                temperatura = float(temp_str)
                                umidita = float(hum_str)
                                pressione = float(pres_str)
                                
                                # Stampa i dati formattati per monitoraggio
                                print(f"[{int(timestamp):>10}] T: {temperatura:.1f}°C | H: {umidita:.1f}% | P: {pressione:.3f} kPa")

                        except ValueError:
                            # Gestisce linee incomplete o non numeriche
                            print(f"Dato non valido ricevuto: {linea}")
                            
except serial.SerialException as e:
    print(f"\nERRORE FATALE di connessione seriale: {e}")
    
except KeyboardInterrupt:
    print("\nAcquisizione interrotta dall'utente.")
    
finally:
    # La clausola 'with open(...)' chiude automaticamente il file_log.
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("Connessione seriale chiusa.")