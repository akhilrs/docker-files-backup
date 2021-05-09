#!/bin/sh

set -e

display_help() {
    echo "Usage: $0 [options...]" >&2
    echo
    echo "   -p, --platforms     set target platform for build."
    echo "   -h, --help          show this help text"
    echo
    exit 1
}


for i in "$@"
do
case $i in
    -p=*|--platforms=*)
    PLATFORMS="${i#*=}"
    shift
    ;;
    -h | --help)
    display_help
    exit 0
    ;;
    *)
    display_help
    exit 0
    # unknown option
    ;;
esac
done

DOCKER_BAKE_FILE=${1:-"docker-bake.hcl"}
TAGS=${TAGS:-"3.13 3.12"}
GOCRONVER=${GOCRONVER:-"v0.0.10"}
PLATFORMS=${PLATFORMS:-"linux/amd64 linux/arm64"}
IMAGE_NAME=${IMAGE_NAME:-"akhilrs/files-backup"}


cd "$(dirname "$0")"

MAIN_TAG=${TAGS%%" "*} # First tag
TAGS_EXTRA=${TAGS#*" "} # Rest of tags
P="\"$(echo $PLATFORMS | sed 's/ /", "/g')\""

T="\"alpine-latest\", \"$(echo alpine-$TAGS_EXTRA | sed 's/ /", "alpine-/g')\""

cat > "../$DOCKER_BAKE_FILE" << EOF
group "default" {
	targets = [$T]
}
target "common" {
	platforms = [$P]
	args = {"GOCRONVER" = "$GOCRONVER"}
}
target "alpine" {
	inherits = ["common"]
	dockerfile = "Dockerfile-alpine"
}
target "alpine-latest" {
	inherits = ["alpine"]
	args = {"BASETAG" = "$MAIN_TAG"}
	tags = [
		"$IMAGE_NAME:alpine",
		"$IMAGE_NAME:$MAIN_TAG-alpine"
	]
}
EOF

for TAG in $TAGS_EXTRA; do cat >> "../$DOCKER_BAKE_FILE" << EOF
target "alpine-$TAG" {
	inherits = ["alpine"]
	args = {"BASETAG" = "$TAG"}
	tags = [
		"$IMAGE_NAME:$TAG-alpine"
	]
}
EOF
done