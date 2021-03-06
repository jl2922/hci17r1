# Default options.
CXX := mpic++
CXX_WARNING_OPTIONS := -Wall -Wextra -Wno-expansion-to-defined -Wno-int-in-bool-context
CXX_MALLOC_OPTIONS := -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free
CXX_ARCH_TUNE := -march='native' -mtune='native' # May have to recompile for different CPUs.
CXXFLAGS := -std=c++17 -O3 -fopenmp $(CXX_ARCH_TUNE) $(CXX_WARNING_OPTIONS) $(CXX_MALLOC_OPTIONS)
LDLIBS := -pthread -lboost_mpi -lboost_serialization -lprotobuf -lpthread
SRC_DIR := src
OBJ_DIR := build
EXE := hci.x
TEST_EXE := $(OBJ_DIR)/hci_test.x

# Libraries.
UNAME := $(shell uname)
HOSTNAME := $(shell hostname)
ifeq ($(UNAME), Linux)
	TOOLS_DIR := $(HOME)/tools
	EIGEN_DIR := $(TOOLS_DIR)/eigen
	BOOST_DIR := $(TOOLS_DIR)/boost
	PROTOBUF_DIR := $(TOOLS_DIR)/protobuf
	GPERFTOOLS_DIR := $(TOOLS_DIR)/gperftools
	CXXFLAGS := $(CXXFLAGS) -I $(EIGEN_DIR)/include -I $(BOOST_DIR)/include -I $(PROTOBUF_DIR)/include
	LDLIBS := -L $(BOOST_DIR)/lib -L $(GPERFTOOLS_DIR)/lib -L $(PROTOBUF_DIR)/lib $(LDLIBS) -ltcmalloc
endif
ifeq ($(UNAME), Darwin)
	LDLIBS := $(LDLIBS) -ltcmalloc_minimal
endif

# Load local Makefile.config if exists.
LOCAL_MAKEFILE := local.mk
ifneq ($(wildcard $(LOCAL_MAKEFILE)),)
	include $(LOCAL_MAKEFILE)
endif

# Sources and intermediate objects.
PROTO_SRC := $(SRC_DIR)/data.proto
PROTO_COMPILED := $(SRC_DIR)/data.pb.h $(SRC_DIR)/data.pb.cc
MAIN := $(SRC_DIR)/main.cc
SRCS := $(shell find $(SRC_DIR) \
		! -name "main.cc" ! -name "*_test.cc" -name "*.cc")
HEADERS := $(shell find $(SRC_DIR) -name "*.h")
TESTS := $(shell find $(SRC_DIR) -name "*_test.cc")
OBJS := $(SRCS:$(SRC_DIR)/%.cc=$(OBJ_DIR)/%.o)
TEST_OBJS := $(TESTS:$(SRC_DIR)/%.cc=$(OBJ_DIR)/%.o)

.PHONY: all build test clean

all: $(PROTO_COMPILED)
	make build -j

build: $(EXE)

clean:
	rm -rf $(OBJ_DIR)
	rm -f ./$(EXE)
	rm -f ./$(TEST_EXE)

$(PROTO_COMPILED): $(PROTO_SRC)
	protoc -I=$(SRC_DIR) --cpp_out=$(SRC_DIR) $(PROTO_SRC)

$(EXE): $(OBJS) $(MAIN) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(MAIN) $(OBJS) -o $(EXE) $(LDLIBS)

$(OBJS): $(OBJ_DIR)/%.o: $(SRC_DIR)/%.cc $(HEADERS)
	mkdir -p $(@D) && $(CXX) $(CXXFLAGS) -c $< -o $@