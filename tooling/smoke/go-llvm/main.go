package main

import (
	"fmt"
	"os"

	llvm "tinygo.org/x/go-llvm"
)

func main() {
	context := llvm.NewContext()
	defer context.Dispose()
	module := context.NewModule("ts2bin-toolchain-smoke")
	defer module.Dispose()
	builder := context.NewBuilder()
	defer builder.Dispose()

	i32 := context.Int32Type()
	addType := llvm.FunctionType(i32, []llvm.Type{i32, i32}, false)
	add := llvm.AddFunction(module, "ts2bin_smoke_add", addType)
	entry := context.AddBasicBlock(add, "entry")
	builder.SetInsertPointAtEnd(entry)
	builder.CreateRet(builder.CreateAdd(add.Param(0), add.Param(1), "sum"))

	if err := llvm.VerifyModule(module, llvm.ReturnStatusAction); err != nil {
		fmt.Fprintf(os.Stderr, "LLVM verifier failed: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("go-llvm %s verifier passed\n", llvm.Version)
}
