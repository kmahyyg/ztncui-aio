package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	var fs http.FileSystem = http.Dir("/opt/key-networks/ztncui/etc/httpfs")
	var fsHandler = http.FileServer(fs)
	var listenGlobal = os.Getenv("PLANET_RETR_PUBLIC")
	if listenGlobal != "" {
		log.Fatal(http.ListenAndServe(":3180", fsHandler))
	} else {
		log.Fatal(http.ListenAndServe("127.0.0.1:3180", fsHandler))
	}
}
