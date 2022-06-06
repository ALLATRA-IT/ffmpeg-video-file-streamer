#!/bin/bash

FILE_TO_PLAY=$1
YOUTUBE_LINK=$2

MAX_RETRIES=1000
DELAY_SECONDS=25

# Запуск стрима файла с помощью ffmpeg
function startFfmpeg {
  # $1 - file to stream
  # $2 - start_from time
  local file_to_play=$1
  if [ -z "$2" ]
  then
    # Не передали время, начинаем с начала
    local start_from=0
  else
    # Пришло время с которого начинать стрим файла
    local start_from=$2
  fi

  # Без перекодирования
  ffmpeg \
    -re \
    -ss $start_from \
    -i $file_to_play \
    -c copy \
    -f flv $YOUTUBE_LINK

# Ниже ничего не добавлять, чтобы в результатах был результат работы именно ffmpeg'а
}

# Берем первый файл из плейлиста
date=$(date +%m-%d-%Y-%T)

echo '[LOG INFO] -' $date 'Current file to play: "'$FILE_TO_PLAY'"'

######## Структура файла status.txt ########
#Retries: 0
#Seconds: 60
############################################

# Считываем с какой секунды начать (при ошибке там будет не 0)
seconds_from_status=$(awk 'FNR == 2 {print $2}' "./status.txt")

# Считываем кол-во попыток (при ошибке будет не 0)
retries_from_status=$(awk 'FNR == 1 {print $2}' "./status.txt")

# Засекаем время работы
start_time=$SECONDS
startFfmpeg $FILE_TO_PLAY $seconds_from_status
# После этой команды ничего не надо добавлять, нам надо обработать результат

# Проверяем результат функции (0 - всё ок)
if [ $? -eq 0 ]
then
  # Успешно завершился стрим файла
  # Выходим
  exit 0
else
  # Скрипт завершился с ошибкой

  # Отмечаем время остановки с учётом прошлого запуска и за вычетом задержки
  duration=$(( SECONDS - start_time + seconds_from_status - DELAY_SECONDS ))

  # Чтобы не уйти в отрицательные значения при ошибке в самом начале воспроизведения
  if [ $duration -lt 0 ]
  then
    duration=0
  fi

  # Инкрементируем счетчик запусков
  count=$((retries_from_status + 1))

  # Проверяем число запусков, если меньше 10, пробуем ещё раз
  if [ $count -lt $MAX_RETRIES ]
  then
    # Обновляем статус, пишем в файл
    echo -e "Retries: $count \nSeconds: $duration \n" > "./status.txt"

    # Рекурсивно вызываем самого себя
    ./$0 $1 $2

  else
    echo '[LOG INFO] - Retries limit of $count exceeded!'
    exit 0
  fi

fi