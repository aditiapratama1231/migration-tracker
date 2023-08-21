#!/usr/bin/env bash
source secret.sh

if [ -z $PSQL_DB_USER ]; then echo "PSQL_DB_USER can't be empty"; exit 1; fi
if [ -z $PSQL_DB_PASW ]; then echo "PSQL_DB_PASW can't be empty"; exit 1; fi
if [ -z $PSQL_DB_HOST ]; then echo "PSQL_DB_HOST can't be empty"; exit 1; fi
if [ -z $PSQL_DB_NAME ]; then echo "PSQL_DB_NAME can't be empty"; exit 1; fi
if [ -z $PSQL_TABLE_NAME ]; then echo "PSQL_TABLE_NAME can't be empty"; exit 1; fi
if [ -z $PSQL_DB_PORT ]; then echo "PSQL_DB_PORT can't be empty"; exit 1; fi
if [ -z $MIGRATION_DIR ]; then echo "MIGRATION_DIR can't be empty"; exit 1; fi
if [ -z $BATCH_SIZE ]; then echo "BATCH_SIZE can't be empty"; exit 1; fi
if [ -z $SLEEP_DURATION ]; then echo "SLEEP_DURATION can't be empty"; exit 1; fi

export PGPASSWORD="$PSQL_DB_PASW";
COUNT=0

for FILE_PATH in "$MIGRATION_DIR"/*.csv; do
    
    # Construct the psql \COPY command
    COPY_COMMAND="\\COPY $PSQL_TABLE_NAME FROM '$FILE_PATH' DELIMITER ',' QUOTE '\"' CSV HEADER"
    
    # Execute the psql command
    OUTPUT=$(psql -h "$PSQL_DB_HOST" -d "$PSQL_DB_NAME" -U "$PSQL_DB_USER" -c "$COPY_COMMAND" 2>&1)
    
    # Display output psql command
    if [ $? -ne 0 ]; then
        echo "Error while processing $FILE_PATH:"
        echo "Command $COPY_COMMAND"
        echo "Result $OUTPUT"
    else
        echo "Processed successfully for $FILE_PATH:"
        echo "Command $COPY_COMMAND"
        echo "Result $OUTPUT"
    fi

    # Sleep for each batch
    ((COUNT++))
    if ((COUNT % $BATCH_SIZE == 0)); then
        sleep $SLEEP_DURATION
    fi
done