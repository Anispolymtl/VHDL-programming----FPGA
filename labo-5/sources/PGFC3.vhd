---------------------------------------------------------------------------------------------------
--
-- PGFC3.vhd
--
-- calcul du plus grand facteur commun entre deux nombres par méthode itérative
--
-- Pierre Langlois, 2022-03-16, basé sur plusieurs codes précédents
--
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pgfc3 is
    generic (
        W : integer := 8
    );
    port (
        reset, CLK   : in  STD_LOGIC;
        A0, B0       : in  unsigned(W - 1 downto 0);
        go           : in  std_logic;
        A_out, B_out : out unsigned(W - 1 downto 0);
        PGFCpret     : out std_logic
    );
end pgfc3;

architecture arch of pgfc3 is

type type_etat is (init, calculePGFC, fini);
signal etat : type_etat;
signal A, B : unsigned(W - 1 downto 0);

begin

    process(all) is
    constant delai : natural := 4; -- en 1 / secondes (10 == 0.1 s, 5 == 0.2 s, 4 == 0.25 s, etc.)
    variable compteur_delai : natural range 0 to 100e6 / delai - 1; -- pour insérer un délai entre les étapes de calcul, pour voir les étapes à l'oeil
    begin
        if reset = '1' then
            etat <= init;
        elsif rising_edge(CLK) then
            case etat is
                when init =>
                    if go = '1' then
                        A <= A0;
                        B <= B0;
                        etat <= calculePGFC;
                        compteur_delai := 100e6 / delai - 1;
                    end if;
                when calculePGFC =>
                    if compteur_delai = 0 then
                        compteur_delai := 100e6 / delai - 1;
                        if (A = B) then
                            etat <= fini;
                        else
                            if (A > B) then
                                A <= A - B;
                            else
                                B <= B - A;
                            end if;
                        end if;
                    else
                        compteur_delai := compteur_delai - 1;
                    end if;
                when fini =>
                    etat <= init;
                when others =>
                    etat <= init;
            end case;
        end if;
    end process;

    PGFCpret <= '1' when etat = fini else '0';
    A_out <= A;
    B_out <= B;

end arch;
