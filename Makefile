# To use another compiler, such clang++, set the CXX variable
# CXX=clang++
# variables used to generate a source snapshot of the GIT repo
COMMIT=$(shell git log --pretty=format:'%H' -n 1)
SHORT_COMMIT=$(shell git log --pretty=format:'%h' -n 1)
CXXFLAGS := -fPIC -pipe -std=c++11 -g -O2 -Iapi
CXXFLAGS += -fno-omit-frame-pointer -fvisibility=hidden -g -pedantic
CXXFLAGS += -Wall -Werror -Wno-sign-compare -Wno-unused-but-set-variable -Wno-unused-variable
TARGET=pict
TARGET_LIB_A=libpict.a
TARGET_LIB_SO=libpict.so
TEST_OUTPUT = test/rel.log test/rel.log.failures test/dbg.log
TEST_OUTPUT += test/.stdout test/.stderr
OBJS = $(OBJS_API) $(OBJS_CLI)
OBJS_API = api/combination.o api/deriver.o api/exclusion.o
OBJS_API += api/model.o api/parameter.o api/pictapi.o
OBJS_API += api/task.o api/worklist.o
OBJS_CLI = cli/ccommon.o cli/cmdline.o
OBJS_CLI += cli/common.o cli/cparser.o cli/ctokenizer.o cli/gcd.o
OBJS_CLI += cli/gcdexcl.o cli/gcdmodel.o cli/model.o cli/mparser.o
OBJS_CLI += cli/pict.o cli/strings.o

all: $(TARGET) $(TARGET_LIB_A) $(TARGET_LIB_SO)

$(TARGET): $(OBJS)
	$(CXX) $^ -o $@

$(TARGET_LIB_A): $(OBJS)
	$(AR) rvs $@ $^

$(TARGET_LIB_SO): $(OBJS)
	$(CXX) -fPIC -shared $^ -o $(TARGET_LIB_SO)

test: $(TARGET) test/test.pl
	cd test; perl test.pl ../$(TARGET) rel.log

clean:
	$(RM) $(TARGET) $(TARGET_LIB_A) $(TARGET_LIB_SO) $(TEST_OUTPUT) $(OBJS)

source: clean
	git archive --prefix="pict-$(COMMIT)/" -o "pict-$(SHORT_COMMIT).tar.gz" $(COMMIT)

.PHONY: all test clean source
