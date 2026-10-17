# CAD Models & Manufacturing Files

This directory contains the original Computer-Aided Design (CAD) models, CAM slicing output, 3D printing G-code, and CAD workspace screenshots for the physical scissor pantograph mechanism.

---

## 📁 Directory Structure

```text
cad/
├── .gdignore                         # Excludes large meshes and G-code from Godot package
├── README.md                         # Manufacturing and geometry documentation (this file)
├── stl/                              # Ready-to-print 3D mesh files (Binary STL)
│   ├── Деталь1.STL                   # Primary 60 mm scissor linkage with 3 hinge holes (Ø 4.0 mm)
│   └── Деталь2.STL                   # Complementary linkage / terminal mount
├── gcode/                            # Ultimaker Cura G-code toolpaths
│   ├── CFFFP_Group.gcode             # Batch print toolpath for multiple linkages
│   ├── CFFFP_Деталь2 vv.gcode        # High-precision vertical toolpath for Деталь2
│   ├── CFFFP_Деталь2 w.gcode         # Standard production run toolpath for Деталь2
│   ├── skizb/                        # Custom printer start routines (M140 bed temp & homing)
│   └── verj/                         # Custom printer end routines (G91 relative coordinates & cooldown)
└── screenshots/                      # SolidWorks modeling and assembly screenshots
    ├── Снимок экрана (4).png         # SolidWorks 3D viewport of parametric scissor linkage
    ├── Снимок экрана (5).png         # Dimensional sketches & hole wizard concentric constraints
    └── Снимок экрана (6).png         # SolidWorks assembly view showing multi-stage scissor fit
```

---

## 📐 Geometric Specifications

| Parameter | Value | Design Rationale |
| :--- | :--- | :--- |
| **Link Length ($\ell$)** | $60.0\text{ mm}$ | Optimized for desktop load testing ($m \in [0, 1.15\text{ kg}]$) |
| **Link Width ($w$)** | $10.0\text{ mm}$ | High in-plane bending resistance without excessive mass |
| **Link Thickness ($t$)** | $4.0\text{ mm}$ | Prevents out-of-plane buckling under high tensile pull |
| **Pivot Hole Diameter ($\varnothing$)** | $4.0\text{ mm}$ | Precision fit for $4\text{ mm}$ steel dowel pins (Hole Wizard) |
| **Hole Center Spacing** | $30.0\text{ mm}$ | Symmetrical midpoint hinge placement for uniform rhombus stroke |
| **Corner Fillet Radius ($R$)** | $5.0\text{ mm}$ | Tangent clearance preventing link collision during compression |

---

## 🖨️ Additive Manufacturing Guidelines (Ultimaker Cura)

- **Material:** PLA (Polylactic Acid) / PETG
- **Layer Height:** $0.10\text{ mm}$ (Fine) to achieve smooth bearing faces with minimal layer-line stick-slip friction
- **Wall Thickness:** $1.2\text{ mm}$ (3 perimeters minimum)
- **Top / Bottom Layers:** 4 layers ($0.4\text{ mm}$)
- **Infill:** $30\text{--}40\%$ Gyroid or Cubic for isotropic torsional stiffness
- **Print Temperature:** $205\text{ °C}$ nozzle, $60\text{ °C}$ heated bed
- **Horizontal Expansion:** $-0.08\text{ mm}$ (compensates for hole contraction, ensuring free pin rotation)
