import matplotlib.pyplot as plt
import matplotlib.animation as animation
import pandas as pd
import numpy as np
import os

# --- Configurazione ---
NOME_FILE_LOG = 'dati_bme_live.csv'     # Legge il file di output da bme280_logger.py
INTERVALLO_AGGIORNAMENTO_MS = 1000
STEP_TEMPORALE_S = 1.0 
# ---------------------

# Setup della figura 
fig, ax1 = plt.subplots(figsize=(10, 6))
ax2 = ax1.twinx()  # Istanzio l'asse gemello una volta sola

def leggi_e_aggiorna(i):
    if not os.path.exists(NOME_FILE_LOG):
        return

    try:
        # Leggiamo il CSV
        df = pd.read_csv(NOME_FILE_LOG, skiprows=1, header=None, skipinitialspace=True)
        
        if df.empty or df.shape[1] < 4: # controllo sulle dimensioni
            return

        df.columns = ['Timestamp_Raw', 'Temp_K', 'Hum_Pct', 'Pres_kPa']

        # Pulizia dati ed estrazione numerica
        regex_num = r'(\d+\.\d+)'
        df['Temperatura'] = df['Temp_K'].astype(str).str.extract(regex_num).astype(float) - 273.15
        df['Umidita'] = df['Hum_Pct'].astype(str).str.extract(regex_num).astype(float)
        df['Pressione'] = df['Pres_kPa'].astype(str).str.extract(regex_num).astype(float)
        
        df.dropna(subset=['Temperatura', 'Umidita', 'Pressione'], inplace=True) # elimina dati corrotti
        
        # Asse temporale sintetico
        df['Tempo_Simulato_s'] = np.arange(len(df)) * STEP_TEMPORALE_S
        
        # --- PLOTTING ---
        # Puliamo entrambi gli assi per il redraw
        ax1.clear()
        ax2.clear()

        # Plot Temperatura su ASSE SINISTRO (ax1)
        ax1.plot(df['Tempo_Simulato_s'], df['Temperatura'], 
                 label='Temperatura (°C)', color='skyblue', linewidth=2.5)

        # Plot Pressione e Umidità su ASSE DESTRO (ax2)
        ax2.plot(df['Tempo_Simulato_s'], df['Pressione'], 
                 label='Pressione (kPa)', color='mediumseagreen', linewidth=2.5)
        
        ax2.plot(df['Tempo_Simulato_s'], df['Umidita'], 
                 label='Umidità (%)', color='mediumpurple', linewidth=2.5)

        # --- GESTIONE ASSI E LIMITI ---
        if not df.empty:
            ax1.set_xlim(left=0, right=df['Tempo_Simulato_s'].max() + STEP_TEMPORALE_S)
            
            # Limiti asse SX (Temperatura) - Dinamico con margine
            t_min, t_max = df['Temperatura'].min(), df['Temperatura'].max()
            ax1.set_ylim(bottom=t_min - 2, top=t_max + 2)

            # Limiti asse DX (Pressione/Umidità)
            # Pressione ~100 kPa, Umidità 0-100.
            # Impostiamo un range che copra bene entrambi, es: 0 - 110
            # Oppure dinamico tra min(Pres, Hum) e max(Pres, Hum)
            vals_dx = np.concatenate([df['Pressione'].values, df['Umidita'].values])
            ax2.set_ylim(bottom=np.min(vals_dx) - 5, top=np.max(vals_dx) + 5)

        
        # Titolo
        ax1.set_title(r'Monitoraggio Live BME280', fontsize=16)

        # Label Asse X
        ax1.set_xlabel(r'Tempo $t$ [s]', fontsize=14, fontweight='bold', color='#2F4F4F')

        # Forza ax1 a sinistra
        ax1.yaxis.set_label_position("left")
        ax1.yaxis.tick_left()
        ax1.set_ylabel(r'Temperatura $T$ [°C]', fontsize=14, fontweight='bold', color='#2F4F4F')
        ax1.tick_params(axis='y', labelcolor='skyblue')

        # Forza ax2 a destra
        ax2.yaxis.set_label_position("right")
        ax2.yaxis.tick_right()
        ax2.set_ylabel(r'Pressione [kPa] / Umidità [%]', fontsize=14, fontweight='bold', color='#2F4F4F')
        ax2.tick_params(axis='y', labelcolor='mediumseagreen')

        # Griglia Personalizzata (Memorizzata) su ax1
        ax1.grid(True, which='major', linestyle='--', alpha=0.6, color='#778899') 
        ax1.minorticks_on()
        ax1.grid(True, which='minor', linestyle=':', alpha=0.3, color='#778899')

        # Legenda Unificata (Raccogliamo le linee da entrambi gli assi)
        lines_1, labels_1 = ax1.get_legend_handles_labels()
        lines_2, labels_2 = ax2.get_legend_handles_labels()
        
        ax1.legend(lines_1 + lines_2, labels_1 + labels_2, 
                   loc= 'best', frameon=True, shadow=True, fontsize=12, facecolor='#F0F8FF')
        
        fig.subplots_adjust(top=0.92, bottom=0.12, left=0.10, right=0.90)

    except Exception as e:
        print(f"Errore nel loop: {e}")
        pass

ani = animation.FuncAnimation(fig, leggi_e_aggiorna, interval=INTERVALLO_AGGIORNAMENTO_MS)
plt.tight_layout()
plt.show()