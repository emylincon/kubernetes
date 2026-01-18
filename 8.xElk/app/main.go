package main

import (
	"fmt"
	"math/rand"
	"time"
)

func getIntRange(start, stop int, r1 *rand.Rand) int {

	return r1.Intn(stop-start+1) + start

}

func getFloatRange(start, stop int, r1 *rand.Rand) float64 {

	return r1.Float64() + float64(getIntRange(start, stop, r1))

}

func main() {
	s1 := rand.NewSource(time.Now().UnixNano())
    r1 := rand.New(s1)
	fmt.Print(r1.Intn(100), "\n")
	fmt.Println(r1.Float64()*3)
	fmt.Println(r1.Float64()*2)

	for i := 0; i < 10; i++ {
		fmt.Println(getIntRange(5, 10, r1), getFloatRange(5, 10, r1))
	}
	
}
