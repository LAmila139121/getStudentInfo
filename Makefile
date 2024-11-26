# 編譯器和標誌
CC = gcc
PYTHON_VERSION = 3.9
PYTHON_INCLUDE = /usr/include/python$(PYTHON_VERSION)
CFLAGS = -fPIC -Wall
LDFLAGS = -shared

# 源文件和目標文件
SWIG_INTERFACE = example.i
SWIG_WRAPPER = example_wrap.c
SOURCES = getStudentInfo.c AVLTree.c
TARGET = _example.so
PYTHON_MODULE = example.py

# SWIG 命令
SWIG = swig
SWIG_FLAGS = -python

# 所有目標文件
OBJECTS = $(SOURCES:.c=.o) $(SWIG_WRAPPER:.c=.o)

# 默認目標
all: $(TARGET)

# 生成 SWIG 包裝器
$(SWIG_WRAPPER): $(SWIG_INTERFACE)
	$(SWIG) $(SWIG_FLAGS) $<

# 編譯目標共享庫
$(TARGET): $(SWIG_WRAPPER) $(SOURCES)
	$(CC) $(CFLAGS) -I$(PYTHON_INCLUDE) $(LDFLAGS) $^ -o $@

# 清理生成的文件
clean:
	rm -f $(TARGET) $(SWIG_WRAPPER) $(PYTHON_MODULE) *.o

# 重新編譯一切
rebuild: clean all

# 測試目標（可選）
test: all
	python3 test.py

# .PHONY 表示這些目標不是文件
.PHONY: all clean rebuild test
