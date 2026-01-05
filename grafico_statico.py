import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os

# --- Configurazione ---
NOME_FILE_LOG = '10gSilice-1litro.csv'
STEP_TEMPORALE_S = 3.0  # Tempo fisso tra una misurazione e l'altra
# ---------------------

def genera_grafico_statico():
    if not os.path.exists(NOME_FILE_LOG):
        print(f"Errore: Il file {NOME_FILE_LOG} non esiste.")
        return

    # 1. Caricamento Dati
    try:
        # Leggiamo il CSV saltando l'header testuale
        df = pd.read_csv(NOME_FILE_LOG, skiprows=1, header=None, skipinitialspace=True)
    except Exception as e:
        print(f"Errore nella lettura del file: {e}")
        return

    if df.empty or df.shape[1] < 4:
        print("Dati insufficienti o formato non valido.")
        return

    # 2. Parsing e Pulizia
    df.columns = ['Timestamp_Raw', 'Temp_K', 'Hum_Pct', 'Pres_kPa']

    # Estrazione valori numerici tramite Regex e conversione
    df['Temperatura'] = df['Temp_K'].astype(str).str.extract(r'(\d+\.\d+)').astype(float) - 273.15
    df['Umidita'] = df['Hum_Pct'].astype(str).str.extract(r'(\d+\.\d+)').astype(float)
    df['Pressione'] = df['Pres_kPa'].astype(str).str.extract(r'(\d+\.\d+)').astype(float)
    
    # Rimozione righe non valide
    df.dropna(subset=['Temperatura', 'Umidita', 'Pressione'], inplace=True)

    if df.empty:
        print("Nessun dato valido trovato dopo il parsing.")
        return

    # 3. Creazione Asse Temporale Sintetico
    # Crea un array [0, 3, 6, 9, ...] basato sul numero di campioni
    df['Tempo_Simulato_s'] = np.arange(len(df)) * STEP_TEMPORALE_S

    # 4. Scaling Pressione (per coerenza visiva)
    df['Pressione_Scalata'] = df['Pressione'] / 2.0

    # 5. Plotting
    fig, ax1 = plt.subplots(figsize=(12, 7))

    # Tracciamento delle curve
    ax1.plot(df['Tempo_Simulato_s'], df['Temperatura'], 
             label='Temperatura (°C)', color='skyblue', linewidth=2.5)
    ax1.plot(df['Tempo_Simulato_s'], df['Umidita'], 
             label='Umidità (%)', color='mediumpurple', linewidth=2.5)
    ax1.plot(df['Tempo_Simulato_s'], df['Pressione_Scalata'], 
             label='Pressione (kPa) / 2', color='mediumseagreen', linewidth=2.5)

    # Configurazione Assi e Titoli
    ax1.set_xlim(left=0, right=df['Tempo_Simulato_s'].max() + STEP_TEMPORALE_S)
    
    # Impostazione limiti Y dinamici con buffer
    vals = df[['Temperatura', 'Umidita', 'Pressione_Scalata']].values
    y_min, y_max = np.nanmin(vals), np.nanmax(vals)
    ax1.set_ylim(bottom=y_min - 5, top=y_max + 5)

    ax1.set_xlabel(f'Tempo (s)')
    ax1.set_ylabel('Grandezze Fisiche')
    ax1.grid(True, linestyle='--', alpha=0.6)
    ax1.legend(loc='best', frameon=True, shadow=True)

    plt.tight_layout()
    plt.show()

# Esecuzione
if __name__ == "__main__":
    genera_grafico_statico()