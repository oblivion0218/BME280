import math

def calcola_moli_con_incertezza(pressione_kpa, temp_c, umidita_relativa, volume_ml):
    """
    Calcola n (moli) e rho (densità) con propagazione degli errori 
    usando il metodo delle perturbazioni numeriche.
    
    Incertezze (hardcoded come da richiesta):
    - T: +/- 1 °C
    - P: +/- 100 Pa (0.1 kPa)
    - UR: +/- 4 % (assoluto, es: 50 +/- 4)
    - V: +/- 3 ml
    """
    
    # --- CONFIGURAZIONE INCERTEZZE ---
    u_P_kpa = 0.1     # 100 Pa = 0.1 kPa
    u_T_c = 1.0       # 1 grado
    u_UR_pct = 4.0    # 4% umidità
    u_V_ml = 3.0      # 3 ml
    
    # --- FUNZIONE CORE (Fisica) ---
    def core_physics(p_kpa, t_c, ur_pct, v_ml):
        # 1. Costanti
        Rd = 287.058    # J/kgK (Aria secca)
        Rv = 461.495    # J/kgK (Vapore)
        Md = 0.028964   # kg/mol (Aria secca)
        Mv = 0.018015   # kg/mol (Acqua)

        # 2. Conversioni
        tk = t_c + 273.15
        p_tot_pa = p_kpa * 1000.0
        v_m3 = v_ml * 1e-6 # ml -> m^3
        
        # 3. Pressioni (Magnus-Tetens)
        # Saturazione
        es_hpa = 6.112 * math.exp((17.67 * t_c) / (t_c + 243.5))
        es_pa = es_hpa * 100.0
        
        # Parziali
        p_vap = es_pa * (ur_pct / 100.0)
        p_dry = p_tot_pa - p_vap
        
        # 4. Densità (rho = P / R_spec * T)
        rho_d = p_dry / (Rd * tk)
        rho_v = p_vap / (Rv * tk)
        densita_tot = rho_d + rho_v
        
        # 5. Moli (n = rho * V / M)
        # moli = (kg/m^3 * m^3) / (kg/mol)
        n_d = (rho_d * v_m3) / Md
        n_v = (rho_v * v_m3) / Mv
        n_tot = n_d + n_v
        
        return n_tot, densita_tot

    # --- CALCOLO NOMINALE ---
    n_nominale, rho_nominale = core_physics(pressione_kpa, temp_c, umidita_relativa, volume_ml)

    # --- PROPAGAZIONE (Differenze Finite) ---
    # Calcoliamo quanto varia il risultato se spostiamo ogni input del suo errore
    
    # 1. Perturbazione Pressione
    n_p, rho_p = core_physics(pressione_kpa + u_P_kpa, temp_c, umidita_relativa, volume_ml)
    dn_dP = n_p - n_nominale
    drho_dP = rho_p - rho_nominale
    
    # 2. Perturbazione Temperatura
    n_t, rho_t = core_physics(pressione_kpa, temp_c + u_T_c, umidita_relativa, volume_ml)
    dn_dT = n_t - n_nominale
    drho_dT = rho_t - rho_nominale
    
    # 3. Perturbazione Umidità
    n_ur, rho_ur = core_physics(pressione_kpa, temp_c, umidita_relativa + u_UR_pct, volume_ml)
    dn_dUR = n_ur - n_nominale
    drho_dUR = rho_ur - rho_nominale
    
    # 4. Perturbazione Volume
    n_v, rho_v = core_physics(pressione_kpa, temp_c, umidita_relativa, volume_ml + u_V_ml)
    dn_dV = n_v - n_nominale
    drho_dV = rho_v - rho_nominale # Nota: la densità non dipende dal volume, sarà ~0

    # --- SOMMA IN QUADRATURA (RSS) ---
    # Incertezza totale su n
    u_n_tot = math.sqrt(dn_dP**2 + dn_dT**2 + dn_dUR**2 + dn_dV**2)
    
    # Incertezza totale su rho
    u_rho_tot = math.sqrt(drho_dP**2 + drho_dT**2 + drho_dUR**2 + drho_dV**2)

    return {
        "valori": {
            "moli": n_nominale,
            "densita": rho_nominale
        },
        "incertezze": {
            "moli": u_n_tot,
            "densita": u_rho_tot
        },
        "contributi_moli": {
            "da_Pressione": abs(dn_dP),
            "da_Temp": abs(dn_dT),
            "da_Umidita": abs(dn_dUR),
            "da_Volume": abs(dn_dV)
        }
    }

# --- ESECUZIONE ---    292.57 K ,    28.5 % ,    98.736 kPa
P_in = 98.736 # kPa
T_in = 19.42    # °C
UR_in = 28.5   # %
V_in = 1015   # ml 1032 ma tolgo 17 ml per silice e elettronica

res = calcola_moli_con_incertezza(P_in, T_in, UR_in, V_in)

val_n = res['valori']['moli']
unc_n = res['incertezze']['moli']
val_rho = res['valori']['densita']
unc_rho = res['incertezze']['densita']

print(f"--- ANALISI INCERTEZZA (Metodo Numerico) ---")
print(f"Condizioni: P={P_in} kPa, T={T_in} °C, UR={UR_in} %, V={V_in} ml")
print("-" * 40)
print(f"MOLI TOTALI (n):    {val_n:.5f} ± {unc_n:.5f} mol")
print(f"DENSITÀ ARIA (rho): {val_rho:.5f} ± {unc_rho:.5f} kg/m³")
print("-" * 40)
print("Budget di incertezza (impatto sulle moli):")
tot_err = sum(res['contributi_moli'].values())
for k, v in res['contributi_moli'].items():
    perc = (v / tot_err) * 100  # Approssimativo, solo per peso relativo lineare
    print(f"  - {k}: {v:.6f} mol")

