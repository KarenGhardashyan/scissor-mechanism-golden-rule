# High School STEM Research Project Passport
## Academic Year 2024–2025 · Semester II

**Institution:** A. Shahinyan Special Phys-Math School under YSU (Yerevan, Armenia)  
**Subject Field:** Physics, STEM, Geometry  
**Project Title:** *Fabrication and Experimental Testing of an Apparatus Demonstrating the Golden Rule of Mechanics*  
**Student Author:** Karen Ghardashyan (10th Grade)  
**Project Advisor:** Bilor Kourghinyan  
**Duration:** 10 Weeks (10 Structured Hours) · **Completion Deadline:** May 15, 2025  
**Project Classification:** Interdisciplinary · Constructive / Design-Build · Challenge-Driven · Individual Research  

---

### 1. Problem Statement & Challenge

> **Core Challenge:** How can high school physics laboratories be modernized and enriched with student-designed, digitally fabricated experimental apparatuses? Is physical experimentation fundamentally superior to purely abstract theoretical explanations in understanding mechanical conservation laws?

Many students struggle to intuitively grasp the **Golden Rule of Mechanics** (*"What is gained in force is lost in distance"*) when taught solely through textbook equations and 2D chalkboard sketches. Without physical tactile devices, the link between internal elastic deformation and kinematic displacement amplification remains abstract. This project addresses the challenge by designing, 3D printing, and empirically verifying a modular multi-stage scissor pantograph mechanism.

---

### 2. Program Learning Outcomes & Deliverables

1. **Experimental Apparatus:** Design and manufacture a working physical testbench using CAD and FDM additive manufacturing.
2. **Operational Competency:** Master precision assembly, calibration, and experimental mass loading protocols.
3. **Physical Explanation:** Mathematically and experimentally demonstrate the Golden Rule of Mechanics through linked rhombic stages.
4. **Pedagogical Demonstration:** Present the working device and quantitative findings in classroom demonstration lectures and interactive student workshops.

---

### 3. Engineering & Manufacturing Specifications

#### A. Computer-Aided Design (SolidWorks)
- **Primary Scissor Links:** Length $l = 6.0\text{ cm}$, width $w = 1.0\text{ cm}$. Features 3 hinge holes ($\varnothing = 4.0\text{ mm}$ via Hole Wizard): two at outer pivot endpoints and one centered at $3.0\text{ cm}$ for structural symmetry.
- **Terminal Half-Links:** Length $l = 3.0\text{ cm}$, width $w = 1.0\text{ cm}$, with 2 hinge holes.
- **Fillet Treatment:** Rounded outer edges with radius $R = 0.5\text{ cm}$ using the Fillet tool to reduce stress concentrations and eliminate corner collision during rhombic scissor expansion.
- **File Export:** High-precision stereolithography mesh format (`*.stl`).

#### B. Slicing & Additive Manufacturing (Ultimaker Cura)
- **Material:** Generic Polylactic Acid (PLA).
- **Layer Height:** $0.1\text{ mm}$ (Fine Profile) for ultra-smooth joint mating surfaces and reduced plastic-on-plastic friction.
- **Print Speed:** $60\text{ mm/s}$ (Travel Speed: $120\text{ mm/s}$).
- **Infill Architecture:** High-density cubic/gyroid infill with reinforced wall count ($3\text{ walls}$) to resist lateral bending moments under tensile loads.
- **G-Code Customization:** Tailored start and end routines for consistent bed adhesion.

#### C. Hardware & Instrumentation
- 3D Printer (FFF/FDM).
- PLA Filament spool.
- Vernier caliper and steel metric rule for sub-millimeter displacement tracking.
- Low-friction hinge axis pins ($\varnothing = 4\text{ mm}$).
- Precision calibrated slotted weights ($0.00\text{ kg} - 1.15\text{ kg}$).
- High-elasticity linear steel coil spring and latex rubber band elastic element.

---

### 4. Technological Development Phases

```text
Phase 1: Conceptual Literature Review & Kinematic Analysis
Phase 2: SolidWorks Parametric CAD Modeling & STL Export
Phase 3: Ultimaker Cura Toolpath Optimization & FDM 3D Printing
Phase 4: Mechanical Assembly, Pin Tolerancing, and Stand Erection
Phase 5: Laboratory Calibration, Slotted Mass Loading & Measurement Recording
Phase 6: Mathematical Regression Analysis (Desmos / Python) & Spring Constant Extraction
Phase 7: Sim-to-Real Virtual Twin Development in Godot Engine 4
Phase 8: Classroom Demonstration, Panel Review & Final Defense
```

---

### 5. Evaluation Criteria & Assessment Rubric

- **Part Quality & Dimensional Accuracy:** High mechanical stiffness, minimal structural deflection, clean hole tolerances.
- **Experimental Rig Rigor:** Proper static equilibrium isolation, repeatable displacement measurements.
- **Mathematical Analysis:** Accurate derivation of self-weight terms, linear regression slope analysis, and quantification of non-linear elastic regimes.
- **Educational Impact:** Ability to clearly communicate physics principles to peers through interactive demonstrations.
