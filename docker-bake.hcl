group "default" {
	targets = ["alpine-latest", "alpine-3.12"]
}
target "common" {
	platforms = ["linux/amd64"]
	args = {"GOCRONVER" = "v0.0.10"}
}
target "alpine" {
	inherits = ["common"]
	dockerfile = "Dockerfile-alpine"
}
target "alpine-latest" {
	inherits = ["alpine"]
	args = {"BASETAG" = "3.13"}
	tags = [
		"akhilrs/files-backup:alpine",
		"akhilrs/files-backup:3.13-alpine"
	]
}
target "alpine-3.12" {
	inherits = ["alpine"]
	args = {"BASETAG" = "3.12"}
	tags = [
		"akhilrs/files-backup:3.12-alpine"
	]
}
