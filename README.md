# What?

This is a revised version of the [DelftX-Database](https://github.com/AngusGLChen/DelftX-Database) setup. While the number of steps are similar, they are now less ambiguous. `main.py` has been updated to Python 3 where necessary.

A docker container is now used for the MySQL server to avoid a painful manual installation. The edx log data is loaded into the database. This requires extensive preprocessing. This is only necessary once. Once the container is running any MySQL client (command-line or GUI can access it). 

# Open Issue

The database resides within a Docker container, it is as of now not persistent, i.e. once the Docker container shuts down (terminal closes, machine shuts down, ...), the whole process has to be repeated. Alternatively, once the whole process is finished, an SQL dump can be made and persisted to local disk.
Should be fixed soon.


# Step-by-step
0. Install [Docker](https://www.docker.com/).

1. Open a terminal and navigate to an empty directory (lets call it `$MY_DIR$`) in which you want to store your data. Execute the following five commands (copy to terminal & Enter for each command) to create sub-directories and an empty file. Note that `COURSE1` can be replaced by any identifier of your choice, e.g. `FP101x`:
```
mkdir course_log
mkdir course_log/Daily_Logs
mkdir course_log/COURSE1/
mkdir course_log/COURSE1/metadata
touch course_log/translated_course_list
```

2. Populate the `course_log/Daily_Logs` sub-directory by copying the daily edx log files (`delftx-edx-events-201X-MM-DD.log.gz`) into it. Keep the files in the \*.gz format.

3. Populate the `course_log/COURSE1/metadata` sub-directory by copying all course metadata files into it (those files contain grades, user overviews, etc.). If this data is downloaded as a single zip or tar from surfsara, it needs to be uncompressed manually. 

4. Make sure the terminal's current directory is still `$MY_DIR$` (this can be checked with the command `pwd`) . Now download the Python scripts that preprocesses the daily log files:
```
curl -o main.py https://raw.githubusercontent.com/AngusGLChen/DelftX-Database/master/main.py
```

5. The `main.py` script writes data to the database, so it needs a bit of information about how to access the DB. The current directory is still `$MY_DIR$`. The lines below create a file `config` with the necessary information:
```
touch config
echo "[mysqld]" >> config
echo "user = root" >> config
echo "password = 123456" >> config
echo "host = 127.0.0.1" >> config
echo "database = DelftX" >> config
echo "[data]" >> config
echo "path = $(pwd)/course_log/" >> config
echo "remove_filtered_logs = 0" >> config
```

6. Lets download the database schema. We are still on the terminal with current directory `$MY_DIR$` and create a new sub-directory into which we download the schema:
```
mkdir docker-container
curl -o docker-container/DelftX.sql https://raw.githubusercontent.com/AngusGLChen/DelftX-Database/master/DelftX.sql
```

7. It is time for the database. We use Docker, so all we need to do is create a Docker file and fill in a few details. Still at `$MY_DIR$` in the terminal:
```
touch docker-container/Dockerfile
echo "FROM mysql" >> docker-container/Dockerfile
echo "ENV MYSQL_USER root_user" >> docker-container/Dockerfile 
echo "ENV MYSQL_ROOT_PASSWORD 123456" >> docker-container/Dockerfile
echo "ENV MYSQL_DATABASE DelftX" >> docker-container/Dockerfile
echo "ADD DelftX.sql /docker-entrypoint-initdb.d/" >> docker-container/Dockerfile
echo 'CMD ["mysqld"]' >> docker-container/Dockerfile
```

8. Still in `$MY_DIR$`, build the Docker image:
```
docker build docker-container/
```
The last line of output this command produces looks something like this: `Successfully built bf3a4f120a22`. We need this hash identifier for the next step.

9. Now start the database (replacing the hash identifier here with the actual one you observed):
```
docker run -p 127.0.0.1:3306:3306 bf3a4f120a22
```
Keep this terminal open - if it is closed the container (database server) ceases to exist. That's it, the MySQL server is now running. We can test this quickly by connecting the MySQL client from our local machine to the container, like so (here `mysql` is the MySQL client binary) from a **new** terminal tab/window:
```
./mysql -h localhost -P 3306 --protocol=tcp -u root -p
```

10. Lets try to run the preprocessing script from a **new** terminal tab/window:
```
python main.py config
```
If it throws an error `No module mysql`, run `pip install mysql-connector-python-rf` to install [Connector/Python](https://dev.mysql.com/doc/connector-python/en/connector-python-installation.html). 

It will take quite a while to run, "All finished" indicates that all went well.

11. Lets see if the database has any content ...
```
./mysql -h localhost -P 3306 --protocol=tcp -u root -p
```
You will be asked for the password, it is `123456` as stated in the configuration file. The interactive `mysql` shell can be tested like this for instance:
```
show databases;
use DelftX;
show tables;
select * from submissions;
```


