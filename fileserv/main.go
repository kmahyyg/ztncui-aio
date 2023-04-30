package main

import (
	"log"
	"net/http"
)

func main() {
	var fs http.FileSystem = http.Dir("/opt/key-networks/ztncui/etc/httpfs")
	var fsHandler = http.FileServer(fs)
	log.Fatal(http.ListenAndServe(":3180", fsHandler))
}
