# traffic_light_fsm

Traffic light controller implemented as a Finite State Machine (FSM) in VHDL, synthesized on the Intel DE10-Lite.

## State diagram

```
RED (5s) → RED-YELLOW (1s) → GREEN (4s) → YELLOW (1s) → RED ...
```

## Board mapping (DE10-Lite)

| Signal | Pin |
|--------|-----|
| Clock 50 MHz | MAX10_CLK1_50 |
| Reset (active low) | KEY[0] |
| RED light | LEDR[0] |
| YELLOW light | LEDR[1] |
| GREEN light | LEDR[2] |

## Synthesis

Open `traffic_light_fsm.qpf` in **Quartus Prime**, compile, and program the DE10-Lite.

> To change state durations, edit the constants `T_RED`, `T_GREEN`, `T_YELLOW` in the VHDL file.
