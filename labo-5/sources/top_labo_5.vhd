---------------------------------------------------------------------------------------------------
--
-- top_labo_5.vhd
--
-- v. 1.0 Pierre Langlois 2022-03-17
--
-- Digilent Basys 3 Artix-7 FPGA Trainer Board
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;
use work.all;

entity top_labo_5 is
    port (
        clk  : in  std_logic;                      -- l'horloge de la carte � 100 MHz
        sw   : in  std_logic_vector(15 downto 0);  -- les 16 commutateurs
        led  : out std_logic_vector(15 downto 0);  -- les 16 LED
        seg  : out std_logic_vector(7 downto 0);   -- les cathodes partag�es des quatre symboles � 7 segments + point
        an   : out std_logic_vector(3 downto 0);   -- les anodes des quatre symboles � 7 segments + point
        btnC : in  std_logic;                      -- bouton du centre
        btnU : in  std_logic;                      -- bouton du haut
        btnL : in  std_logic;                      -- bouton de gauche
        btnR : in  std_logic;                      -- bouton de droite
        btnD : in  std_logic;                      -- bouton du bas
        RsRx : in  std_logic;                      -- interface USB-RS-232 r�ception
        RsTx : out std_logic                       -- interface USB-RS-232 transmission
        -- UART_TXD_IN : in std_logic;                -- pour carte Nexys A7 100T, patte C4, r�ception RS232 (du point du vue du FPGA), voir le manuel de l'utilisateur
        -- UART_RXD_OUT : out std_logic               -- pour carte Nexys A7 100T, patte D4, transmission RS232 (du point du vue du FPGA), voir le manuel de l'utilisateur
    );
end;

architecture arch of top_labo_5 is

    -- signal RsRx, RsTx : std_logic;  -- signaux internes quand on utilise la Nexys A7, qui a une nomenclature diff�rente pour les ports UART

    signal reset : std_logic;
    signal clk_1_MHz : std_logic;

    signal symboles : quatre_symboles;

    signal btnC_stable, btnU_stable, btnL_stable, btnR_stable, btnD_stable : std_logic;
    signal NC1, NC2, NC3, NC4, NC5 : std_logic;    -- pour fils Non Connect�s

    signal go_tx : std_logic;

    signal le_caractere : character;
    signal valide : std_logic;

    signal givenNumber : unsigned(15 downto 0);
    signal squareNumber : unsigned(7 downto 0);

    signal squareNumber_affichage : unsigned(15 downto 0);

    signal A0, B0, A, B, A_affichage, B_affichage : unsigned(7 downto 0);

    signal go_processeur, processeur_fini : std_logic;

begin

    -- pairage des ports UART pour la carte Nexy A7 seulement
    -- commenter ces lignes pour la carte Basys 3
    -- RsRx         <= UART_TXD_IN;
    -- UART_RXD_OUT <= RsTx;

    -- g�n�ration des horloges du circuit � partir de l'horloge � 100 MHz de la carte
    gen_horloge_1_MHz : entity generateur_horloge_precis(arch) generic map (100e6, 1e6) port map (clk, clk_1_MHz);
--    gen_horloge_2_Hz  : entity generateur_horloge_precis(arch) generic map (100e6,   2) port map (clk, clk_2_Hz);

    -- stabilisation et synchronisation des boutons avec l'horloge du circuit, on suppose une dur�e de rebond de 5 ms
    -- on prend une horloge de r�f�rence de 1 MHz pour avoir une impulsion qui dure 1 microseconde
    lebtnC : entity monopulseur(arch) generic map ('1', '1', integer(1e6 * 0.005), 1) port map (clk_1_MHz, btnC, btnC_stable, NC1);
    reset <= btnC_stable;

    interface : entity interface_utilisateur(arch)
		generic map (100e6, 9600)
		port map (reset, clk, RsRx, squareNumber, processeur_fini, RsTx, givenNumber, go_processeur);


    ---processeur : entity pgfc3(arch)
      ---  generic map (8)
      ---  port map (reset, clk, A0, B0, go_processeur, A, B, processeur_fini);

    processeur : entity racine_carree(newton)
        generic map (givenNumber'length, squareNumber'length, 10)
        port map (reset, clk, givenNumber, go_processeur, squareNumber, processeur_fini);
		
	squareNumber_affichage <= resize(squareNumber, givenNumber'length);

     process(all)
    begin
	    led(0) <= processeur_fini;
	    led(1) <= go_processeur;
		
        if sw(0) = '1' then
             -- afficher le nombre dont on veut la racine, en format hexad�cimal sur 16 bits = 4 chiffres
            symboles(3) <= hex_to_7seg(givenNumber(15 downto 12));
            symboles(2) <= hex_to_7seg(givenNumber(11 downto 8));
            symboles(1) <= hex_to_7seg(givenNumber(7 downto 4));
            symboles(0) <= hex_to_7seg(givenNumber(3 downto 0));
        else
            --  afficher la racine en format hexad�cimal sur 8 bits = 2 chiffres
            symboles(3) <= hex_to_7seg(to_unsigned(0, 4));
            symboles(2) <= hex_to_7seg(to_unsigned(0, 4));
            symboles(1) <= hex_to_7seg(squareNumber(7 downto 4));
            symboles(0) <= hex_to_7seg(squareNumber(3 downto 0));
        end if;
    end process;


    -- circuit pour s�rialiser l'acc�s � l'affichage
    -- l'affichage contient quatre symboles chacun compos� de sept segments et d'un point
    process(all)
    variable clkCount : unsigned(19 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            clkCount := clkCount + 1;
        end if;
        case clkCount(clkCount'left downto clkCount'left - 1) is     -- L'horloge de 100 MHz est ramen�e � environ 100 Hz en la divisant par 2^19
            when   "00" => an <= "1110"; seg <= symboles(0);         -- Effectivement on prend les deux bits les plus significatifs d'un compteur de 20 bits.
            when   "01" => an <= "1101"; seg <= symboles(1);
            when   "10" => an <= "1011"; seg <= symboles(2);
            when others => an <= "0111"; seg <= symboles(3);
        end case;
    end process;

end arch;
