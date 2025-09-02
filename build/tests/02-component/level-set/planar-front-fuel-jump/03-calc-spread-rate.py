#!/usr/bin/env python3
import math
import sys

# --- Args ---
if len(sys.argv) < 8:
    print(f"Usage: {sys.argv[0]} M1 M10 M100 MLH MLW (unused) fbfm40")
    sys.exit(1)

M1, M10, M100, MLH, MLW = [float(arg) for arg in sys.argv[1:6]]
M = [M1, M10, M100, M1, MLH, MLW]  # fractions

fbfm40 = int(sys.argv[7])

# --- Fuel model constants ---
if fbfm40 == 10:
    # Fuel Model 10
    W0   = [0.138, 0.092, 0.23, 0.0, 0.0, 0.092]   # lb/ft2
    SIG  = [2000, 109, 30, 9999, 9999, 1500]       # ft2/ft3
    DELTA = 1.0
    MEX_DEAD = 0.25
    HOC = 8000
    RHOP = 32.0
    ST = 0.055
    SE = 0.01
    ETAS = 0.174 / (SE**0.19)

elif fbfm40 == 3:
    # Fuel Model 3 from your table: 3,FBFM03,.FALSE.,0.138,0,0,0,0,1500,9999,9999,2.5,25,8000
    W0   = [0.138, 0.0, 0.0, 0.0, 0.0, 0.0]
    SIG  = [1500, 9999, 9999, 9999, 9999, 9999]
    DELTA = 2.5
    MEX_DEAD = 0.25
    HOC = 8000
    RHOP = 32.0
    ST = 0.055
    SE = 0.01
    ETAS = 0.174 / (SE**0.19)

else:
    print(f"Unsupported fuel model: {fbfm40}")
    sys.exit(1)

# --- Step 1: Derived quantities ---
A = [SIG[i]*W0[i]/RHOP for i in range(6)]
A_dead = sum(A[0:4])
A_live = sum(A[4:6])
A_overall = A_dead + A_live

F = [0.0]*6
for i in range(4):
    F[i] = A[i]/max(A_dead, 1e-9)
for i in range(4,6):
    F[i] = A[i]/max(A_live, 1e-9)

FMEX = [0.0]*6
for i in range(4):
    FMEX[i] = F[i]*MEX_DEAD

F_dead = A_dead/A_overall
F_live = A_live/A_overall

FW0 = [F[i]*W0[i] for i in range(6)]
FSIG = [F[i]*SIG[i] for i in range(6)]
EPS = [math.exp(-138.0/SIG[i]) for i in range(6)]
FEPS = [F[i]*EPS[i] for i in range(6)]

WPRIMENUMER = [W0[i]*EPS[i] for i in range(6)]
MPRIMEDENOM = [W0[i]*EPS[i] for i in range(6)]

W0_dead = sum(FW0[0:4])
W0_live = sum(FW0[4:6])
WN_dead = W0_dead*(1-ST)
WN_live = W0_live*(1-ST)

SIG_dead = sum(FSIG[0:4])
SIG_live = sum(FSIG[4:6])
SIG_overall = F_dead*SIG_dead + F_live*SIG_live

BETA   = sum(W0)/(DELTA*RHOP)
BETAop = 3.348/(SIG_overall**0.8189)
RHOB   = sum(W0)/DELTA

XI = math.exp((0.792 + 0.681*math.sqrt(SIG_overall))*(0.1+BETA)) / \
     (192. + 0.2595*SIG_overall)

A_COEFF = 133./(SIG_overall**0.7913)
B_COEFF = 0.02526*SIG_overall**0.54
C_COEFF = 7.47*math.exp(-0.133*SIG_overall**0.55)
E_COEFF = 0.715*(math.exp(-0.000359*SIG_overall))

GAMMAPRIMEPEAK = SIG_overall**1.5 / (495. + 0.0594*SIG_overall**1.5)
GAMMAPRIME = GAMMAPRIMEPEAK*(BETA/BETAop)**A_COEFF * \
             math.exp(A_COEFF*(1. - BETA/BETAop))

TR = 384. / SIG_overall

GP_WND_EMD_ES_HOC = GAMMAPRIME * WN_dead * ETAS * HOC
GP_WNL_EML_ES_HOC = GAMMAPRIME * WN_live * ETAS * HOC

# RHOBEPSQIG
QIG = [250. + 1116.*M[i] for i in range(6)]
RHOBEPSQIG_dead = RHOB * sum(FEPS[i]*QIG[i] for i in range(4))
RHOBEPSQIG_live = RHOB * sum(FEPS[i]*QIG[i] for i in range(4,6))
RHOBEPSQIG = F_dead*RHOBEPSQIG_dead + F_live*RHOBEPSQIG_live

# --- Step 2: FMC ---
FMC = [F[i]*M[i] for i in range(6)]

# --- Step 3: Moisture damping and IR ---
M_dead_sum = sum(FMC[0:4])
momex = M_dead_sum / MEX_DEAD
etam_dead = max(0., min(1., 1. - 2.59*momex + 5.11*momex**2 - 3.52*momex**3))
IR_dead = GP_WND_EMD_ES_HOC * etam_dead

# Live extinction moisture
if sum(W0[4:6]) > 1e-6:
    WPRIMEDENOM_56_sum = W0[4]*math.exp(-500./SIG[4]) + W0[5]*math.exp(-500./SIG[5])
    MEX_live = 2.9 * sum(WPRIMENUMER[0:4]) / WPRIMEDENOM_56_sum if WPRIMEDENOM_56_sum > 0 else 100.0
else:
    MEX_live = 100.0
MEX_live = max(MEX_live, MEX_DEAD)

M_live_sum = sum(FMC[4:6])
momex = M_live_sum / MEX_live
etam_live = max(0., min(1., 1. - 2.59*momex + 5.11*momex**2 - 3.52*momex**3))
IR_live = GP_WNL_EML_ES_HOC * etam_live

IR_total = IR_dead + IR_live  # Btu/(ft2·min)

# --- Step 4: No wind/slope ROS ---
ADJ = 1.0
VS0_ftmin = ADJ * (IR_total * XI / RHOBEPSQIG)
VS0_mph = VS0_ftmin * 0.3048 * 60.

print(f"No-wind, no-slope ROS for FM{fbfm40}:")
print(f"  VS0 = {VS0_ftmin:.4f} ft/min")
print(f"  VS0 = {VS0_mph:.4f} m/h")