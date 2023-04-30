package main

import (
	"encoding/json"
	"io"
	"log"
	"os"
	"ztnodeid/pkg/node"
)

type NodeIdentity struct {
	NodePriv string `json:"nodePriv,omitempty"`
	NodePub  string `json:"nodePub,omitempty"`
}

func main() {
	// the same as identity.public and identity.secret
	fd, err := os.OpenFile("runtime.json", os.O_RDWR|os.O_SYNC|os.O_CREATE, 0640)
	if err != nil {
		panic(err)
	}
	defer fd.Close()
	defer fd.Sync()
	log.Println("file runtime.json opened.")
	fdData, err := io.ReadAll(fd)
	if err != nil {
		panic(err)
	}
	log.Println("data read from runtime.json.")
	var runtimeZTNodeId = &NodeIdentity{}
	if len(fdData) < 10 {
		ztId := node.NewZeroTierIdentity()
		log.Println("new zt identity generated.")
		runtimeZTNodeId.NodePriv = ztId.PrivateKeyString()
		runtimeZTNodeId.NodePub = ztId.PublicKeyString()
		jData, err := json.Marshal(runtimeZTNodeId)
		if err != nil {
			panic(err)
		}
		log.Println("data marshalled to json.")
		_, err = fd.Write(jData)
		if err != nil {
			panic(err)
		}
		log.Println("generated new identity, written to file.")
		return
	} else {
		err = json.Unmarshal(fdData, runtimeZTNodeId)
		if err != nil {
			panic(err)
		}
		log.Println("read identity successfully.")
		return
	}
}
