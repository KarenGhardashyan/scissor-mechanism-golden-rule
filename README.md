# Sim-to-Real Verification of the Golden Rule of Mechanics
### Experimental Physics Investigation, Additive Manufacturing & Interactive 3D Digital Twin

[![Godot 4](https://img.shields.io/badge/Engine-Godot%204.5-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Physics](https://img.shields.io/badge/Physics-Classical%20Mechanics-orange)](#-theoretical-principles)
[![School](https://img.shields.io/badge/Institution-A.%20Shahinyan%20Phys--Math%20School-red)](https://physmath.am)
[![Aesthetic](https://img.shields.io/badge/Aesthetic-Apple%20Liquid%20Glass-black)](https://developer.apple.com/visionos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An end-to-end scientific and engineering research project investigating the **Golden Rule of Mechanics** (*Goldene Regel der Mechanik*) and the **Principle of Virtual Work** through custom 3D-printed scissor pantograph mechanisms, physical laboratory testing, statistical regression modeling, and a real-time 3D simulation bench built in Godot Engine 4.

![Simulation Preview](simulation_render.png)

---

## 👨‍🔬 Authorship & Academic Affiliation

- **Student Researcher:** **Karen Ghardashyan** (10th Grade)
- **Academic Advisor:** **Bilor Kourghinyan**
- **Institution:** **A. Shahinyan Special Phys-Math School under Yerevan State University (YSU)**, Yerevan, Armenia
- **Academic Year:** 2024–2025 · Semester II

---

## 📌 Executive Summary

The project establishes a complete **Sim-to-Real** loop across three integrated domains:
1. **Mechanical Design & Digital Fabrication (CAD/CAM):** Parametric SolidWorks modeling of modular scissor arms ($6\text{ cm}$ and $3\text{ cm}$) and precision 3D printing (Ultimaker Cura, $0.1\text{ mm}$ fine PLA) to minimize pivot friction.
2. **Physical Load Testing & Empirical Data:** Calibrated static load testing ($m \in [0.0\text{ kg}, 1.15\text{ kg}]$) on 3-stage ($n=3$) and 5-stage ($n=5$) testbenches using both Hookean steel springs and hyperelastic rubber polymers.
3. **Interactive 3D Digital Twin (Godot 4):** A real-time virtual testbench rendered in an Apple VisionOS *"Light Liquid Glass"* aesthetic, replicating physical kinematics, spring tension, and live $L(m)$ vector plots.

---

## 🔬 Theoretical Principles

### 1. Conservation of Mechanical Energy & Virtual Work
In an ideal static mechanical linkage, mechanical work done by input spring tension $T$ over vertical deflection $\delta H$ equals the work performed on the suspended load $P$ over total mechanism extension $\delta L$:

$$\delta A_{\text{in}} = \delta A_{\text{out}} \iff T \cdot \delta H = P \cdot \delta L$$

For a pantograph comprising $n$ identical rhombuses:
$$L(m) = n \cdot H(m) \implies \lambda \equiv \frac{\delta L}{\delta H} = n$$

$$\therefore T = n \cdot P = n \cdot (m \cdot g)$$

### 2. Linkage Self-Weight Compensation (3D-Printed PLA)
Because physical PLA arms have non-zero mass ($m_{\text{link}} \approx 0.05\text{ kg}$ per rhombus), the distributed gravitational load acts at the linkage center of mass, which moves by $S_{\text{cm}} = n \frac{H}{2}$:

$$T(m) = n \left(m \cdot g + \frac{P_w}{2}\right)$$

### 3. Hooke's Law & Linear Regression Slope
Under spring stiffness $k$:
$$\Delta H(m) = \frac{T(m)}{k} = m \cdot g \cdot \frac{n}{k} + \frac{n \cdot P_w}{2k}$$

Plotting $\Delta H(m)$ vs. $m$ yields a linear slope $\tan \alpha = \frac{n \cdot g}{k}$, allowing direct experimental extraction of spring stiffness:
$$k = \frac{n \cdot g}{\tan \alpha}$$

---

## 📊 Physical Experimental Results

Full CSV datasets are available in the [`experimental_data/`](experimental_data/) directory.

### Series 1: Five-Stage Rig ($n = 5$) with Steel Spring
$$\lambda_{\text{theoretical}} = 5.000\times \quad \big| \quad \overline{\lambda}_{\text{empirical}} = \mathbf{4.94 \pm 0.12}$$

| Load $m$ [kg] | Total Span $L$ [cm] | Spring Height $H$ [cm] | Experimental $\lambda = L/H$ |
| :---: | :---: | :---: | :---: |
| **0.00** | 26.0 | 5.0 | **5.20** |
| **0.10** | 27.5 | 5.5 | **5.00** |
| **0.20** | 30.0 | 6.0 | **5.00** |
| **0.30** | 32.5 | 6.5 | **5.00** |
| **0.40** | 34.3 | 7.0 | **4.90** |
| **0.50** | 36.1 | 7.4 | **4.87** |
| **1.15** | 43.5 | 9.2 | **4.73** |

- **Extracted Spring Constant:** Linear regression slope $\tan \alpha \approx 4.5\times 10^{-2}\text{ m/kg} \implies k \approx \mathbf{1090\text{ N/m}}$.

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

- **Extracted Spring Constant:** Linear regression slope $\tan \alpha \approx 0.030\text{ m/kg} \implies k \approx \mathbf{981\text{ N/m}}$.

### Series 3: Non-Linear Polymer Hyperelasticity (Rubber Band, $n = 5$)
- While the steel spring exhibited clean linear Hookean behavior, the rubber band demonstrated non-linear hyperelastic stiffening.
- **Geometric Invariance:** Even with non-linear elastomer stretching, $\lambda = L/H \approx 4.96$ remained invariant across all loads.
- **Polynomial Regression:** The curve $L(m)$ was successfully modeled using a 3rd-degree polynomial ($R^3$), explaining molecular chain alignment under increasing strain.

---

## 💻 Interactive 3D Digital Twin (Godot 4)

- **Sim-to-Real Synchronization:** Programmed with the exact physical link dimensions ($l = 0.06\text{ m}$, $H_0 = 0.075\text{ m}$, $k = 1000\text{ N/m}$).
- **Apple "Light Liquid Glass" Aesthetic:** Minimalist showroom lighting, ACES tone-mapping, screen-space ambient occlusion (SSAO), and floating frosted-glass telemetry cards.
- **Realtime 2D Vector Plot (`LiveGraph.gd`):** Procedural anti-aliased canvas rendering plotting theoretical curves $L_A(m) = 3 \cdot H_A(m)$ and $L_B(m) = 5 \cdot H_B(m)$ with live mass tracking markers and interactive scrubbing.
- **High-Contrast 3D Laser Dimension Guides:** Real-time unshaded guide lines with conical arrowheads and reference ticks displaying instantaneous $H$ and $L$ values.

---

## 📂 Repository Structure

```text
├── cad/                     # SolidWorks 3D models & STL 3D-printing files
│   └── README.md            # Part geometry, hole tolerances, and specifications
├── slicer_profiles/         # Ultimaker Cura FFF print profiles & parameters
│   └── README.md            # Infill, layer height, and wall thickness guide
├── experimental_data/       # Raw physical measurement datasets (CSV)
│   ├── spring_n5_measurements.csv
│   ├── spring_n3_measurements.csv
│   └── rubber_band_measurements.csv
├── docs/                    # Full academic papers & formal documentation
│   ├── RESEARCH_PAPER.md    # Complete scientific research paper in English
│   └── PROJECT_PASSPORT.md  # Official STEM High School Project Passport
├── scenes/                  # Godot 4 3D scene files
│   ├── Main.tscn            # Master showroom scene
│   └── PantographRig.tscn   # Parametric pantograph component scene
├── scripts/                 # Godot 4 GDScript implementation
│   ├── Main.gd              # UI layout, telemetry coordinator, and event routing
│   ├── PantographRig.gd     # Kinematic solver, spring dynamics, and 3D lasers
│   ├── LiveGraph.gd         # Real-time procedural 2D plot panel
│   ├── OrbitCamera.gd       # Damped 360° orbit, pan, and zoom camera controller
│   └── SpringMeshGenerator.gd # Procedural helical spring geometry generator
├── shaders/                 # Custom graphic shaders
│   └── GlassPanel.gdshader  # Translucent frosted glass blur shader
├── build/                   # Pre-compiled standalone releases (Windows x64 ZIP)
├── simulation_render.png    # High-resolution simulation showcase image
├── project.godot            # Engine project configuration
├── LICENSE                  # MIT License
└── README.md                # Main presentation and project overview
```

---

## 🚀 Running the Project

### Standalone Executable (Windows x64)
A pre-compiled standalone executable is provided in the repository:
1. Download `build/ScissorPantograph_Windows_x64.zip`.
2. Extract the archive and double-click `ScissorPantograph.exe` to run immediately without needing Godot installed.

### Opening in Godot Engine 4
1. Install **[Godot Engine 4.3+](https://godotengine.org/download)**.
2. Clone this repository:
   ```bash
   git clone https://github.com/KarenGhardashyan/scissor-mechanism-golden-rule.git
   ```
3. Open Godot, click **Import**, select `project.godot`, and press **Run** (`F5`).

---

## 📜 Academic Citations & References

1. **A. Shahinyan Phys-Math Special School** STEM Curriculum (Theme 4: *Conservation Laws in Mechanics*).
2. Principle of Virtual Work and D'Alembert's Principle in Multibody Kinematics.
3. *Goldene Regel der Mechanik*, Classical Mechanical Physics.

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
