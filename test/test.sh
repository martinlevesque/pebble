pwd

DATABASE_PATH=./test/test.db ./server &
sleep 5

apk add -u curl

result=$(curl -H "Content-Type: application/json" \
        --request POST \
        --data '{"type":"mutation","query":"INSERT INTO contacts(age) VALUES(25)"}' \
      http://localhost:3000/query)

echo "$result" | grep "@rows_affected=1"

curl -H "Content-Type: application/json" \
        --request POST \
        --data '{"type":"mutation","query":"INSERT INTO contacts(age) VALUES(18)"}' \
      http://localhost:3000/query

result=$(curl -H "Content-Type: application/json" \
        --request POST \
        --data '{"type":"read","query":"SELECT * FROM contacts order by age DESC"}' \
      http://localhost:3000/query)

echo "result" | grep "[{\"age\":25},{\"age\":18}]"