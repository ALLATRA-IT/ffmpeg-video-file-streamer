# ffmpeg-video-file-streamer

_Скрипт предназначен для rtmp трансляции видео файла с помощью [ffmpeg](https://ffmpeg.org/download.html)._

🔥 **Киллер-фича** заключается в восстановлении трансляции с того момента на котором оборвался поток 
по каким либо причинам (проблемы сети, сбои у принимающей rtmp поток стороны и тд):

```Error writing trailer of rtmp://a.rtmp.youtube.com/live2/...: Broken pipe```


### 👨‍💻 Пример использования:

`./ffmpeg-streamer.sh /home/forum-7th-2022.mp4 rtmp://a.rtmp.youtube.com/live2/xxxx-qqqq-yyyy-jjjjj-kkkk
`
