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
OBJECTS = $(SOURCES:.c=.o)

# SWIG 相關設定
SWIG = swig
SWIG_FLAGS = -python
SWIG_OBJECTS = $(SWIG_WRAPPER:.c=.o)

# 目標文件
CTYPE_TARGET = example_ctype.so
SWIG_TARGET = _example.so
PYTHON_MODULE = example.py

# 默認目標：構建所有內容
all: $(CTYPE_TARGET) $(SWIG_TARGET)

# C 類型目標的構建規則
$(CTYPE_TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^

# SWIG 包裝器生成
$(SWIG_WRAPPER): $(SWIG_INTERFACE)
	$(SWIG) $(SWIG_FLAGS) $<

# SWIG 目標的構建規則
$(SWIG_TARGET): $(SWIG_WRAPPER) $(OBJECTS)
	$(CC) $(CFLAGS) -I$(PYTHON_INCLUDE) $(LDFLAGS) $^ -o $@

# 通用目標文件編譯規則
%.o: %.c
	$(CC) $(CFLAGS) -c $<

# 清理規則
clean:
	rm -f $(CTYPE_TARGET) $(SWIG_TARGET) $(SWIG_WRAPPER) $(PYTHON_MODULE) *.o

# 重新編譯
rebuild: clean all

# .PHONY 表示這些目標不是文件
.PHONY: all clean rebuild test ctype swig

# 額外的便利目標
ctype: $(CTYPE_TARGET)
swig: $(SWIG_TARGET)
