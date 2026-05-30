-- ============================================================
-- traffic_light_fsm.vhd
-- Traffic light controller using a Finite State Machine (FSM)
--
-- States:
--   RED          (5 seconds)  -> RED_YELLOW
--   RED_YELLOW   (1 second)   -> GREEN
--   GREEN        (4 seconds)  -> YELLOW
--   YELLOW       (1 second)   -> RED
--
-- DE10-Lite mapping:
--   MAX10_CLK1_50  -> 50 MHz system clock
--   KEY[0]         -> Reset (active low)
--   LEDR[0]        -> RED    light
--   LEDR[1]        -> YELLOW light
--   LEDR[2]        -> GREEN  light
--
-- Author: Barbaros Nicolin
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity traffic_light_fsm is
    port (
        MAX10_CLK1_50 : in  STD_LOGIC;
        KEY           : in  STD_LOGIC_VECTOR(1 downto 0);
        LEDR          : out STD_LOGIC_VECTOR(9 downto 0)
    );
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is

    -- ── Clock divider: 50 MHz → 1 Hz ──────────────────────────
    -- CLK_DIV = 50_000_000 counts = 1 second at 50 MHz
    -- Set to 5_000_000 for simulation (1/10 speed) or 50 for testbench
    constant CLK_DIV : integer := 50_000_000;

    signal cnt_clk : integer range 0 to CLK_DIV - 1 := 0;
    signal tick    : STD_LOGIC := '0';   -- 1-second pulse

    -- ── FSM ───────────────────────────────────────────────────
    type State_t is (RED_ST, RED_YELLOW_ST, GREEN_ST, YELLOW_ST);
    signal state     : State_t := RED_ST;
    signal cnt_state : integer range 0 to 9 := 0;

    -- Duration of each state (seconds)
    constant T_RED        : integer := 5;
    constant T_RED_YELLOW : integer := 1;
    constant T_GREEN      : integer := 4;
    constant T_YELLOW     : integer := 1;

    -- Active-low reset
    signal rst_n : STD_LOGIC;

begin

    rst_n <= KEY(0);

    -- ── Clock divider process ─────────────────────────────────
    -- Generates a one-clock-wide pulse ('tick') every second
    clk_div_proc : process(MAX10_CLK1_50, rst_n)
    begin
        if rst_n = '0' then
            cnt_clk <= 0;
            tick    <= '0';
        elsif rising_edge(MAX10_CLK1_50) then
            tick <= '0';
            if cnt_clk = CLK_DIV - 1 then
                cnt_clk <= 0;
                tick    <= '1';
            else
                cnt_clk <= cnt_clk + 1;
            end if;
        end if;
    end process clk_div_proc;

    -- ── FSM: state transitions ────────────────────────────────
    fsm_proc : process(MAX10_CLK1_50, rst_n)
    begin
        if rst_n = '0' then
            state     <= RED_ST;
            cnt_state <= 0;
        elsif rising_edge(MAX10_CLK1_50) then
            if tick = '1' then
                case state is

                    when RED_ST =>
                        if cnt_state = T_RED - 1 then
                            state     <= RED_YELLOW_ST;
                            cnt_state <= 0;
                        else
                            cnt_state <= cnt_state + 1;
                        end if;

                    when RED_YELLOW_ST =>
                        if cnt_state = T_RED_YELLOW - 1 then
                            state     <= GREEN_ST;
                            cnt_state <= 0;
                        else
                            cnt_state <= cnt_state + 1;
                        end if;

                    when GREEN_ST =>
                        if cnt_state = T_GREEN - 1 then
                            state     <= YELLOW_ST;
                            cnt_state <= 0;
                        else
                            cnt_state <= cnt_state + 1;
                        end if;

                    when YELLOW_ST =>
                        if cnt_state = T_YELLOW - 1 then
                            state     <= RED_ST;
                            cnt_state <= 0;
                        else
                            cnt_state <= cnt_state + 1;
                        end if;

                end case;
            end if;
        end if;
    end process fsm_proc;

    -- ── Output logic (combinational) ──────────────────────────
    output_proc : process(state)
    begin
        -- Default: all LEDs off
        LEDR <= (others => '0');

        case state is
            when RED_ST =>
                LEDR(0) <= '1';           -- RED on

            when RED_YELLOW_ST =>
                LEDR(0) <= '1';           -- RED on
                LEDR(1) <= '1';           -- YELLOW on

            when GREEN_ST =>
                LEDR(2) <= '1';           -- GREEN on

            when YELLOW_ST =>
                LEDR(1) <= '1';           -- YELLOW on
        end case;
    end process output_proc;

end Behavioral;
