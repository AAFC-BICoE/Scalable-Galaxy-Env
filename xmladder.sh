xmlstarlet ed \
  --subnode /job_conf/handlers --type elem -n handler \
  --subnode '/job_conf/handlers/handler[last()]' --type attr -n id -v $1 \
  --subnode '/job_conf/handlers/handler[last()]' --type attr -n tags -v handlers \
  $2 >| $3

