package main

/*
#include <stdint.h>
*/
import "C"
import (
	"sync"
	"time"
	"unsafe"
	"unicode/utf16"
	md "github.com/JohannesKaufmann/html-to-markdown"
)

type cacheEntry struct {
	data      []uint16
	timestamp time.Time
	timer     *time.Timer
}

var (
	converter       *md.Converter
	mu             sync.Mutex
	resultCache    map[uint32]cacheEntry
	nextID         uint32
	timeoutDuration = 30 * time.Second
	isShuttingDown bool
)

func init() {
	converter = md.NewConverter("", true, nil)
	resultCache = make(map[uint32]cacheEntry)
}

//export Initialize
func Initialize() {
	mu.Lock()
	defer mu.Unlock()
	isShuttingDown = false
}

//export Shutdown
func Shutdown() {
	mu.Lock()
	defer mu.Unlock()
	
	isShuttingDown = true
	
	for _, entry := range resultCache {
		if entry.timer != nil {
			entry.timer.Stop()
		}
	}
	resultCache = make(map[uint32]cacheEntry)
}

//export SetTimeout
func SetTimeout(seconds C.int32_t) {
	mu.Lock()
	defer mu.Unlock()
	timeoutDuration = time.Duration(seconds) * time.Second
}

func cleanupEntry(id uint32) {
	mu.Lock()
	defer mu.Unlock()
	
	if !isShuttingDown {
		delete(resultCache, id)
	}
}

//export GetConversionSize
func GetConversionSize(htmlW *C.uint16_t) C.uint32_t {
	mu.Lock()
	defer mu.Unlock()

	if isShuttingDown {
		return 0
	}

	var utf16Slice []uint16
	ptr := unsafe.Pointer(htmlW)
	for i := 0; ; i++ {
		char := *(*uint16)(unsafe.Pointer(uintptr(ptr) + uintptr(i*2)))
		if char == 0 {
			break
		}
		utf16Slice = append(utf16Slice, char)
	}
	
	input := string(utf16.Decode(utf16Slice))
	markdown, err := converter.ConvertString(input)
	if err != nil {
		return 0
	}

	utf16Result := utf16.Encode([]rune(markdown))
	
	nextID++
	currentID := nextID

	timer := time.AfterFunc(timeoutDuration, func() {
		cleanupEntry(currentID)
	})

	resultCache[currentID] = cacheEntry{
		data:      utf16Result,
		timestamp: time.Now(),
		timer:     timer,
	}
	
	return C.uint32_t(currentID << 16 | uint32(len(utf16Result)))
}

//export GetConversionResult
func GetConversionResult(id C.uint32_t, buffer *C.uint16_t, bufferSize C.int32_t) C.int32_t {
	mu.Lock()
	defer mu.Unlock()

	if isShuttingDown {
		return -3 // DLL is shutting down
	}

	cacheID := uint32(id) >> 16
	
	entry, exists := resultCache[cacheID]
	if !exists {
		return -1 // Invalid ID or expired
	}

	if entry.timer != nil {
		entry.timer.Stop()
	}
	
	if len(entry.data)+1 > int(bufferSize) {
		return -2 // Buffer too small
	}

	for i, char := range entry.data {
		*(*uint16)(unsafe.Pointer(uintptr(unsafe.Pointer(buffer)) + uintptr(i*2))) = char
	}
	*(*uint16)(unsafe.Pointer(uintptr(unsafe.Pointer(buffer)) + uintptr(len(entry.data)*2))) = 0

	delete(resultCache, cacheID)

	return C.int32_t(len(entry.data))
}

func main() {}