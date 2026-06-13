if [ ! -z "$CONTAINER_ID" ]; then
    docker exec -it "$CONTAINER_ID" bash
else
    echo No container ID known. For this command to work, set \`database.allow_containerization\` to \`true\`, and define the environment variable \`WAX_CNTAINERIZED_DB=1\`
fi
