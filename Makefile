INCLUDES := -I/usr/local/x86_64/include -I/usr/x86_64/include
CXX := g++
CXXFLAGS := -fPIC -Wall -Wextra -O2 -std=c++17 -g $(INCLUDES)
LDFLAGS := -shared
RM := rm -f
SRCS := gl.cpp vk.cpp log.cpp hash.cpp
OBJS := $(SRCS:.cpp=.o)
DEPS := $(SRCS:.cpp=.d)

.PHONY: all clean install
all: deshade.so

deshade.so: $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

$(DEPS):%.d:%.cpp
	$(CXX) $(CXXFLAGS) -MM $< > $@

include $(DEPS)

clean:
	-$(RM) deshade.so $(OBJS) $(DEPS)

install:
	install -Dm755 deshade.so /usr/lib/x86_64-linux-gnu/deshade.so
	install -Dm644 deshade.json /usr/share/vulkan/explicit_layer.d/deshade.json
