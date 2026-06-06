#docker run --rm -e RAILS_ENV=production -e SECRET_KEY_BASE=2242555804fff6e93f99a01048c2a7f8d4c782b351aff514fed1794a31e95e9bcefa5c3615d8c4fcb773e0482dd425eea4e7775256fc8568f44c812fd9da774e -e DB_HOST=localhost -e DB_USERNAME=koala_admin -e DB_PASSWORD=woofwoof koala:latest bundle exec rails db:prepare db:seed

docker run --rm --add-host=host.docker.internal:host-gateway -e RAILS_ENV=production -e DB_HOST=host.docker.internal -e DB_PORT=5432 -e DB_USERNAME=koala_admin -e DB_PASSWORD=woofwoof -e SECRET_KEY_BASE=2242555804fff6e93f99a01048c2a7f8d4c782b351aff514fed1794a31e95e9bcefa5c3615d8c4fcb773e0482dd425eea4e7775256fc8568f44c812fd9da774e koala:latest bundle exec rails db:prepare db:seed

# wombat@wombat04:2064>sh ./wombat4_prep.sh
# Created database 'mellow_koala_production'
# Created Mellow Heeler — ingest token: accdd1e9a7233640f7549b40d7ba729877abea59e366ae732cbc6603923a1813
# Created Mellow Hyena-ADSB — ingest token: c67161cd861b626946e83b7acbdd81b5fe080678316542c70cca6694e094938c
# Created Mellow Hyena-UAT — ingest token: 5711a15af9eca0f72121dc9a4117c4f80f6289c6e2b5bf704ba2d55046bf405b
# Created Mellow Mastodon — ingest token: c0098a0a091ba51a28978de1d677554feac5bd84329876c0b16529ecbb118071
# Created Mellow Manatee — ingest token: a44ca538b4a391f73a883bd32f127482f64314d3edb8294363c6e4c893ca7af0
# Updated Mellow Heeler (token unchanged)
# Updated Mellow Hyena-ADSB (token unchanged)
# Updated Mellow Hyena-UAT (token unchanged)
# Updated Mellow Mastodon (token unchanged)
# Updated Mellow Manatee (token unchanged)
#
docker run -d --name koala --restart unless-stopped -p 3000:3000 --add-host=host.docker.internal:host-gateway -e RAILS_ENV=production -e SECRET_KEY_BASE=2242555804fff6e93f99a01048c2a7f8d4c782b351aff514fed1794a31e95e9bcefa5c3615d8c4fcb773e0482dd425eea4e7775256fc8568f44c812fd9da774e -e DB_HOST=host.docker.internal -e DB_USERNAME=koala_admin -e DB_PASSWORD=woofwoof koala:latest

