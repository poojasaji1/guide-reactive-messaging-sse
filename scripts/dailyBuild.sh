#!/bin/bash
while getopts t:d:b:u: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    b) BUILD="${OPTARG}" ;;
    u) DOCKER_USERNAME="${OPTARG}" ;;
    *) echo "Invalid option" ;;
    esac
done

echo "Testing daily OpenLiberty image"

sed -i "\#</containerRunOpts>#a<install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install>" system/pom.xml
sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#a<configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install></configuration>" bff/pom.xml frontend/pom.xml
cat system/pom.xml bff/pom.xml frontend/pom.xml

if [[ "$DOCKER_USERNAME" != "" ]]; then
    sed -i "s;FROM icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi;FROM $DOCKER_USERNAME/olguides:$BUILD;g" system/Dockerfile bff/Dockerfile frontend/Dockerfile
    sed -i "s;RUN features.sh;#RUN features.sh;g" system/Dockerfile bff/Dockerfile frontend/Dockerfile
    cat system/Dockerfile bff/Dockerfile frontend/Dockerfile
fi

../scripts/testApp.sh
