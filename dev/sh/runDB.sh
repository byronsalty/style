export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=style_dev
export CONTAINER=db_style

docker stop $CONTAINER

docker run -it --rm --name $CONTAINER -p 5632:5432 \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$POSTGRES_DB \
  -v $(pwd)/dev/data:/var/lib/postgresql/data \
  postgres
