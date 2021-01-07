#! /bin/bash

merge() {
    find -type f -name 'FATIADOR*' | sort > lista_FATIADOR
    sed -e 's/^/file /' -i lista_FATIADOR
    ffmpeg -safe 0 -f concat -i lista_FATIADOR -c copy _$nomeArq -y
    rm lista_FATIADOR
    exit
}

CONTADOR=0
FILE=$( zenity --file-selection --title="Selecione um arquivo de vídeo" )
nomeArq=$( basename $FILE )
shopt -s extglob

case $? in
         0)
                DURACAO_VIDEO=$( ffmpeg -i "$FILE" 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,// );;
         1)
                echo "Nenhum arquivo selecionado.";
                exit 1;;
        -1)
                echo "Erro inesperado";
                exit 1;;
esac


if [ -z "$DURACAO_VIDEO" ]; then
      echo "Arquivo inválido"
      exit 1
else
  while [ 1 ]; do
      inicio=$( zenity --entry --title="Início" \
        --text="Início do corte (formato 00:00 ou 00:00:00)\n'm' une os cortes, 'd' exclui os cortes gerados" )
      if [ -z "$inicio" ]; then
         exit 1
      elif [ $inicio = 'm' ]; then
          merge
      elif [ $inicio = 'd' ]; then
          rm +(FATIADOR)*.$nomeArq
      else 
          fim=$( zenity --entry --title="Fim" --text="Fim do corte em segundos:" )
          ffmpeg -ss "$inicio" -i "$FILE" -to "$fim" -c copy FATIADOR$CONTADOR.$nomeArq -y
          CONTADOR=$(($CONTADOR+1))
      fi
  done

fi


