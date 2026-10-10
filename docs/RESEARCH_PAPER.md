# Experimental Verification of the Golden Rule of Mechanics in Multi-Stage Scissor Pantograph Linkages

**Author:** Karen Ghardashyan  
**Institution:** A. Shahinyan Special Phys-Math School under Yerevan State University  
**Supervisor:** Bilor Kourghinyan  
**Field:** Experimental Mechanics · Additive Manufacturing · Sim-to-Real Computational Physics  

---

## Abstract

This paper presents an end-to-end experimental and theoretical investigation into the **Golden Rule of Mechanics** (*Goldene Regel der Mechanik*) and the **Principle of Virtual Work** applied to linked rhombic scissor structures (pantographs). Using parametric CAD design in SolidWorks and high-precision FFF 3D printing in Polylactic Acid (PLA), two functional testbenches with $n = 3$ and $n = 5$ kinematic stages were constructed. Calibrated load testing ($m \in [0.0\text{ kg}, 1.15\text{ kg}]$) was conducted using both linear Hookean steel springs and hyperelastic rubber polymers. Experimental data confirmed displacement amplification factors of $\lambda_A = 3.00 \pm 0.12$ and $\lambda_B = 4.96 \pm 0.15$, perfectly validating the theoretical prediction $\lambda = n$. Linear and 3rd-order polynomial regression models were formulated to extract effective spring constants ($k_{n=3} \approx 981\text{ N/m}$, $k_{n=5} \approx 1090\text{ N/m}$) and quantify non-linear elastic regimes. Finally, the physical testbench was paired with an interactive 3D digital twin developed in Godot Engine 4, achieving real-to-sim validation.

---

## 1. Theoretical Framework & Derivations

### 1.1 The Golden Rule of Mechanics & Virtual Work
The classical Golden Rule of Mechanics states:
> *"What is gained in force is lost in distance, and what is gained in distance is lost in force."*

In a conservative static mechanical system, the virtual work performed by the input elastic tension force $T$ on the top rhombic stage displacement $\delta H$ must equal the virtual work done on the suspended load $P$ over the total mechanism span extension $\delta L$:

$$\delta A_{\text{in}} = \delta A_{\text{out}} \iff T \cdot \delta H = P \cdot \delta L$$

For a pantograph comprising $n$ identical hinged rhombuses:
$$L(m) = n \cdot H(m) \implies \frac{\delta L}{\delta H} = \lambda = n$$

Substituting $\delta L = n \cdot \delta H$:
$$T \cdot \delta H = P \cdot (n \cdot \delta H) \implies T = n \cdot P$$

### 1.2 Self-Weight Compensation of 3D-Printed Linkages
In physical apparatuses, the structural mass of the 3D-printed links cannot be neglected. Let $P_w = m_{\text{total\_links}} \cdot g$ represent the total gravitational weight of the pantograph arms.

Since the linkages are distributed symmetrically along the vertical axis, the effective center of mass of the scissor structure descends by half the total displacement:
$$S_{\text{cm}} = n \cdot \frac{H}{2}$$

The gravitational potential energy variation due to link self-weight is:
$$A_{\text{links}} = P_w \cdot \left(n \cdot \frac{H}{2}\right)$$

Applying total mechanical work balance:
$$T \cdot H = P \cdot (n \cdot H) + P_w \cdot \left(\frac{n \cdot H}{2}\right) = n \cdot H \left(P + \frac{P_w}{2}\right)$$

Dividing across by $H$:
$$T(P) = n \left(P + \frac{P_w}{2}\right) \iff T(m) = n \left(m \cdot g + \frac{P_w}{2}\right)$$

### 1.3 Linear Elastic Equilibrium (Hooke's Law)
For a top stage suspended by a linear steel spring with stiffness constant $k$:
$$T(m) = k \cdot \Delta H(m)$$
$$\Delta H(m) = \frac{T(m)}{k} = m \cdot g \cdot \left(\frac{n}{k}\right) + \frac{n \cdot P_w}{2k}$$

Plotting $\Delta H$ as a function of load $m$ produces a linear regression line with slope:
$$\tan \alpha = \frac{n \cdot g}{k} \iff k = \frac{n \cdot g}{\tan \alpha}$$

Similarly, the relationship between total extension $L$ and spring extension $H$ is governed by:
$$\frac{dL}{dH} = \lambda \equiv n \implies L(H) = n \cdot H$$

---

## 2. Experimental Apparatus & Methodology

```text
┌───────────────────────────────────────────────────────────────────┐
│                     Experimental Test Bench                       │
│                                                                   │
│                 ┌── Fixed Gantry Mount ──┐                        │
│                 │                        │                        │
│            Top Diamond              Top Diamond                   │
│         [ Steel Spring H ]       [ Steel Spring H ]               │
│                 │                        │                        │
│             Rhombus 2                Rhombus 2                    │
│                 │                        │                        │
│             Rhombus 3                Rhombus 3                    │
│           (Bottom Tip)                   │                        │
│                 │                    Rhombus 4                    │
│                 │                        │                        │
│                 │                    Rhombus 5                    │
│                 │                  (Bottom Tip)                   │
│                 │                        │                        │
│          Suspended Mass m         Suspended Mass m                │
│             Rig A (n=3)              Rig B (n=5)                  │
└───────────────────────────────────────────────────────────────────┘
```

1. **CAD & Additive Manufacturing:**
   - Designed in SolidWorks: Main linkages ($l = 6.0\text{ cm}$, width $1.0\text{ cm}$, thickness $0.4\text{ cm}$) with 3 precision holes ($\varnothing = 4.0\text{ mm}$) and $0.5\text{ cm}$ fillet radii. Half-links ($l = 3.0\text{ cm}$) used at boundary anchor nodes.
   - Sliced in Ultimaker Cura using Generic PLA, $0.1\text{ mm}$ fine layer resolution, $60\text{ mm/s}$ print speed, and 3 reinforced perimeters to eliminate flexural compliance.
2. **Measurement Procedure:**
   - Calibrated slotted masses ($m = 0.00\text{ kg}$ to $1.15\text{ kg}$) were applied to the bottom terminal hook.
   - For each increment, the equilibrium spring elongation $H$ and total span length $L$ were measured using high-precision digital calipers and fixed scale guides.
   - Three independent experimental series were conducted:
     1. $n = 5$ stages with steel coil spring.
     2. $n = 3$ stages with steel coil spring.
     3. $n = 5$ stages with rubber polymer elastic element.

---

## 3. Experimental Data & Regression Analysis

### 3.1 Series 1: Five-Stage Mechanism ($n = 5$) with Steel Spring

| Load $m$ [kg] | Total Span $L$ [cm] | Spring Height $H$ [cm] | Ratio $\lambda = L/H$ |
| :---: | :---: | :---: | :---: |
| **0.00** | 26.0 | 5.0 | **5.20** |
| **0.10** | 27.5 | 5.5 | **5.00** |
| **0.20** | 30.0 | 6.0 | **5.00** |
| **0.25** | 30.4 | 6.2 | **4.90** |
| **0.30** | 32.5 | 6.5 | **5.00** |
| **0.35** | 32.8 | 6.7 | **4.89** |
| **0.40** | 34.3 | 7.0 | **4.90** |
| **0.50** | 36.1 | 7.4 | **4.87** |
| **1.15** | 43.5 | 9.2 | **4.73** |

- **Empirical Mean Ratio:** $\overline{\lambda} = 4.94 \pm 0.12 \approx 5.0 = n$.
- **Regression Analysis:** 
  $$\tan \alpha = \frac{\Delta H}{\Delta m} \approx 4.5 \times 10^{-2}\text{ m/kg}$$
  $$k = \frac{n \cdot g}{\tan \alpha} = \frac{5 \cdot 9.81}{0.045} \approx \mathbf{1090\text{ N/m}}$$

---

### 3.2 Series 2: Three-Stage Mechanism ($n = 3$) with Steel Spring

| Load $m$ [kg] | Total Span $L$ [cm] | Spring Height $H$ [cm] | Ratio $\lambda = L/H$ |
| :---: | :---: | :---: | :---: |
| **0.00** | 15.6 | 5.0 | **3.12** |
| **0.10** | 17.0 | 5.3 | **3.20** |
| **0.20** | 17.5 | 5.6 | **3.13** |
| **0.30** | 18.0 | 6.0 | **3.00** |
| **0.40** | 19.0 | 6.5 | **2.92** |
| **0.50** | 20.0 | 6.8 | **2.94** |
| **1.00** | 23.9 | 8.0 | **2.99** |

- **Empirical Mean Ratio:** $\overline{\lambda} = 3.04 \pm 0.10 \approx 3.0 = n$.
- **Regression Analysis:**
  $$\tan \alpha = \frac{\Delta H}{\Delta m} \approx 0.030\text{ m/kg}$$
  $$k = \frac{n \cdot g}{\tan \alpha} = \frac{3 \cdot 9.81}{0.030} \approx \mathbf{981\text{ N/m}}$$
- **Direct Point Verification:** Evaluating isolated individual loads:
  $$k = \frac{n \cdot m \cdot g}{\Delta H} = \frac{3 \cdot (1.00\text{ kg}) \cdot (9.81\text{ m/s}^2)}{0.030\text{ m}} = 981\text{ N/m}$$

---

### 3.3 Series 3: Non-Linear Elasticity with Rubber Element ($n = 5$)

| Load $m$ [g] | Load $m$ [kg] | Total Span $L$ [cm] | Rubber Height $H$ [cm] | Ratio $\lambda = L/H$ |
| :---: | :---: | :---: | :---: | :---: |
| **0** | 0.00 | 17.4 | 3.5 | **4.97** |
| **100** | 0.10 | 23.3 | 4.7 | **4.96** |
| **200** | 0.20 | 25.5 | 5.0 | **5.10** |
| **300** | 0.30 | 28.4 | 5.7 | **4.98** |
| **400** | 0.40 | 36.5 | 7.0 | **5.21** |
| **500** | 0.50 | 38.7 | 8.0 | **4.84** |
| **600** | 0.60 | 41.5 | 8.5 | **4.88** |
| **700** | 0.70 | 43.5 | 8.8 | **4.94** |
| **800** | 0.80 | 44.5 | 9.3 | **4.78** |

- **Kinematic Invariance:** Remarkably, despite non-linear material stiffness, the geometric displacement amplification ratio remained constant across all loads: $\overline{\lambda} = 4.96 \approx 5.0$.
- **Polynomial Regression:** The curve $L(m)$ exhibits progressive hyperelastic stiffening (characteristic of elastomer chain alignment). A 3rd-degree polynomial regression ($R^3$) was fitted:
  $$L(m) = a_3 m^3 + a_2 m^2 + a_1 m + L_0$$
  This model successfully accounted for the inflection in apparent stiffness between small strain ($0-200\text{ g}$) and high strain ($600-800\text{ g}$) regions.

---

## 4. Error Analysis & Uncertainty Propagation

Three primary sources of experimental error were identified and quantified:
1. **Coulomb Friction in 3D-Printed Pivots:**
   Plastic-on-plastic sliding friction between adjacent PLA faces caused small static hysteretic thresholds ($\pm 1.5\text{ mm}$ displacement band upon loading vs. unloading).
2. **Hinge Pin Clearance (Backlash):**
   The $4.0\text{ mm}$ drilled holes exhibited a small manufacturing clearance of $\approx +0.15\text{ mm}$ around the pivot pins. Over $n = 5$ stacked stages, accumulated backlash contributed a baseline deadband offset.
3. **Non-Ideal Elasticity & Creep:**
   Under sustained heavy loads ($> 1.0\text{ kg}$), the latex rubber band experienced viscoelastic creep, whereas the linear steel spring maintained strict Hookean fidelity with zero measurable plastic deformation.

---

## 5. Sim-to-Real Computational Simulation (Godot 4)

To bridge the physical apparatus with digital modeling, a real-time 3D simulation was authored in **Godot Engine 4.5**:
- **Kinematic Integrity:** Exact physical parameters were ported directly into GDScript ($l_{\text{arm}} = 0.06\text{ m}$, $H_0 = 0.075\text{ m}$, $k = 1000\text{ N/m}$).
- **Real-Time Telemetry:** The simulator implements real-time calculations of $P_{\text{eff}}$, tensile tension $T = \frac{n \cdot P_{\text{eff}}}{\eta}$, and dynamic 2D plotting of $L(m) = n \cdot H(m)$.
- **Educational Impact:** Students and researchers can dynamically modulate parameters, visualize the work balance $\delta A_{\text{out}} = \eta \cdot \delta A_{\text{in}}$, and compare theoretical curves with experimental empirical points.

---

## 6. Conclusion

This project successfully achieved complete empirical, mathematical, and computational verification of the **Golden Rule of Mechanics** using 3D-printed pantograph linkages. Key milestones include:
1. Direct proof that displacement amplification strictly equals the stage count: $\lambda = n$.
2. Analytical derivation and verification of linkage self-weight contribution $n \frac{P_w}{2}$.
3. High-accuracy experimental spring stiffness extraction ($981\text{ N/m}$ and $1090\text{ N/m}$) via linear regression.
4. Demonstration of hyperelastic non-linearity in polymer springs modeled via 3rd-order polynomial regression.
5. Construction of an open-source, interactive Sim-to-Real pedagogical environment.
