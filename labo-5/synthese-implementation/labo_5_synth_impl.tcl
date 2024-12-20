# -------------------------------------------------------------------------------
# labo_5_synth_impl.tcl
#
# Il faut d'abord ouvrir une fenêtre d'invite de commande (dans Windows : cmd).
# Ensuite naviguer dans le bon répertoire, par exemple user\docs\poly\inf3500\labo-5\synthese-implementation
#
# On peut lancer Vivado avec la commande "C:\Xilinx\Vivado\2021.1\bin\vivado -mode tcl"
# (** doit correspondre à la version de Vivado que vous avez installée **)
#
# Ensuite, on peut copier-coller les commandes du présent fichier une à une ou en groupe,
# selon les besoins afin d'avancer dans le flot selon son rythme et les erreurs qui peuvent survenir.
#
# Il faut commenter et dé-commenter les lignes qui correspondent à votre carte.
#
# -------------------------------------------------------------------------------

# fermer tout design présentement actif
close_design

# lecture des fichiers sources VHDL
remove_files [get_files]
read_vhdl -vhdl2008 ../sources/utilitaires_inf3500_pkg.vhd
read_vhdl -vhdl2008 ../sources/generateur_horloge_precis.vhd
read_vhdl -vhdl2008 ../sources/monopulseur.vhd
read_vhdl -vhdl2008 ../sources/interface_utilisateur.vhd
read_vhdl -vhdl2008 ../sources/PGFC3.vhd
read_vhdl -vhdl2008 ../sources/uart_tx_char.vhd
read_vhdl -vhdl2008 ../sources/uart_tx_message.vhd
read_vhdl -vhdl2008 ../sources/uart_rx_char.vhd
read_vhdl -vhdl2008 ../sources/top_labo_5.vhd

# lecture du fichier de contraintes xdc; choisir la ligne qui correspond à votre carte
read_xdc ../xdc/basys_3_top.xdc
#read_xdc ../xdc/nexys_a7_50t_top.xdc
#read_xdc ../xdc/nexys_a7_100t_top.xdc

# synthèse - choisir la ligne qui correspond à votre carte
synth_design -top top_labo_5 -part xc7a35tcpg236-1 -assert
#synth_design -top top_labo_5 -part xC7a50TCSG324 -assert
#synth_design -top top_labo_5 -part xC7a100TCSG324 -assert

# implémentation (placement et routage)
place_design
route_design

# génération du fichier de configuration
write_bitstream -force top_labo_5.bit

# programmation du FPGA
open_hw_manager
connect_hw_server
get_hw_targets
open_hw_target

# choisir les trois lignes qui correspondent à votre carte
current_hw_device [get_hw_devices xc7a35t_0]
set_property PROGRAM.FILE {top_labo_5.bit} [get_hw_devices xc7a35t_0]
program_hw_devices [get_hw_devices xc7a35t_0]

#current_hw_device [get_hw_devices xc7a50t_0]
#set_property PROGRAM.FILE {top_labo_5.bit} [get_hw_devices xc7a50t_0]
#program_hw_devices [get_hw_devices xc7a50t_0]

#current_hw_device [get_hw_devices xc7a100t_0]
#set_property PROGRAM.FILE {top_labo_5.bit} [get_hw_devices xc7a100t_0]
#program_hw_devices [get_hw_devices xc7a100t_0]
