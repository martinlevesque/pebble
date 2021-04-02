for i in {1..1000}
do
    echo "cur = $i"
    curl -H "Content-Type: application/json" \
        --request POST \
        --data '{"type":"mutation","query":"INSERT INTO contacts(name, age) VALUES(\\\"test\\\", 25)"}' \
      http://localhost:3000/query &
    sleep 0.001

done