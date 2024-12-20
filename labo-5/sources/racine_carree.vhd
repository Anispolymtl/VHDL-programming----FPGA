---------------------------------------------------------------------------------------------------
-- 
-- racine_carree.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-25 laboratoire #4 INF3500 - code de base
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity racine_carree is
    generic (
        N : positive := 16;                     -- nombre de bits de A
        M : positive := 8;                      -- nombre de bits de X
        kmax : positive := 10                   -- nombre d'itérations à faire
    );
    port (
        reset, clk : in std_logic;
        A : in unsigned(N - 1 downto 0);        -- le nombre dont on cherche la racine carrée
        go : in std_logic;                      -- commande pour débuter les calculs
        X : out unsigned(M - 1 downto 0);       -- la racine carrée de A, telle que X * X = A
        fini : out std_logic                    -- '1' quand les calculs sont terminés ==> la valeur de X est stable et correcte
    );
end racine_carree;

architecture newton of racine_carree is
    
    constant W_frac : integer := 14;               -- pour le module de division, nombre de bits pour exprimer les réciproques
    
    type etat_type is (attente, calculs);
    signal etat : etat_type := attente;
    
--- votre code ici
    signal A_int : unsigned(N - 1 downto 0);     
    signal xk : unsigned(M - 1 downto 0);
	signal div_0 : std_logic;    
    signal division : unsigned(N + W_frac - 1 downto 0);
	

begin
    
    diviseur : entity division_par_reciproque(arch)
       generic map (N, M, W_frac)
       port map (A_int, xk, division, div_0); 
		
	--diviseur_goldschmidt : entity work.division_goldschmidt
      --  generic map (
          --  W_num => N,
          --  W_denom => M,  
          --  W_frac => W_frac, 
          --  Iterations => 5 
       -- )

    -- votre code ici
    
    process(all)
    variable k : natural;
    begin   
        if (reset = '1') then
            etat <= attente; 
			xk <= (others => '0'); 
            A_int <= (others => '0'); 
            fini <= '0';  
            k := 0;  
        elsif (rising_edge(clk)) then
            case etat is 
                when attente => 
                    if (go = '1') then
                        k := 0;
                        A_int <= A;
                        if (to_integer(A_int) > 16384) then      
                            xk <= to_unsigned(255, xk'length);
                        elsif (to_integer(A_int) > 4096) then   
                            xk <= to_unsigned(128, xk'length);
                        elsif (to_integer(A_int) > 1024) then   
                            xk <= to_unsigned(64, xk'length);
                        elsif (to_integer(A_int) > 256) then    
                            xk <= to_unsigned(32, xk'length);
                        elsif (to_integer(A_int) > 64) then 
                            xk <= to_unsigned(16, xk'length); 
                        else 
                            xk <= to_unsigned(8, xk'length);
                        end if;
                        etat <= calculs;
						fini <= '0';
                    end if;
                when calculs =>
                    fini <= '0';
                    if (to_integer(A_int) = 0) then 
                        xk <= to_unsigned(0, xk'length);
                    else                                                                                                        
						xk <= resize( ( (division(N + W_frac - 1 downto W_frac) + resize(xk, A_int'length)) sra 1), M);
                    end if;
    
                    k := k + 1;
                    if (k = kmax) then
                        etat <= attente;
                    end if;
            end case;
        end if;
        X <= xk;
        if (etat = attente) then
            fini <= '1';
        else 
            fini <= '0';
        end if;
    end process;
end newton;
