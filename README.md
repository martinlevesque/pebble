# pebble - cloud-sqlite

Simple crystal-lang based dockerized web server allowing to store and read into a local sqlite database.

## Build

        shards install
        crystal build server.cr --release

## Boot

        DATABASE_PATH=./mydb.db ./server -p 3000

## Mutate the database

        curl -H "Content-Type: application/json" \
            --request POST \
            --data '{"type":"mutation","query":"INSERT INTO contacts(age) VALUES(25)"}' \
          http://localhost:3000/query