# Makefile for analysis of fastbus data in SBS test stand
#
# Use this if compiling online code (ET system)
# User must have LD_LIBRARY_PATH = $CODA/$OSNAME/lib:$LD_LIBRARY_PATH
# export ONLINE = 1

# Use this if profiling (note: it slows down the code)
# export PROFILE = 1

# To make standalone, independent of root CINT macros
export STANDALONE = 1
MACHINE := $(shell uname -s)
ARCH	:= linux
ifeq ($(MACHINE),Darwin)
	ARCH := macosx
endif
   
ifdef OLDROOT
   ROOTLIBS      = -L$(ROOTSYS)/lib -lNew -lBase -lCint -lClib -lCont -lFunc \
                    -lGraf -lGraf3d -lHist -lHtml -lMatrix -lMeta -lMinuit -lNet \
                    -lPhysics -lPostscript -lProof -lRint -lTree -lUnix -lZip
   ROOTGLIBS     = -lGpad -lGui -lGX11 -lX3d
else
   ROOTLIBS      = $(shell root-config --libs)
   ROOTGLIBS     = $(shell root-config --glibs)
endif

ifeq ($(ARCH),linux)

   MODERNGPPVERSION := $(shell expr `g++ -dumpversion` \> 4.4.7)

# Linux with egcs
   INCLUDES      = -I$(ROOTSYS)/include 
   CXX           = g++
   ifneq ($(MODERNGPPVERSION),1)
   	CXXFLAGS      = -O -Wall  -fno-exceptions -std=c++0x -fPIC $(INCLUDES)
   	CXXFLAGS     += -Wno-deprecated 
   else
   	CXXFLAGS      = -O -Wall  -fno-exceptions -std=c++11 -fPIC $(INCLUDES)
   	CXXFLAGS     += -Wno-deprecated
   endif

   LD            = g++
   LDFLAGS       = 
   SOFLAGS       = -shared

   ifdef OLDROOT
      LIBS          = $(ROOTLIBS) -lm -ldl -rdynamic
      GLIBS         = $(ROOTLIBS) $(ROOTGLIBS) -L/usr/X11R6/lib \
                      -lXpm -lX11 -lm -ldl -rdynamic
      CXXFLAGS     += -DOLDROOT
   else
      LIBS          = $(ROOTLIBS)
      GLIBS         = $(ROOTGLIBS) -L/usr/lib -lXpm -lX11
   endif

   EVIO_LIB=libevio.a
   ALL_LIBS = $(EVIO_LIB) $(GLIBS) $(ROOTLIBS) 

# ONLIBS is needed for ET
   ET_AC_FLAGS = -D_REENTRANT -D_POSIX_PTHREAD_SEMANTICS
   ET_CFLAGS = -02 -fPIC $(ET_AC_FLAGS) -DLINUXVERS
# CODA may be an environment variable.  Typical examples
#  CODA = /adaqfs/coda/2.2
#  CODA = /data7/user/coda/2.2
   LIBET = $(CODA)/Linux/lib/libet.so
   ONLIBS = $(LIBET) -lieee -lpthread -ldl -lresolv

   ifdef ONLINE
     ALL_LIBS += $(ONLIBS)
   endif

   ifdef PROFILE
     CXXFLAGS += -pg
   endif

endif

ifeq ($(ARCH),macosx)

   MODERNGPPVERSION := $(shell expr `clang++ -dumpversion` \>= 4.2.1)

# Linux with egcs
   ROOTINC	 := $(shell root-config --incdir)
   INCLUDES      = -I$(ROOTINC)
   CXX           = clang++
   ifneq ($(MODERNGPPVERSION),1)
   	CXXFLAGS      = -O -Wall  -fno-exceptions -std=c++0x -fPIC $(INCLUDES)
   	CXXFLAGS     += -Wno-deprecated 
   else
   	CXXFLAGS      = -O -Wall  -fno-exceptions -std=c++11 -fPIC $(INCLUDES)
   	CXXFLAGS     += -Wno-deprecated
   endif

   LD            = clang++
   LDFLAGS       = 
   SOFLAGS       = -shared

   ifdef OLDROOT
      LIBS          = $(ROOTLIBS) -lm -ldl -rdynamic
      GLIBS         = $(ROOTLIBS) $(ROOTGLIBS) -L/usr/X11R6/lib \
                      -lXpm -lX11 -lm -ldl -rdynamic
      CXXFLAGS     += -DOLDROOT
   else
      LIBS          = $(ROOTLIBS)
      GLIBS         = $(ROOTGLIBS) -L/usr/lib -lXpm -lX11
   endif

   EVIO_LIB=libevio.a
   ALL_LIBS = $(EVIO_LIB) $(GLIBS) $(ROOTLIBS) 

# ONLIBS is needed for ET
   ET_AC_FLAGS = -D_REENTRANT -D_POSIX_PTHREAD_SEMANTICS
   ET_CFLAGS = -02 -fPIC $(ET_AC_FLAGS) -DLINUXVERS
# CODA may be an environment variable.  Typical examples
#  CODA = /adaqfs/coda/2.2
#  CODA = /data7/user/coda/2.2
   LIBET = $(CODA)/Linux/lib/libet.so
   ONLIBS = $(LIBET) -lieee -lpthread -ldl -lresolv

   ifdef ONLINE
     ALL_LIBS += $(ONLIBS)
   endif

   ifdef PROFILE
     CXXFLAGS += -pg
   endif

endif

SRC = THaCodaFile.C THaCodaData.C 
ifdef ONLINE 
  SRC += THaEtClient.C
endif
HEAD = $(SRC:.C=.h)
DEPS = $(SRC:.C=.d)
DECODE_OBJS = $(SRC:.C=.o)


SRC = THaCodaFile.C THaCodaData.C 
ifdef ONLINE 
  SRC += THaEtClient.C
endif
HEAD = $(SRC:.C=.h)
DEPS = $(SRC:.C=.d)
DECODE_OBJS = $(SRC:.C=.o)

ifdef STANDALONE 
  CXXFLAGS += -DSTANDALONE
endif

# ORIGINAL:
#all: fbana

#fbana: Fastbus_main1.o $(DECODE_OBJS) $(HEAD) libevio.a
#	$(CXX) -g $(CXXFLAGS) -o $@ Fastbus_main1.C $(DECODE_OBJS) $(ALL_LIBS) 
# END of ORIGINAL
# EDITED:
#all: fbanareal
#all: myonline fbanareal
#all: myonline
all: dumper fbanareal

fbanareal: Fastbus_main1.o $(DECODE_OBJS) $(HEAD) libevio.a
	$(CXX) -g $(CXXFLAGS) -o $@ Fastbus_main1.C $(DECODE_OBJS) $(ALL_LIBS) 

myonline: online.o $(DECODE_OBJS) $(HEAD) libevio.a
	$(CXX) -g $(CXXFLAGS) -o $@ online.C $(DECODE_OBJS) $(ALL_LIBS) 

dumper: dumper.o $(DECODE_OBJS) $(HEAD) libevio.a
	$(CXX) -g $(CXXFLAGS) -o $@ dumper.C $(DECODE_OBJS) $(ALL_LIBS) 
# END of EDITED

# Here we build a library with all this stuff
libcoda.a: $(DECODE_OBJS) clean_evio evio.o swap_util.o 
	rm -f $@
	ar cr $@ $(DECODE_OBJS) evio.o swap_util.o 

# Below is the evio library, which comes rather directly 
# from CODA group with minor tweaking by R. Michaels & O. Hansen.

libevio.a: clean_evio evio.o swap_util.o 
	rm -f $@
	ar cr $@ evio.o swap_util.o 

evio.o: evio.C
	$(CXX) -c  $<

swap_util.o: swap_util.C
	$(CXX) -c  $<

clean:  clean_evio
	rm -f *.o *.a core *~ *.d *.out adcana

realclean:  clean
	rm -f *.d

clean_evio:
	rm -f evio.o swap_util.o 


.SUFFIXES:
.SUFFIXES: .c .cc .cpp .C .o .d

%.o:	%.C
	$(CXX) $(CXXFLAGS) -c $<

%.d:	%.C
	@echo Creating dependencies for $<
	@$(SHELL) -ec '$(CXX) -MM $(CXXFLAGS) -c $< \
		| sed '\''s/\($*\)\.o[ :]*/\1.o $@ : /g'\'' > $@; \
		[ -s $@ ] || rm -f $@'

-include $(DEPS)








