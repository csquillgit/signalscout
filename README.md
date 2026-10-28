# SignalScout 📡

**Cell Tower & Dead-Zone Finder with Offline Directional Booster Aiming Needle**  
*Powered by OpenCellID and FCC Antenna Structure Registration (ASR) data.*

---

## 🎯 Overview

**SignalScout** is an offline-first tactical navigation and RF scouting utility designed for backcountry camping, rural overlanding, off-grid cabins, and directional cellular booster aiming (weBoost, SureCall, Cel-Fi, Poynting).

When you are deep in the woods or down in a granite mountain notch with 0–1 bars of intermittent service, searching online for tower maps is impossible. SignalScout pre-loads verified cell tower structures, tower heights (AGL), ground elevations (AMSL), and frequency bands completely offline, providing a high-precision directional HUD needle that points straight to the nearest carrier antenna.

---

## ⚡ Key Features

* **Tactical Azimuth HUD Needle**:
  * Real-time directional needle computing relative angle `(targetBearing - deviceHeading)`.
  * **Aim Locked Reticle**: Glows high-contrast emerald (`#10B981`) with `AIM LOCKED ±5°` when phone/antenna is pointed right at the tower mast.
  * Digital azimuth readout, cardinal headings, and distance in miles/km.
  * Estimated Free-Space Path Loss (FSPL) and signal strength in dBm.

* **FCC ASR & OpenCellID Offline Directory**:
  * Bundled database of cell towers with authentic FCC Antenna Structure Registration numbers, structure types (Monopole, Guyed Lattice, Alpine Summit, Camouflaged Monopine), and operator licenses.
  * Filter by carrier: **Verizon**, **AT&T**, **T-Mobile**, or All Carriers.
  * Proximity sorting with instant one-tap target lock.
  * Add custom rural repeaters or private field towers.

* **Offline Dead-Zone Breadcrumb Logger**:
  * One-tap **"Mark Dead Spot Here"** at current GPS coordinates.
  * Log 0-bar blackouts vs 1-bar SOS-only zones, carrier networks, and terrain notes (e.g., canyon shadows, dense hardwood attenuation).
  * Persisted locally with zero cell connectivity.

* **Tactical Booster Field Guide**:
  * Step-by-step instructions for aiming high-gain Yagi and LPDA directional antennas.
  * Explains amplifier Automatic Gain Control (AGC) settling time (30–45s).
  * RF band breakdown: Low-Band penetration (600–700 MHz: B12/B13/B14/B71) vs high-speed Mid-Band (1.9–2.1 GHz: B2/B4/B66).
  * Antenna oscillation prevention rules (separation distances).

* **Observer Simulation Presets**:
  * Switch effortlessly between live GPS and backcountry testing presets (White Mountains NH, Crawford Notch, Cape Cod Dunes, Adirondack High Peaks, Shenandoah Ridge, Worcester MA).

---

## 🎨 Tactical Dark Design System

SignalScout follows Chuck's signature tactical utility aesthetic:
* **Base Surface**: Midnight tactical slate (`#0B0F19`)
* **Card Containers**: Navy slate (`#1E293B`) with `#334155` perimeter borders
* **High-Contrast Neon Roles**:
  * 🟢 **Emerald (`#10B981`)**: Aim Locked / Safe / Strong Signal
  * 🔵 **Electric Cyan (`#38BDF8`)**: Primary Telemetry / Bearing / GPS Active
  * 🔴 **Crimson (`#EF4444`)**: Dead-Zone Blackout / Verizon / Delete
  * 🟡 **Amber (`#F59E0B`)**: Advisory caution / Simulation active
* **UX Best Practices**:
  * Clean 3-dots popup menus (`PopupMenuButton`) and long-press actions to prevent horizontal button crowding.
  * Balanced 3-column metric card with dedicated vertical dividers.
  * Bottom scroll clearance padding for navigation bars.

---

## 🚀 Quick Start (Mac & iOS / Android)

Clone the repository:
```bash
git clone https://github.com/csquillgit/signalscout.git
cd signalscout
```

Install dependencies:
```bash
flutter pub get
```

Run on your iPhone or connected device:
```bash
flutter run --release
```

---

## 📄 License
MIT License. Created by csquillgit.
