###########################################################################
# Script: vis.gmtec_2-2.sh - Adquirindo e formatando imagens satelites    #
#                            fornecido pelo DSA/CPTEC/INPE.               #
# Versao: 2.2 (Experimental/Beta)                                         #
# Data: Segunda-feira, 19 de Setembro de 2011 - 21:34 (UTC).              #
# Desenvolvedor: Julio Xavier Valle - julioxavier@me.com                  #
# Direitos Autorais: O presente script encontra-se aberto para copia, sem #
#                    a necessidade de referenciar o autor em produtos de- #
#                    rivados do presente codigo.                          #
#                                                                         #
#                    * O autor nao se responsabiliza por quaisquer conse- #
#                      quencias da utilizacao do presente script, e/ou do #
#                      conjunto de scripts GMTEC.                         #
#                                                                         #
# Informacoes Gerais: Tradicionalmente nessa parte seria feito uma expli- #
#                     cacao do funciomaneto do script, porem a partir da  #
#                     presente versao sera disponbilizado um manual em    #
#                     formato PDF onde explicacoes gerais poderao ser     #
#                     encotradas. Em caso de duvida, favor entrar em con- #
#                     tato.                                               #
#                                                                         #
#                     Atencao: Esse script foi escrito para funcionar     #
#                              junto com outros scripts.                  #
###########################################################################

###########################################################################
#                           Alteracoes                                    #
###########################################################################
#2011/12/27: alterado UTC-3 para UTC e "Fonte: INPE /CPTEC / DSA" para    #
#"Fonte: CPTEC/INPE" por Marcio/Julio e mudado possicao                   #
###########################################################################

###########################################################################
#                   Parte I - Configuracoes de Parametros                 #
###########################################################################
servidor="http://satelite.cptec.inpe.br/repositoriogoes/goes16/goes16_web/ams_ret_ch07_baixa" #alterado em 15/02/2018
#servidor="http://satelite.cptec.inpe.br/repositorio1/goes16/goes16_web/ams_ret_ch1_baixa" #alterado 20/9/17
dataAnoMesDiaHora=`date -u -d '-30 Minutes' +%Y%m%d%H`  # Primeira parte da data. "AnoMesDiaHora".
dataMinutos15=`date -u -d '-30 Minutes' +%M`  # Minutos em multiplos de quinze <= 45.
dataAno=`date -u -d '-30 Minutes' +%Y`
dataMes=`date -u -d '-30 Minutes' +%m`
cmdBaixar="wget -t 0 -c" #curl -O  # Comando utilizado para baixar as imagens.
nImagens_m1="7"  # Numero de imagens desejadas subtraido em um. Ie. se nImagens_m1 =7 -> 7 + 1 = 8".
extensao=".jpg"  # Extensao do arquivo.
id="S11635376_" #alterado em 20/09/2017
corte="+1600+1230"

# A seguir a sequencia de IFs ajusta o valor de 'dataMinutos15' para ser: 00 ou 30.
if [ "$dataMinutos15" -lt 15 ];
then 
   dataMinutos15=00
else if [ "$dataMinutos15" -lt 45 ];
   then
      dataMinutos15=30
   else
      dataMinutos15=00
   fi
fi

nomeImg=$id$dataAnoMesDiaHora$dataMinutos15$extensao  # Nome da imagem possivelmente disponivel para baixar.

# Parametros iniciados com 'cab' serao usados como cabecalhos na animacao final.
cabData=`date -u -d '-30 Minutes' +%d/%m/%Y`  # O Mimutes pode ser alterado substituindo a diferença do UTC (por exemplo, -3h (180min)).
cabHora=`date -u -d '-30 Minutes' +%H`


###########################################################################
#                      Parte II - Coletando Imagens                       #
###########################################################################
# Baixando a primeira imagem. E poseteriormente verificando se o tamanho do arquivos condiz com o ta-
# manho normalmente encontrado nas imagens baixadas.
if [ ! -e $nomeImg ]
then
  echo "$cmdBaixar $servidor/$dataAno/$dataMes/$nomeImg"  # Se tudo ocorrer bem, a imagem sera baixada nesse momento.
  tamanhoImg=$(ls -la $nomeImg | awk '{print $5}')
  convert $nomeImg -crop 300x300$corte +repage $nomeImg  # Formantando imagem.
  convert $nomeImg -stroke black -strokewidth 12 -draw "line 0,6 1370,6" $nomeImg
  convert $nomeImg -font ../ttf/FreeMono.ttf -pointsize 12 -stroke white -fill white -draw "text 2, 9 'GOAMet/UFES         $cabData *UTC* $cabHora:$dataMinutos15'" $nomeImg
	#coloco sombras
  convert -page +4+4 $nomeImg -alpha set \
          \( +clone -background navy -shadow 60x4+4+4 \) +swap \
		-background white -layers merge +repage $nomeImg 2> /dev/null;

  tamanhoImg=$(ls -la $nomeImg | awk '{print $5}')
  if [ $tamanhoImg -le 1189 ]
  then 
    rm $nomeImg
  else 
    cp $nomeImg /var/lib/wview/img/img-arquivo
  fi
fi

  # A partir daqui sera feito um laco (loop) para baixar as outras imagens caso seja necessario.
for (( i = 1 ; i <= $nImagens_m1 ; i++ ))
  do
    dataAnoMesDiaHora=`date -u -d '-'$(( $i * 30 ))' Minutes' +%Y%m%d%H`
    dataMinutos15=`date -u -d '-'$(( $i * 30 ))' Minutes' +%M`

   # A seguir a sequencia de IFs ajusta o valor de 'dataMinutos15' para ser: 00 ou 30.
   if [ "$dataMinutos15" -lt 15 ];
  then 
      dataMinutos15=00
   else if [ "$dataMinutos15" -lt 45 ];
      then
         dataMinutos15=30
      else
         dataMinutos15=00
      fi
   fi

  nomeImg=$id$dataAnoMesDiaHora$dataMinutos15$extensao
  
  if [ ! -e $nomeImg ]
    then
      ano=`date -u -d '-'$(( $i * 30 ))' Minutes' +%Y`
      mes=`date -u -d '-'$(( $i * 30 ))' Minutes' +%m`
      $cmdBaixar $servidor/$dataAno/$dataMes/$nomeImg  # Se tudo ocorrer bem, a imagem sera baixada nesse momento.
      tamanhoImg=$(ls -la $nomeImg | awk '{print $5}')
      cabData=`date -u -d '-'$(( ($i * 30)))' Minutes' +%d/%m/%Y`
      cabHora=`date -u -d '-'$(( ($i * 30)))' Minutes' +%H`
      convert $nomeImg -crop 300x300$corte +repage $nomeImg  # Formantando imagem.
      convert $nomeImg -stroke black -strokewidth 12 -draw "line 0,6 1370,5" $nomeImg
      convert $nomeImg -font ../ttf/FreeMono.ttf -pointsize 12 -stroke white -fill white -draw "text 2, 9 'GOAMet/UFES         $cabData *TUC* $cabHora:$dataMinutos15'" $nomeImg
	#coloco sombras
	convert -page +4+4 $nomeImg -alpha set \
          \( +clone -background navy -shadow 60x4+4+4 \) +swap \
		-background white -layers merge +repage $nomeImg 2> /dev/null;

      tamanhoImg=$(ls -la $nomeImg | awk '{print $5}')
      if [ $tamanhoImg -le 1189 ]
      then 
      	rm $nomeImg
      else 
         cp $nomeImg /var/lib/wview/img/img-arquivo
      fi
  fi
  done

###########################################################################
#            Parte III - Escolhendo Quais Imagens Serao Necessarias       #
###########################################################################

# Nessa parte do script serao apagadas o numero de imagens "obsoletas" em funcao da quantidade escolhi-
# da de imagens ("nImagens_m1"). A tentativa sera manter o numero minimo necessario de imagens para que
# o script possa funcionar continuamente sem ter que toda hora ficar baixando imagens que ja foram bai-
# xadas anteriormente.

nImgsDir=`ls -l . | egrep -c '*.jpg'`  # Buscando o numero de imagens ja existentes no diretorio.
nImagens=$(( $nImagens_m1 + 1 ))  # Numero de imagens configurada para compor a animacao.

if [ $nImgsDir -gt $nImagens ]
  then
    for (( i = $nImgsDir ; i > $nImagens ; i-- ))  # Laco (loop) para apagar imagens antigas.
      do rm `ls -X *.jpg | head -1`  # Busca e apaga a imagem mais antiga possivel.
    done
fi
# Nesse momento teremos apenas imagens que formarao a animacao final.

# Seguencia de comandos para manter a ultima imagem por um tempo maior que as outras. 
# Criaremos algo como "imagem1.jpg imagem2.jpg ... até nImagens_m1 'pause 3000' ImagemFinal"
imagensIniciais=$(ls -X *.jpg | head -$nImagens_m1) #  Imagens Iniciais
imagemFinal=$(ls -X *.jpg | tail -1) # Última imagem

###########################################################################
#                    Parte IV - Gerando a Animacao Final                  #
###########################################################################

convert -delay 35 -loop 0 $imagensIniciais -delay 300 $imagemFinal vis.gif
gifsicle --colors 256 -O3 vis.gif -o vis.gif

# As duas linhas/comandos a seguir servem para marcar a cidade de Vitoria no mapa.
# convert vis.gif -fill none -stroke cyan -strokewidth 1 -draw "circle 230,157.5 234,157.5" vis.gif
# convert vis.gif -font ../ttf/FreeMono.ttf -fill cyan -stroke none -strokewidth 0.25 -draw "text 237,166 'Vitoria'" vis.gif
#convert vis.gif -stroke black -strokewidth 8 -draw "line 249,345 349,345" vis.gif
#convert vis.gif -font ../ttf/FreeMono.ttf -pointsize 8 -fill white -stroke none -strokewidth 0.25 -draw "text 257,348 'Fonte: CPTEC/INPE'" vis.gif

# As duas linhas/comandos a seguir servem para marcar a cidade de Vitoria no mapa.
convert vis.gif -fill none -stroke black -strokewidth 1 -draw "circle 223,172 226,176" vis.gif
convert vis.gif -font ../ttf/FreeMono.ttf -fill black -stroke none -strokewidth 0.25 -draw "text 230,175 'Vitoria'" vis.gif
convert vis.gif -stroke black -strokewidth 8 -draw "line 185,295 302,295" vis.gif
convert vis.gif -font ../ttf/FreeMono.ttf -pointsize 8 -fill white -stroke none -strokewidth 0.25 -draw "text 188,298 'Fonte: CPTEC/NOAA/GOES'" vis.gif

#otimiza o tamanho
convert vis.gif -fuzz 4% -layers Optimize vis.gif


###########################################################################
#                              Final do Script                            #
###########################################################################
