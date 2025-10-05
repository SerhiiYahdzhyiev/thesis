---
marp: true
theme: rose-pine-moon
class: main
---

<!-- _class: center -->

# Comparative Analysis of Energy Measurement Interfaces in AMD CPUs: Ryzen SMU vs. RAPL 

*Viva Presentation for Bachelor Thesis*
**_Serhii Yahdzhyiev_**
GH&nbsp;1023645

---

# Introduction

## Background I

### Increasing demand of computational power

 - Development and broad utilization of AI-related products

 - High Performance Computing + real-time computation-heavy applications

### Icreasing Demand + Sustainability Trends =

### Need for Hi-Fi Profiling and Monitoring Tools

---

# Introduction

## Background II

### AMD vs. Intel

- notable gains for AMD in the past Decade

- historically dominant position of Intel

---

# Introduction

## Problem Statements

- AMD platforms: coexistence of vendor-specific solutions and adaptations
  of Intel mechanisms.  

- Ryzen SMU interfaces and AMD’s realization of RAPL introduces uncertainty
  in selecting appropriate tools for high-fidelity measurements.  

- RAPL, though widely adopted, differs in design and has specific limitations
  on AMD hardware.  

- The Ryzen SMU driver exposes low-level telemetry, but its practical benefits
  over RAPL remain largely unexplored.

---

# Introduction

## Research Questions

- To what extent do energy measurements obtained from the SMU PM Table and RAPL
  interfaces for different power domains show similar dynamic and temporal trends?

- What is the magnitude of errors RMSE, MAE, MAPE, and to what degree are the two
  interfaces theoretically interchangeable in practical energy measurement tasks?

- How do differences in the supported sampling rates between interfaces affect the
  temporal resolution of measurements, and what are the implications?

---

# Introduction

## Considerations

- Focus limited to software-level energy measurements

- No external power measurement device used

- Both interfaces rely on hardware counters + estimation models

---

# Related Work

## Main Groups

- Studies that validate and quantify characteristics of software-accessible counters

- Comparisons between software and external/hardware meters

- Methodical works on measurement protocols, reproducibility and energy accounting
  in HPC contexts

---

# Related Work

## Works Used

### Papers

- Dissecting the software-based measurement of CPU energy consumption:
  a comparative analysis

- Strategies to Measure Energy Consumption Using RAPL During Workflow
  Execution on Commodity Clusters

- E-Team: Practical Energy Accounting for Multi-Core Systems

---

# Related Work

## Gaps Aimed To Be Closed

- Instrumenting both sources simultaneously

- Using a robust re-sampling and overflow-aware pipeline

- Applying agreement analyses to quantify differences

---

# Methodology

## Hypothesis

- *H0* : There is no statistically significant dynamic relationship between
  SMU (PMtable) and RAPL measurements for the selected power domains

- *H1* : SMU (PM-table) and RAPL measurements for the same domains exhibit
  significant temporal correlation and similar trends.

---

# Methodology

## Setup

### Hardware

- AMD Ryzen 5 3600 (6 cores / 12 threads)

- Gigabyte A320M-H-CF

- BIOS F53 (Jan 2021)

### Software

- Arch Linux (rolling release)

- kernel 6.16.4-arch1-1

---

# Methodology

## Supporting Documentation

### Resources

- RedHat Docs

- ArchWiki

### Contributed to

- Correct identification of measurement power domains
- Reproducible platform configuration
- Selection of implementation approaches for the SMU-to-energy conversion
- Principled discussion of the limitations and security considerations

---

# Methodology

## Limitations and Considerations

- Intel’s RAPL interface imposes a hardware limitation on energy counter updates,
  restricting effective resolution to around 1 kHz, regardless of read frequency

- Ryzen SMU driver reportedly exhibits a similar ~1 ms refresh rate cap 

- Ryzen SMU driver employed is not officially released by AMD; it is a
  community-maintained, reverse-engineered implementation.

---

# Methodology

## Measurements Framework (EMA)

### Benefits and Features

- In-code integration

- Plug-in-based extensibility

- Reliability

- Familiarity and openness

---

# Methodology

## Measurements Framework (EMA)

![center w:700px](assets/emahl.svg)

---

# Methodology

## EMA / Regions API

![center w:800px](assets/ema_region_api.svg)

---

# Methodology

## EMA / Overflow Handling

![center w:1200px](assets/ema_overflow.svg)

---

# Methodology

## EMA / Ryzen Plug-in

### Practical considerations:

- The integration method corresponds to a rectangular approximation, simple and
  deterministic, but can miss short high-power spikes

- For RAPL/MSR measurements EMA’s overflow handling utilities are applied to
  handle counter wraparound; for Ryzen plug-in readings the handling behavior is
  disabled due to limitations

---

# Methodology

## Benchmarking

### Power Domains

- Package

- Core

---

# Methodology

## Benchmarking

### Workload Patterns

  - A short steady high computational load region.

  - A long steady high computational load region.

  - A short region with burst (spiked) computational load.

  - A long region with burst (spiked) computational load.

  - A short idle load region (sleep).

---

# Findings & Conclusions

## Main Hypothesis

- **Correlation**: Pearson coefficients are close to zero in all cases indicating
  absence of linear correlation between readings

- **Error Metrics**: Absolute error metrics are large across all regions. MAE and RMSE
  frequently reach 1016−1017 µJ, and MAPE in most cases exceed several orders of
  magnitude

- **Bland–Altman Plots**: Mean differences are far from zero with very wide limits of
  agreement, highlighting a systematic bias and considerable dispersion between
  two measurement sources

---

# Findings & Conclusions

## Per-Core Measurements

![center w:1200px](assets/core_sharing.svg)

---

# Findings & Conclusions

## Sampling Rate Limits I

![center w:700px](assets/psampling_1.svg)

---

# Findings & Conclusions

## Sampling Rate Limits II

![center w:700px](assets/psampling_2.svg)

---

# Findings & Conclusions

## Future Work / Improved Methodology Concept

![center w:1200](assets/ryzend.svg)

---

<!-- _class: center -->

# Thank you for your time!

---

<!-- _class: center -->

# Questions ?
