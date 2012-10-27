package main

import "fmt"
import "encoding/json"

func main() {
    //b := []byte(`{"id":"kugsdfkgdsfdf","payload":"jgefygkwajhefluygaweflugyaef"}`)
    var msg string
    fmt.Scanf("%s", &msg)
    b := []byte(msg)
    var f interface{}
    json.Unmarshal(b, &f)
    fmt.Println(f)
}