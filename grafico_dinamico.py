import matplotlib.pyplot as plt
import matplotlib.animation as animation
import pandas as pd
import numpy as np
import os

# --- Configurazione ---
NOME_FILE_LOG = 'dati_bme_live.csv'
INTERVALLO_AGGIORNAMENTO_MS = 3000
STEP_TEMPORALE_S = 3.0  # Tempo fisso tra una riga e l'altra
# ---------------------

fig, ax1 = plt.subplots(figsize=(10, 6))

def leggi_e_aggiorna(i):
    if not os.path.exists(NOME_FILE_LOG):
        return

    try:
        # Leggiamo il CSV
        df = pd.read_csv(NOME_FILE_LOG, skiprows=1, header=None, skipinitialspace=True)
        
        if df.empty or df.shape[1] < 4:
            return

        # Assegniamo i nomi per comodità di estrazione, anche se il Timestamp reale viene ignorato
        df.columns = ['Timestamp_Raw', 'Temp_K', 'Hum_Pct', 'Pres_kPa']

        # Pulizia dati ed estrazione numerica
        df['Temperatura'] = df['Temp_K'].astype(str).str.extract(r'(\d+\.\d+)').astype(float) - 273.15
        df['Umidita'] = df['Hum_Pct'].astype(str).str.extract(r'(\d+\.\d+)').astype(float)
        df['Pressione'] = df['Pres_kPa'].astype(str).str.extract(r'(\d+\.\d+)').astype(float)
        
        # Rimuoviamo righe con valori NaN (parsing fallito)
        df.dropna(subset=['Temperatura', 'Umidita', 'Pressione'], inplace=True)
        
        # --- MODIFICA CORE ---
        # Invece di leggere il tempo, generiamo una sequenza: 0, 3, 6, 9...
        # basata sul numero di righe valide lette.
        df['Tempo_Simulato_s'] = np.arange(len(df)) * STEP_TEMPORALE_S
        
        # Scaling pressione
        df['Pressione_Scalata'] = df['Pressione'] / 2.0

        ax1.clear() 

        # Plotting usando il Tempo Simulato sull'asse X
        ax1.plot(df['Tempo_Simulato_s'], df['Temperatura'], 
                 label='Temperatura (°C)', color='skyblue', linewidth=2.5)
        ax1.plot(df['Tempo_Simulato_s'], df['Umidita'], 
                 label='Umidità (%)', color='mediumpurple', linewidth=2.5)
        ax1.plot(df['Tempo_Simulato_s'], df['Pressione_Scalata'], 
                 label='Pressione (kPa) / 2', color='mediumseagreen', linewidth=2.5)

        # Gestione Assi
        if not df.empty:
            # X-Axis: dal tempo 0 all'ultimo step calcolato + buffer
            ax1.set_xlim(left=0, right=df['Tempo_Simulato_s'].max() + STEP_TEMPORALE_S)
            
            # Y-Axis: range dinamico
            vals = df[['Temperatura', 'Umidita', 'Pressione_Scalata']].values
            y_min, y_max = np.nanmin(vals), np.nanmax(vals)
            ax1.set_ylim(bottom=y_min - 5, top=y_max + 5)

        # Estetica
        ax1.set_xlabel('Tempo (s) - [Step fisso 3s]')
        ax1.set_ylabel('Grandezze Fisiche')
        ax1.set_title('Monitoraggio BME280 (Asse temporale sintetico)')
        ax1.grid(True, linestyle='--', alpha=0.5)
        ax1.legend(loc='upper left', frameon=True)

    except Exception as e:
        print(f"Errore nel loop: {e}")
        pass

ani = animation.FuncAnimation(fig, leggi_e_aggiorna, interval=INTERVALLO_AGGIORNAMENTO_MS)
plt.show()