package main

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"
)

func WriteLogFile(logpath string) {
	filepath := fmt.Sprintf("%s/%v.log", logpath, time.Now().Unix())
	f, err := os.OpenFile(filepath, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		log.Fatalf("error opening file: %v", err)
	}
	defer f.Close()
	levels := []string{"Error", "Critical", "Warn", "Debug", "Success"}
	s1 := rand.NewSource(time.Now().UnixNano())
	r1 := rand.New(s1)

	log.SetOutput(f)
	hostname, _ := os.Hostname()
	for i := 0; i < 20; i++ {
		log.Printf("%s %s This is a test log entry %v\n", hostname, levels[r1.Intn(len(levels))], i)
	}

}

func main() {
	var logpath = "log"
	if os.Getenv("LOGPATH") != "" {
		logpath = os.Getenv("LOGPATH")
	}
	log.Println("log app started")
	if _, err := os.Stat(logpath); os.IsNotExist(err) {
		if err := os.MkdirAll(logpath, os.ModePerm); err != nil {
			log.Printf("Error: creating folder %v\n", err)
		}
	}
	counter := 0
	for {
		log.Printf("Writing log to file %v", counter)
		WriteLogFile(logpath)
		time.Sleep(5 * time.Second)
	}

}
