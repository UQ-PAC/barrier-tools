AUTOMAKE_OPTIONS = subdir-objects
# enable PIC for x64 support
AM_CXXFLAGS = -fPIC -DPIC

lib_LIBRARIES = libtrace.a
pkginclude_HEADERS = trace.container.hpp frame_arch.h frame.piqi.pb.h config.h

PIQI = piqi
PROTOC = protoc
PIQIFILE = ../../piqi/frame.piqi
PIQIFILEC = frame.piqi.pb.cc frame.piqi.pb.h

$(PIQIFILEC): frame.piqi.proto
	$(PROTOC) $< --cpp_out=.

frame.piqi.proto: $(PIQIFILE)
	$(PIQI) to-proto $< -o $@

BUILT_SOURCES = $(PIQIFILEC)

libtrace_a_SOURCES = $(PIQIFILEC) trace.container.cpp
utils_LDADD = libtrace.a -lprotobuf -lpthread

bin_PROGRAMS = readtrace copytrace slicetrace
slicetrace_SOURCES = slicetrace.cpp
slicetrace_LDADD = $(utils_LDADD)
readtrace_SOURCES = readtrace.cpp
readtrace_LDADD = $(utils_LDADD)
copytrace_SOURCES = copytrace.cpp
copytrace_LDADD = $(utils_LDADD)
