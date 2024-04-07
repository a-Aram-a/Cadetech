#!/bin/bash

source .env

action=$1

drupal_install_drush() {
    echo "installing drush"
    docker exec drupal sh -c "composer require drush/drush"
}

drupal_install() {
    echo "installing drupal site"
    docker exec drupal sh -c \
    "drush site-install \
        --locale=$DRUPAL_LOCALE \
        --db-url=$DRUPAL_DB_URL \
        --account-name=$DRUPAL_ADMIN_NAME \
        --account-pass=$DRUPAL_ADMIN_PASS \
        --account-mail=$DRUPAL_ADMIN_MAIL \
        --site-mail=$DRUPAL_SITE_MAIL \
        --site-name=$DRUPAL_SITE_NAME \
    --yes"
}

drupal_clear_cache() {
    echo "clearing drupal cache"
    docker exec drupal sh -c "drush cache-rebuild --yes"
}

db_import() {
    echo "importing database"
    docker cp ./db/exported_db.sql db:/
    docker exec db sh -c "mysql -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME < exported_db.sql"
}

db_export() {
    echo "exporting database"
    docker exec db sh -c "mysqldump -u $DB_ROOT_USER -p$DB_ROOT_PASSWORD $DB_NAME > exported_db.sql"
    docker cp db:/exported_db.sql ./db
}

if [[ $action = "dev-up" ]]; then
    echo "starting docker-compose"
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
    drupal_install_drush

    if ! [ -f drupal_inited ]; then
        echo "initializing drupal site"
        drupal_install
        if [ -f ./db/exported_db.sql ]; then
            db_import
        fi
        drupal_clear_cache
        touch drupal_inited
    fi

fi

if [[ $action = "prod-up" ]]; then
    echo "starting docker-compose"
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
    drupal_install_drush

    if ! [ -f drupal_inited ]; then
        echo "initializing drupal site"
        drupal_install
        db_import
        drupal_clear_cache
        touch drupal_inited
    fi

fi

if [[ $action = "down" ]]; then
    echo "stopping docker compose"
    docker-compose down
fi

if [[ $action = "drupal-install" ]]; then
    drupal_install
fi

if [[ $action = "drupal-install-drush" ]]; then
    drupal_install_drush
fi

if [[ $action = "drupal-clear-cache" ]]; then
    drupal_clear_cache
fi

if [[ $action = "db-export" ]]; then
    db_export
fi

if [[ $action = "db-import" ]]; then
    db_import
fi