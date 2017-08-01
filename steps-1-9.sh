# step 1
mkdir course_log
mkdir course_log/Daily_Logs
mkdir course_log/COURSE1/
mkdir course_log/COURSE1/metadata
touch course_log/translated_course_list

# step 4
mkdir translation
curl -o main.py https://raw.githubusercontent.com/chauff/edx-analysis/master/main.py
curl -o translation/ForumMode.py https://raw.githubusercontent.com/chauff/edx-analysis/master/translation/ForumMode.py
curl -o translation/Functions.py https://raw.githubusercontent.com/chauff/edx-analysis/master/translation/Functions.py
curl -o translation/LearnerMode.py https://raw.githubusercontent.com/chauff/edx-analysis/master/translation/LearnerMode.py
curl -o translation/QuizMode.py https://raw.githubusercontent.com/chauff/edx-analysis/master/translation/QuizMode.py
curl -o translation/SurveyMode.py https://raw.githubusercontent.com/chauff/edx-analysis/master/translation/SurveyMode.py
curl -o translation/VideoMode.py https://raw.githubusercontent.com/chauff/edx-analysis/master/translation/VideoMode.py

# step 5
touch config
echo "[mysqld]" >> config
echo "user = root" >> config
echo "password = 123456" >> config
echo "host = 127.0.0.1" >> config
echo "database = DelftX" >> config
echo "[data]" >> config
echo "path = $(pwd)/course_log/" >> config
echo "remove_filtered_logs = 0" >> config

# step 6
mkdir docker-container
curl -o docker-container/DelftX.sql https://raw.githubusercontent.com/AngusGLChen/DelftX-Database/master/DelftX.sql

# step 7
touch docker-container/Dockerfile
echo "FROM mysql" >> docker-container/Dockerfile
echo "ENV MYSQL_USER root_user" >> docker-container/Dockerfile 
echo "ENV MYSQL_ROOT_PASSWORD 123456" >> docker-container/Dockerfile
echo "ENV MYSQL_DATABASE DelftX" >> docker-container/Dockerfile
echo "ADD DelftX.sql /docker-entrypoint-initdb.d/" >> docker-container/Dockerfile
echo 'CMD ["mysqld"]' >> docker-container/Dockerfile

# step 8
docker build docker-container/ > tmpout

# step 9
docker run -p 127.0.0.1:3306:3306 $(tail -n1 tmpout|awk '{print $3}')

# clean up
rm tmpout

echo "Steps 1 through 9 are complete with the exception of steps 2 & 3 (data upload)."
echo "Once the data upload is complete move to step 10 in a new terminal."
