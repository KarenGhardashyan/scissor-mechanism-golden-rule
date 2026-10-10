# Sim-to-Real Verification of the Golden Rule of Mechanics
### Interactive 3D Hardware Simulation & Virtual Telemetry Bench for Scissor Pantograph Mechanisms

[![Godot 4](https://img.shields.io/badge/Engine-Godot%204.5-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Physics Simulation](https://img.shields.io/badge/Physics-Classical%20Mechanics-orange)](#theoretical-principles)
[![UI Aesthetic](https://img.shields.io/badge/Aesthetic-Apple%20Liquid%20Glass-black)](https://developer.apple.com/visionos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An interactive computational physics testbench designed to experimentally model, visualize, and verify the **Golden Rule of Mechanics** (*Goldene Regel der Mechanik*) and the **Principle of Virtual Work** using linked rhombic scissor structures (pantographs).

![Simulation Preview](simulation_render.png)

---

## 🔬 Theoretical Principles

The physical apparatus investigates how multi-stage rhombic pantographs transmit input displacements and forces to an output suspended load, governed by the conservation of mechanical energy and transmission efficiency $\eta$:

$$\delta A_{\text{out}} = \eta \cdot \delta A_{\text{in}} \iff P_{\text{eff}} \cdot \delta L = \eta \cdot (T \cdot \delta H)$$

### 1. Rhombus Geometry & Kinematics
Each scissor linkage arm has constant physical length $l_{\text{arm}} = 6.0\text{ cm} = 0.06\text{ m}$.
For each rhombus stage of vertical height $H$:
$$\theta = \arccos\left(\frac{H}{2 \cdot l_{\text{arm}}}\right)$$
$$W(\theta) = 2 \cdot l_{\text{arm}} \cdot \sin(\theta) = 2 \cdot l_{\text{arm}} \sqrt{1 - \left(\frac{H}{2 \cdot l_{\text{arm}}}\right)^2}$$

For a mechanism composed of $n$ stacked rhombuses:
$$L(m) = n \cdot H(m) \implies \Delta L = n \cdot \Delta H$$

The kinematic displacement transmission factor is exactly linear:
$$\lambda \equiv \frac{\Delta L}{\Delta H} = n$$
- **Rig A ($n = 3$ stages)**: $\lambda_A = 3.000\times$ (Amplifies displacement by 3)
- **Rig B ($n = 5$ stages)**: $\lambda_B = 5.000\times$ (Amplifies displacement by 5)

### 2. Self-Weight Compensation (3D-Printed PLA)
Physical 3D-printed PLA linkage arms possess mass ($m_{\text{link}} \approx 0.05\text{ kg}$ per rhombus). Distributed self-weight exerts an equivalent static load concentrated at the bottom tip:
$$P_{\text{eff}} = m \cdot g + \frac{n \cdot m_{\text{link}} \cdot g}{2}$$

### 3. Virtual Work & Tensile Spring Force Equilibrium
Taking joint friction and pin compliance into account via mechanical efficiency $\eta \in [0.50, 1.00]$:
$$T(m, \eta) = \frac{n \cdot P_{\text{eff}}}{\eta}$$

Under linear Hookean elasticity with spring stiffness $k$:
$$\Delta H(m, \eta) = \frac{T(m, \eta)}{k} = \frac{n \cdot P_{\text{eff}}}{\eta \cdot k}$$
$$L(m, \eta) = n \cdot \left(H_0 + \Delta H(m, \eta)\right)$$

Notice that while Rig B ($n=5$) produces larger vertical extension for a given mass ($5\times$ vs $3\times$), its upper spring experiences $\approx 1.667\times$ higher tensile force ($T_B / T_A = 5/3$), exactly fulfilling the Golden Rule: **"What is gained in displacement is lost in force."**

---

## 🛠 Key Engineering Features

- **Apple "Light Liquid Glass" Aesthetic**:
  - Showroom environment with ACES tone-mapping, screen-space ambient occlusion (SSAO), and diffuse contact shadows.
  - Floating translucent frosted-glass panels inspired by VisionOS (`StyleBoxFlat` with custom border highlights and shadows).
  - High-contrast charcoal typography (`#1D1D1F`) designed for readability against light backgrounds.
- **Hero-Grade Tactile 3D Hardware**:
  - **Rig A**: Precision Satin Anodized Electric Blue linkages (`#0A73EB`) with indigo inlays, aerospace aluminum weight, and polished brass joint pins.
  - **Rig B**: Precision Satin Anodized Ultra Orange linkages (`#FF6B0D`) with amber inlays, machined bronze billet weight, and polished brass joint pins.
  - High-contrast unshaded 3D laser dimension guides with dual-cone arrowheads and horizontal reference ticks.
- **Realtime 2D Plot Engine (`LiveGraph.gd`)**:
  - Procedural anti-aliased vector rendering using Godot's `_draw()` canvas API.
  - Live curves for theoretical displacements $L_A(m) = 3 \cdot H_A(m)$ and $L_B(m) = 5 \cdot H_B(m)$.
  - Dynamic cursor line and interactive floating tooltip pills tracking mass changes.
- **Dynamic Physics Simulation**:
  - Damped second-order harmonic oscillator simulation for spring response.
  - Interactive parameters: mass $m \in [0.0, 1.5]\text{ kg}$, stiffness $k \in [500, 1500]\text{ N/m}$, efficiency $\eta \in [50\%, 100\%]$.
  - Kinetic impulse trigger for transient vibration and settling analysis.

---

## 📂 Project Architecture

```
scissor-mechanism/
├── scenes/
│   └── Main.tscn                 # Primary showroom scene with camera and dual rigs
├── scripts/
│   ├── Main.gd                   # Orchestration, VisionOS UI layout, and telemetry
│   ├── PantographRig.gd          # Kinematics, dynamics, 3D laser lines, and materials
│   ├── LiveGraph.gd              # Realtime 2D vector plot panel for L(m)
│   ├── OrbitCamera.gd            # Damped 360° orbit, pan, and zoom camera controller
│   └── SpringMeshGenerator.gd    # Procedural 3D helical chrome spring generator
├── shaders/
│   └── GlassPanel.gdshader       # Frosted glass blur shader
├── project.godot                 # Project settings & rendering configuration
└── README.md                     # Technical documentation & physics analysis
```

---

## 🚀 Running the Project

### Option 1: Live Web Demo (Recommended)
You can test the simulation directly in your web browser:
> **[▶ Launch Live Simulation](https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/)** *(Coming soon via GitHub Pages)*

### Option 2: Local Execution with Godot 4
1. Download **[Godot Engine 4.3+](https://godotengine.org/download)**.
2. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/scissor-pantograph-mechanics.git
   ```
3. Open Godot, click **Import**, select `project.godot`, and click **Edit & Run** (`F5`).

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
