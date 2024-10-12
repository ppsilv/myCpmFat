# myCpmFat Board Z80Boad2022RA
Based on z80-playground

Este projeto está sendo recuperado, pois os códigos e o diretório onde eu estava
desenvolvento se perderam em um ssd que deu problema.

Trouxe os diretórios schematic e pictures que estavam no projeto BSX, pois o esquema
é da placa z80-playground.

Nessa data 2024-09-18 estou tentando verificar se os arquivos desse projeto são os
mais recentes, pois no projeto BSX tem commits meus recentes e não sei qual dos 2
projetos é o que eu estava considerando ser o final.


O projeto cpmfat foi usado somente como fonte de informações para esse projeto
O projeto bsx foi gravado uma vez na placa e ele até mostra log no display de cristal
liquido como mostra a foto z80_002.jpg.


2024-09-18:
            A placa etá totalmente funcional com hardware atual.
            Baudrate 38400.
            O pendrive está funcional e eu entrei em todos os drivers de A ~ P.
            Eu não gravei nessa data a eprom, usei o programa que já estava nela.
            Em verdade eu nem sei mais como gravar a eprom ou seja qual binario
            vai nela. onde por os outros binários vou pesquisar como fiz pois não
            tem instrução atualmente.

            Agora a placa está completamente testada.
            Gravei a versão cpm20240918.hex compilada hoje

            Para compilar é preciso ter:

            pasmo cross compiler, to compile cpm e applicações cpm
            sjasmplus cross compiler, to compile cpm.asm o programa monitor

            No linux para gravar baixar o https://github.com/ppsilv/minipro
            Para compilar: make
            Para instalar: copie o programa minipro para /usr/bin

            Para gravar na eprom apesar de extensão hex o programa é um binário.
            minipro  -p AT29C512 -s -w cpm.hex

            ********************************************************************

            Nessa data falta refazer o esquema elétrico.
