Dependencies
1. Docker
2. Gatling 


### Running Gatling tests locally

1. Start docker daemon 
2. Run below to build your local docker container from where dockerfile exists.  If 'hwfgatling' image exists in your local you can skip this step

    ```
    > docker build -f performance-tests/Dockerfile -t hwfgatling:local . 

    ```


3. From the performance-tests directory, run gatling scripts against docker image
   ```
   > docker run --rm \
  -e APP_URL=https://example.com \
  -e APP_EMAIL=example@test.com \
  -e APP_PASSWORD=example \
  -v `pwd`/src/test/resources:/opt/gatling/conf \
  -v `pwd`/src/test/scala/simulations:/opt/gatling/user-files/simulations \
  -v `pwd`/results:/opt/gatling/results \
  -v `pwd`/data:/opt/gatling/data \
  hwfgatling:local -s simulations.StaffAppPerformance
   ```

Note: if you are on os x you will need to include the following in the above command `--add-host localhost:<IP>`

    
4. Reports folder will be created once tests successfully ran


### Running Gatling tests using maven without container

1. Get latest from this repo.

2. Execute below command to run test

    ```
      > mvn gatling:execute

      or for single simulation execution

      > mvn gatling:execute -Dgatling.simulationClass=StaffAppPerformance

    ```