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
#
13 JUN
#
docker run --rm koala:latest bundle exec rails secret
4ab71d3ddb6931592ebe93cff389ce8daddac920ca8d97c640885fbb83bb700854c97d8b5e854ed3a3676abf8def3aad196ad531cd66eaf4b79a9c249b89e518
#
docker run --rm --add-host=host.docker.internal:host-gateway -e RAILS_ENV=production -e DB_HOST=host.docker.internal -e DB_PORT=5432 -e DB_USERNAME=koala_admin -e DB_PASSWORD=woofwoof -e SECRET_KEY_BASE=4ab71d3ddb6931592ebe93cff389ce8daddac920ca8d97c640885fbb83bb700854c97d8b5e854ed3a3676abf8def3aad196ad531cd66eaf4b79a9c249b89e518 koala:latest bundle exec rails runner 'map={"mellow-heeler"=>"MELLOW_HEELER_TOKEN","mellow-hyena-adsb"=>"MELLOW_HYENA_ADSB_TOKEN","mellow-hyena-uat"=>"MELLOW_HYENA_UAT_TOKEN","mellow-mastodon"=>"MELLOW_MASTODON_TOKEN","mellow-manatee"=>"MELLOW_MANATEE_TOKEN"}; Collector.order(:collector_id).each{|c| t=SecureRandom.hex(32); c.ingest_token=t; c.save!; key=map[c.collector_id] || "#{c.collector_id.upcase.tr("-","_")}_TOKEN"; puts "#{key}=#{t}"}'
MELLOW_HEELER_TOKEN=e208a67687c8f8ae759edaafa50542ae55a8911d6a46aef4880e8c4f1808cadd
MELLOW_HYENA_ADSB_TOKEN=e204350366693cc1adc4fded39a4c39c2ca938821107158ee7e06612187fad0b
MELLOW_HYENA_UAT_TOKEN=24d4b2e92e87662532597f062fdda41bccbe8cfe2fc5982df3e12a2ad031d925
MELLOW_MANATEE_TOKEN=c386ca9bcac8be3b8b1d721dbc20eb737f494b8e0a5d986d82098cad4dcb88ef
MELLOW_MASTODON_TOKEN=afeaf8b26ef00ceddf3b39f42d6e2b5b45d2c14eaa41bbbdfdea694fb4820260
#
docker run -d --name koala --restart unless-stopped -p 3000:3000 --add-host=host.docker.internal:host-gateway -e RAILS_ENV=production -e SECRET_KEY_BASE=4ab71d3ddb6931592ebe93cff389ce8daddac920ca8d97c640885fbb83bb700854c97d8b5e854ed3a3676abf8def3aad196ad531cd66eaf4b79a9c249b89e518 -e DB_HOST=host.docker.internal -e DB_USERNAME=koala_admin -e DB_PASSWORD=woofwoof koala:latest
#
