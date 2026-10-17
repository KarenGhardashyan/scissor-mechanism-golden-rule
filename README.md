# Sim-to-Real Verification of the Golden Rule of Mechanics
### Experimental Physics Investigation, Additive Manufacturing & Interactive 3D Digital Twin

[![Live Demo](https://img.shields.io/badge/Live%20Simulation-Play%20in%20Browser-0071E3?style=for-the-badge&logo=googlechrome&logoColor=white)](https://karenghardashyan.github.io/scissor-mechanism-golden-rule/)
[![Download Executable](https://img.shields.io/badge/Standalone%20App-Windows%20x64%20(ZIP)-34C759?style=for-the-badge&logo=windows&logoColor=white)](build/ScissorPantograph_Windows_x64.zip)

[![Godot 4](https://img.shields.io/badge/Engine-Godot%204.5-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Physics](https://img.shields.io/badge/Physics-Classical%20Mechanics-orange)](#-theoretical-principles--mathematical-formulations)
[![School](https://img.shields.io/badge/Institution-A.%20Shahinyan%20Phys--Math%20School-red)](https://physmath.am)
[![Aesthetic](https://img.shields.io/badge/Aesthetic-Apple%20VisionOS%20Liquid%20Glass-black)](https://developer.apple.com/visionos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> ### 🌐 [▶ Click Here to Launch the Live 3D Simulation](https://karenghardashyan.github.io/scissor-mechanism-golden-rule/)
> **Interact with the physical rigs, inspect real-time LaTeX theory equations, adjust suspended masses ($m$), change spring constants ($k$), toggle mechanical efficiency ($\eta$), explore planetary gravity ($g$), and inspect regression curves directly in your web browser.**

An end-to-end scientific and engineering research project investigating the **Golden Rule of Mechanics** (*Goldene Regel der Mechanik*) and the **Principle of Virtual Work** through custom 3D-printed scissor pantograph mechanisms, physical laboratory testing, statistical Desmos regression modeling, and a real-time 3D simulation bench built in Godot Engine 4.

![Simulation Showcase](simulation_render.png)

---

## 👨‍🔬 Authorship, Timeline & Academic Trajectory

- **Student Researcher:** **Karen Ghardashyan**
  - *Phase I (Physical Prototyping & Lab Experiments):* 10th Grade (Spring 2024–2025)
  - *Phase II (Sim-to-Real Digital Twin & Symplectic Solver):* 12th Grade (2025–2026)
- **Academic Advisor:** **Bilor Kourghinyan**
- **Institution:** **A. Shahinyan Special Phys-Math School under Yerevan State University (YSU)**, Yerevan, Armenia
- **Official STEM Project Classification:** Interdisciplinary · Constructive / Design-Build · Challenge-Driven · Individual Research

> **Note on Project Trajectory (Phase I to Phase II):**
> This project represents a multi-year engineering evolution. In 10th grade, the research originated as a physical investigation to solve high school laboratory pedagogical gaps: design, 3D printing, and empirical verification. In 12th grade, having observed real-world mechanical bottlenecks (joint friction hysteresis, non-linear elastomer creep, harmonic oscillations), the author engineered a real-time 3D **Digital Twin** in Godot 4.5. This closed the complete **Sim-to-Real loop**, synthesizing CAD/CAM, experimental physics, numerical differential equations, and interactive computer graphics.

---

## 📌 Executive Summary & Research Value

The project solves a fundamental educational and mechanical problem:
1. **The Pedagogical Dilemma:** In high school physics, the Golden Rule of Mechanics (*"What is gained in force is lost in distance"*) is traditionally taught via static 2D chalkboard diagrams or ideal levers. Students struggle to grasp coupled kinematics, internal elasticity, and dynamic energy dissipation.
2. **The Engineering Loop (CAD $\to$ Print $\to$ Test $\to$ Debug $\to$ Sim):**
   - **SolidWorks Parametric CAD:** Parametric modeling of modular linkages ($6\text{ cm}$ and $3\text{ cm}$) with low-stress filleted corners and hinge holes.
   - **Ultimaker Cura Additive Manufacturing:** Slicing optimization with fine $0.1\text{ mm}$ layer resolution and gyroid infill to minimize Coulomb joint friction.
   - **Empirical Testing & Desmos Regression:** Load testing ($m \in [0.0\text{ kg}, 1.15\text{ kg}]$) on $n=3$, $n=5$, and non-linear rubber bands.
   - **Engineering Failure Modes & Debugging:** Identifying real-world backlash ($\approx 0.15\text{ mm}$ pin clearance), hysteresis, link bending moments, and self-weight deflection.
   - **Sim-to-Real Computational Twin (Godot 4.5):** Translating the physical discoveries into an interactive 3D digital twin featuring three rigs (Uniform $n=3$, Progressive $1:2:3$, and Uniform $n=5$), planetary gravity, and 2nd-order damped ODE dynamics.

---

## ⚙️ Engineering Journey: CAD Design, 3D Printing & Debugging

```mermaid
flowchart LR
    A["CAD Modeling<br>(SolidWorks 2024)"] --> B["CAM Slicing<br>(Ultimaker Cura 0.1mm)"]
    B --> C["Additive Manufacturing<br>(FDM PLA Extrusion)"]
    C --> D["Bench Assembly &<br>Hardware Debugging"]
    D --> E["Empirical Testing<br>& Desmos Regression"]
    E --> F["Computational Digital Twin<br>(Godot 4.5 GDScript)"]
```

### 1. Parametric CAD Modeling (SolidWorks)
The pantograph links were modeled parametrically from scratch (archived in [`cad/`](cad/)):
- **Primary Scissor Bars ($6.0\text{ cm} \times 1.0\text{ cm}$):** Designed with 3 symmetrical hinge holes ($\varnothing = 4.0\text{ mm}$ via Hole Wizard) at both extremities and the exact geometric midpoint ($3.0\text{ cm}$). Binary STL: [`cad/stl/Деталь1.STL`](cad/stl/Деталь1.STL).
- **Terminal Half-Bars ($3.0\text{ cm} \times 1.0\text{ cm}$):** Dual-pivot links for mounting to the upper fixed gantry clamp. Binary STL: [`cad/stl/Деталь2.STL`](cad/stl/Деталь2.STL).
- **Stress-Relief Filleting ($R = 0.5\text{ cm}$):** Applied to all bar ends using the Fillet tool. This crucial geometry prevents adjacent links from colliding during scissor compression and eliminates stress concentrations near the pivot pins.
- **SolidWorks Modeling Screenshots:** View original CAD sketches and assembly constraints in [`cad/screenshots/`](cad/screenshots/).

| SolidWorks CAD Assembly & STL Mesh | Cura Slicing Profiles ($0.1\text{ mm}$) |
| :---: | :---: |
| ![SolidWorks Model](docs/images/hardware/solidworks_stl_model.jpeg) | ![Cura Profile](docs/images/hardware/cura_slicing_profiles.png) |
| *Parametric scissor arms with $\varnothing = 4\text{ mm}$ bearing holes and $R = 0.5\text{ cm}$ fillets* | *Fine $0.1\text{ mm}$ layer height profile with custom G-code routines* |

### 2. CAM Slicing & Additive Manufacturing (Ultimaker Cura)
- **Material:** Generic Polylactic Acid (PLA), chosen for its high tensile modulus ($E \approx 3.5\text{ GPa}$) and minimal thermal shrinkage.
- **Layer Thickness:** $0.1\text{ mm}$ (Fine Profile) to achieve ultra-smooth bearing contact faces and minimize plastic-on-plastic Coulomb friction.
- **Print Speed:** $60\text{ mm/s}$ extrusion speed, $120\text{ mm/s}$ travel speed.
- **Infill & Shell Geometry:** High-density Cubic/Gyroid infill with 3 perimeter walls ($1.2\text{ mm}$ shell thickness) to resist out-of-plane buckling under high tensile loads.
- **G-Code Toolpaths:** Ready-to-print production G-code and custom printer start/end scripts are provided in [`cad/gcode/`](cad/gcode/).

---

### 3. Engineering Challenges & Troubleshooting (What We Had to Overcome)

Building a physical mechanism that matches theoretical equations revealed several non-trivial real-world engineering hurdles:

| Challenge / Engineering Problem | Root Cause Analysis | Engineering Solution & Resolution |
| :--- | :--- | :--- |
| **1. Pivot Pin Backlash & Play** | Drill bit / nozzle tolerance caused $\approx 0.15\text{ mm}$ oversize on holes, resulting in cumulative droop across 5 stages. | Re-calibrated Cura horizontal expansion parameter (`-0.08 mm`) and standardized on precision $4.0\text{ mm}$ steel pins. |
| **2. Joint Friction Hysteresis** | Layer-line ridges on FDM printed faces caused stick-slip friction, creating a $\pm 1.5\text{ mm}$ deadband. | Switched to $0.1\text{ mm}$ layer height with ironing enabled; applied low-viscosity PTFE lubricant to pivot faces. |
| **3. Linkage Self-Weight Sag** | Theoretical equations assumed massless linkages, but real PLA links ($m_{\text{link}} \approx 0.05\text{ kg}$) created baseline extension. | Derived new analytical formulation taking link center-of-mass into account: $P_{\text{eff}} = (m + \frac{n}{2} m_{\text{link}})g$. |
| **4. Elastomer Viscoelastic Creep** | Rubber bands suffered from stress relaxation and strain hardening under high loads ($> 800\text{ g}$). | Replaced with linear temper-hardened steel coil springs ($k \approx 1000\text{ N/m}$); modeled rubber band using 3rd-degree polynomial. |
| **5. High-Load Lateral Buckling** | Under $> 1\text{ kg}$ suspended load, slender 2D scissor arms tended to twist out of plane. | Reinforced link thickness ($3.6\text{ mm}$); added interlocking hub collars to maintain planar rigidity. |

---

## 🔬 Theoretical Principles & Mathematical Formulations

### 1. Principle of Virtual Work & Ideal Mechanical Advantage
In an ideal static mechanical linkage at equilibrium, infinitesimal virtual displacements yield zero net virtual work. The input mechanical work done by the upper helical extension spring tension $T$ over vertical rhombus compression $\delta H$ strictly equals the output work done lifting the suspended payload $P_{\text{eff}}$ through total stroke $\delta L$:

$$\delta A_{\text{in}} = \delta A_{\text{out}} \iff T \cdot \delta H = P_{\text{eff}} \cdot \delta L$$

Defining the kinematic transmission ratio $\lambda \equiv \frac{\delta L}{\delta H}$:

$$T_{\text{ideal}} = \lambda \cdot P_{\text{eff}}$$

### 2. Parasitic Energy Dissipation & Hinge Friction
In physical 3D-printed hardware, each scissor stage incorporates multiple rotating pivot pins. During angular rotation $\Delta \theta_i$, dry Coulomb friction and bearing contact resistance dissipate mechanical energy into irreversible thermal losses:

$$\Delta E_{\text{dissipated}} = \sum_{i=1}^{N_{\text{hinges}}} \int M_{\text{fric}, i}(\theta_i) \, d\theta_i$$

Where $M_{\text{fric}, i} = \mu \cdot R_i \cdot r_{\text{pin}}$ depends on joint reaction forces $R_i$, pin radius $r_{\text{pin}}$, and friction coefficient $\mu$. Taking transmission efficiency $\eta \in [0.50, 1.00]$ into account:

$$A_{\text{out}} = \eta \cdot A_{\text{in}} \iff T = \frac{\lambda \cdot P_{\text{eff}}}{\eta}$$

### 3. Multi-Linkage Architectures & Transmission Ratios ($\lambda$)
- **Rig A ($n = 3$ Uniform Scissor):**
  $$L_A(m) = 3 \cdot H(m) \implies \lambda_A = \mathbf{3.000\times}$$
- **Rig C ($1:2:3$ Progressive Scissor):** Links scale with arithmetic lengths $\{1\ell, 2\ell, 3\ell\}$:
  $$L_C(m) = (1 + 2 + 3) \cdot H_0(m) = 6 \cdot H_0(m) \implies \lambda_C = \mathbf{6.000\times}$$
- **Rig B ($n = 5$ Uniform Scissor):**
  $$L_B(m) = 5 \cdot H(m) \implies \lambda_B = \mathbf{5.000\times}$$

### 4. Static Equilibrium with Planetary Gravity & Structural Self-Weight
The effective load $P_{\text{eff}}$ accounts for suspended payload mass $m$ plus structural PLA link mass $m_{\text{link}} \approx 0.05\text{ kg}$ evaluated at the center of mass under gravity $g$:

$$P_{\text{eff}} = \left(m + m_{\text{struct}}\right) \cdot g, \quad m_{\text{struct}} = \begin{cases} \frac{n}{2} \cdot m_{\text{link}}, & \text{Uniform Rigs} \\ 3.0 \cdot m_{\text{link}}, & \text{Rig C } (1:2:3) \end{cases}$$

### 5. Hooke's Law & Characteristic Elongation
Combining linear elasticity $T = k \cdot \Delta H$ with kinematic amplification:

$$\Delta H(m) = \frac{T(m)}{k} = \frac{\lambda \cdot P_{\text{eff}}}{\eta \cdot k}$$

$$\Delta L(m) = \lambda \cdot \Delta H(m) = \frac{\lambda^2 \cdot P_{\text{eff}}}{\eta \cdot k} = \frac{\lambda^2 \cdot (m + m_{\text{struct}}) \cdot g}{\eta \cdot k}$$

### 6. Experimental Stiffness Extraction (Linear Regression Slope)
Differentiating $\Delta H$ with respect to suspended mass $m$ yields the experimental regression slope $\tan(\alpha)$:

$$\tan(\alpha) = \frac{\partial (\Delta H)}{\partial m} = \frac{\lambda \cdot g}{\eta \cdot k} \iff k = \frac{\lambda \cdot g}{\eta \cdot \tan(\alpha)}$$

### 7. 2nd-Order Dynamic Harmonic Vibration ODE
Transient response under step load transitions or dynamic impulses obeys the damped harmonic oscillator differential equation:

$$\frac{d^2 H}{dt^2} + 2 \zeta \omega_n \frac{dH}{dt} + \omega_n^2 \left(H(t) - H_{\text{target}}\right) = 0$$

Where natural frequency $\omega_n$ couples dynamically to spring stiffness $k$ and reflected mechanism inertia:

$$\omega_n = \sqrt{\frac{k_{\text{eff}}}{m_{\text{eff}}}} = \sqrt{\frac{k}{\frac{m + m_{\text{struct}}}{\lambda^2}}}, \qquad c = 2 \zeta \omega_n m_{\text{eff}}$$

---

## 📊 Physical Experimental Results & Desmos Regressions

Raw datasets are maintained in [`experimental_data/`](experimental_data/). Statistical regression curves were plotted and validated using **Desmos Graphing Calculator**.

### 🔬 Physical Hardware Apparatus & Laboratory Testbench
The physical validation experiments were conducted using custom 3D-printed pantograph linkages mounted on a calibrated vertical test stand with high-precision suspended masses and calibrated displacement sensors.

| Custom 3D-Printed Apparatus | Calibrated Load Testing Stand |
| :---: | :---: |
| ![Physical Scissor Apparatus](docs/images/hardware/physical_rig_apparatus.png) | ![Laboratory Testing](docs/images/hardware/physical_load_testing.png) |
| *Modular 3D-printed precision linkages with low-friction pivot bearings* | *Calibrated static weight load testing ($m \in [0.0 - 1.15\text{ kg}]$)* |

> 📹 **Upcoming:** Full video demonstrations and high-speed motion capture recordings of physical vibration and dynamic testing will be linked here directly.

---

### Series 1: Five-Stage Rig ($n = 5$) with Steel Spring
$$\lambda_{\text{theoretical}} = 5.000\times \quad \big| \quad \overline{\lambda}_{\text{empirical}} = \mathbf{4.94 \pm 0.12}$$

| Load $m$ [kg] | Total Span $L$ [cm] | Spring Height $H$ [cm] | Experimental $\lambda = L/H$ |
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

#### Desmos Regression Analysis for $n=5$:
- **Extracted Spring Constant:** Linear regression slope $\tan(\alpha) \approx 0.045\text{ m/kg} \implies k \approx \mathbf{1090\text{ N/m}}$.
- **Span Regression $L(m)$ and Elongation $H(m)$:**
  ![Desmos n=5 L(m)](docs/images/desmos/desmos_spring_n5_L_vs_m.png)
  ![Desmos n=5 H(m)](docs/images/desmos/desmos_spring_n5_H_vs_m.png)
- **Direct Geometric Invariance $L(H)$:** Slope $\tan(\alpha) = \lambda \approx 5.0$ confirms $L = 5 \cdot H$:
  ![Desmos n=5 L(H)](docs/images/desmos/desmos_spring_n5_L_vs_H.png)

---

### Series 2: Three-Stage Rig ($n = 3$) with Steel Spring
$$\lambda_{\text{theoretical}} = 3.000\times \quad \big| \quad \overline{\lambda}_{\text{empirical}} = \mathbf{3.04 \pm 0.10}$$

| Load $m$ [kg] | Total Span $L$ [cm] | Spring Height $H$ [cm] | Experimental $\lambda = L/H$ |
| :---: | :---: | :---: | :---: |
| **0.00** | 15.6 | 5.0 | **3.12** |
| **0.10** | 17.0 | 5.3 | **3.20** |
| **0.20** | 17.5 | 5.6 | **3.13** |
| **0.30** | 18.0 | 6.0 | **3.00** |
| **0.40** | 19.0 | 6.5 | **2.92** |
| **0.50** | 20.0 | 6.8 | **2.94** |
| **1.00** | 23.9 | 8.0 | **2.99** |

#### Desmos Regression Analysis for $n=3$:
- **Extracted Spring Constant:** Linear regression slope $\tan(\alpha) \approx 0.030\text{ m/kg} \implies k \approx \mathbf{981\text{ N/m}}$.
- **Span Regression $L(m)$ and Geometric Linearity $L(H)$:**
  ![Desmos n=3 L(m)](docs/images/desmos/desmos_spring_n3_L_vs_m.png)
  ![Desmos n=3 L(H)](docs/images/desmos/desmos_spring_n3_L_vs_H.png)

---

### Series 3: Non-Linear Polymer Hyperelasticity (Rubber Band, $n = 5$)
$$\lambda_{\text{theoretical}} = 5.000\times \quad \big| \quad \overline{\lambda}_{\text{empirical}} = \mathbf{4.96 \pm 0.13}$$

| Load $m$ [g] | Total Span $L$ [cm] | Band Height $H$ [cm] | Experimental $\lambda = L/H$ |
| :---: | :---: | :---: | :---: |
| **0** | 17.4 | 3.5 | **4.97** |
| **100** | 23.3 | 4.7 | **4.96** |
| **200** | 25.5 | 5.0 | **5.10** |
| **300** | 28.4 | 5.7 | **4.98** |
| **400** | 36.5 | 7.0 | **5.21** |
| **500** | 38.7 | 8.0 | **4.84** |
| **600** | 41.5 | 8.5 | **4.88** |
| **700** | 43.5 | 8.8 | **4.94** |
| **800** | 44.5 | 9.3 | **4.78** |

#### Desmos Polynomial Regression (Cubic Strain Hardening):
While the steel spring exhibited linear Hookean deformation, the rubber band experienced non-linear polymer strain stiffening modeled via a 3rd-degree polynomial in Desmos:
![Desmos Rubber L(m)](docs/images/desmos/desmos_rubber_L_vs_m.png)
![Desmos Rubber H(m)](docs/images/desmos/desmos_rubber_H_vs_m.png)

> **Key Discovery:** Despite severe non-linear hyperelasticity in the elastomer, kinematic invariance **$\lambda = L/H \approx 5.0$ holds true across all loads**, demonstrating that kinematic mechanical advantage is strictly determined by linkage geometry and independent of spring linearity.

---

## 🛠️ Simulation Engineering & Digital Twin Architecture

The 3D interactive workbench was designed from scratch in **Godot Engine 4 (GDScript)** to provide a 1:1 digital twin of the physical testbench:

```mermaid
graph TD
    A["User Inputs (Sliders / Presets)"] --> B["Main.gd (Coordinator & UI)"]
    B --> C["PantographRig.gd (Kinematic & Dynamic Solver)"]
    C --> D["2nd-Order ODE Solver (Symplectic Euler)"]
    C --> E["3D Procedural Mesh & Lasers Generator"]
    B --> F["LiveGraph.gd (Real-Time 2D Vector Plot)"]
    B --> G["Web Layer (KaTeX LaTeX Mathematical Modal)"]
    D --> H["Hardware Telemetry Table (λ, ΔH, ΔL, T, W)"]
```

### Key Technical Systems:
1. **Procedural Kinematics (`PantographRig.gd`):**
   - Calculates exact trigonometric rhombus positions: $\theta = \arccos\left(\frac{H}{2\ell}\right)$, $W = 2\ell\sin(\theta)$.
   - Handles both uniform and 1:2:3 progressive arm scaling with automatic center-of-mass balancing.
2. **Symplectic Integration for Dynamics:**
   - Evaluates $\ddot{H} + 2\zeta\omega_n \dot{H} + \omega_n^2 (H - H_{\text{target}}) = 0$ across high-frequency sub-steps (up to 400 Hz), ensuring unconditional numerical stability without jitter even under low damping ratios.
3. **Interactive 3D Joint Force Vector Visualizer Engine:**
   - Click any pivot pin in 3D to inspect the full local force decomposition in real time:
     - **$F_y$ (Vertical Load / Upper Support):** Downward transmitted load or upward support reaction [Blue].
     - **$F_x$ (Lateral Thrust):** Scissor toggle mechanical thrust $F_x = \frac{P}{2\tan\theta}$ [Red].
     - **$R$ (Reaction Resultant):** Vector sum $\vec{R} = \vec{F}_x + \vec{F}_y$ [Green].
     - **$F_{\text{spr}}$ (Spring Restoring Pull):** Direct helical spring tension pulling anchor downward, stage 0 bottom pin upward, and centering lateral scissor hinges [Purple].
     - **$f_k$ (Kinetic Friction):** Dynamic Coulomb sliding drag active during oscillation opposing velocity [Amber].
     - **$f_s$ (Static Friction / Stiction):** Incipient slip threshold capacity holding the linkage at rest [Brown].
4. **Coulomb Friction Mechanics & Stiction Toggle:**
   - Toggle static friction on/off to compare ideal theoretical equilibrium against real-world stick-slip hysteresis with a physical deadband ($L \pm \text{deadband}$).
5. **Stepped Response & Linear Regression Engine (`LiveGraph.gd`):**
   - Isolate individual rigs (e.g., Rig A only) to inspect discrete step increments with real-time empirical linear regression and slope $\tan(\alpha)$ overlay.
6. **Procedural Helical Spring Mesh (`SpringMeshGenerator.gd`):**
   - Generates 3D cylindrical tube coils along a 3D helix path in real time, flexing and compressing smoothly with dynamic load.
7. **Refined Matte Studio PBR Materials:**
   - Non-glare industrial matte polymer (`metallic = 0.06`, `roughness = 0.68`), slate gray calibration masses, and spring steel under studio lighting with zero bloom and zero SSR dithering for pristine WebGL performance.
8. **Liquid Glass UI with KaTeX LaTeX Engine:**
   - VisionOS frosted glass aesthetic with floating panels, backdrop blur (`16px`), and web-integrated KaTeX typesetting for mathematical textbook formulas.

---

## 🎓 Recommendations for Top Universities (MIT, Harvard, Stanford, Caltech)

This project exhibits the exact traits sought by admissions committees and faculty research labs:

1. **Demonstrated Intellectual Vitality & Problem-Solving Resilience:**
   - The project does not merely state theoretical formulas; it chronicles real physical breakdowns (pin clearance backlash, Coulomb friction, out-of-plane buckling) and systematically solves each via engineering design.
2. **True Multidisciplinary Mastery (STEM Synergy):**
   - Combines **Mechanical Engineering** (SolidWorks CAD, tolerances, fillets), **Materials & CAM** (Cura slicing, infill patterns, FDM print orientation), **Experimental Physics** (static equilibrium, Hooke's law, Desmos regression), and **Computer Science / Computational Physics** (Godot 4, Symplectic Euler ODE solver, WebAssembly/KaTeX).
3. **From Physical Prototype to Digital Twin:**
   - Demonstrates modern Industry 4.0 methodology: starting with physical hardware in Grade 10, recognizing system limits, and synthesizing an interactive computational digital twin in Grade 12.
4. **Educational Leadership:**
   - Designed to modernize school laboratories and empower peers to understand classical mechanics through interactive visual computing and tactile experimentation.

---

## 📂 Repository Structure

```text
├── cad/                     # SolidWorks 3D CAD models, STL meshes, Cura G-code & screenshots
│   ├── README.md            # Manufacturing guide, part geometry, and print parameters
│   ├── stl/                 # 3D printable meshes (Деталь1.STL, Деталь2.STL)
│   ├── gcode/               # Cura production toolpaths (CFFFP_Group.gcode, start/end scripts)
│   └── screenshots/         # SolidWorks 3D CAD modeling and assembly screenshots
├── slicer_profiles/         # Ultimaker Cura FFF print profiles & parameters
├── experimental_data/       # Raw physical measurement datasets (CSV)
│   ├── spring_n5_measurements.csv
│   ├── spring_n3_measurements.csv
│   └── rubber_band_measurements.csv
├── docs/                    # Full academic papers & formal documentation
│   ├── RESEARCH_PAPER.md    # Complete scientific research paper in English
│   ├── PROJECT_PASSPORT.md  # Official STEM High School Project Passport
│   └── images/              # Documentation assets & Desmos regression plots
│       ├── desmos/          # Laboratory regression charts from Desmos
│       ├── hardware/        # Physical testbench photos, SolidWorks & Cura profiles
│       └── simulation_showcase.png
├── scenes/                  # Godot 4 3D scene files (Main.tscn, PantographRig.tscn)
├── scripts/                 # Core simulation GDScript source code
│   ├── Main.gd              # UI coordinator, telemetry bus, force visualizer & KaTeX bridge
│   ├── PantographRig.gd     # Kinematic solver, spring dynamics, stiction & laser visualizers
│   ├── LiveGraph.gd         # Real-time procedural 2D plot panel & regression analysis
│   ├── OrbitCamera.gd       # 360° orbit, smooth panning, and zoom controller
│   └── SpringMeshGenerator.gd # Procedural helical spring geometry generator
├── shaders/                 # Frosted glass blur shaders (GlassPanel.gdshader)
├── web/                     # HTML5 WebGL export bundle (hosted on GitHub Pages)
├── build/                   # Pre-compiled standalone releases (Windows x64 ZIP)
├── simulation_render.png    # High-resolution simulation showcase image
├── project.godot            # Godot 4.5 engine configuration
├── LICENSE                  # MIT License
└── README.md                # Master presentation and documentation
```

---

## 🚀 Running the Project

### 1. Live Browser Simulation (No Installation Required)
Directly open **[https://karenghardashyan.github.io/scissor-mechanism-golden-rule/](https://karenghardashyan.github.io/scissor-mechanism-golden-rule/)** in Chrome, Firefox, Safari, or Edge.

### 2. Standalone Executable (Windows x64)
1. Download [`build/ScissorPantograph_Windows_x64.zip`](build/ScissorPantograph_Windows_x64.zip).
2. Extract the archive and double-click `ScissorPantograph.exe`.

### 3. Opening in Godot Engine 4
1. Install **[Godot Engine 4.3+](https://godotengine.org/download)**.
2. Clone this repository:
   ```bash
   git clone https://github.com/KarenGhardashyan/scissor-mechanism-golden-rule.git
   ```
3. Open Godot, click **Import**, select `project.godot`, and press **Run** (`F5`).

---

## 📜 Academic Citations & References

1. **A. Shahinyan Phys-Math Special School** STEM Curriculum (*Conservation Laws in Mechanics*).
2. Principle of Virtual Work and D'Alembert's Principle in Multibody Linkage Kinematics.
3. *Goldene Regel der Mechanik*, Classical Mechanical Physics.
4. Desmos Graphing Calculator Statistical Regression Suite.

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
