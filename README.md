## Dockerfile
Dockerfile для сборки Docker-образа, содержащий 
следующие актуальные версии специализированных программ и библиотек:

- samtools + htslib + libdeflate; 
- bcftools;
- vcftools.

Команда для сборки Docker-образа
- docker build -t test .

Запуск Docker-образа в интерактивном режиме

- docker run -it test bash
