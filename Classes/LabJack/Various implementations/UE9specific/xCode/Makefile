UE9CONFIG_SRC=ue9Config.c ue9.c
UE9CONFIG_OBJ=$(UE9CONFIG_SRC:.c=.o)

UE9SINGLEIO_SRC=ue9SingleIO.c ue9.c
UE9SINGLEIO_OBJ=$(UE9SINGLEIO_SRC:.c=.o)

UE9COMMCONFIG_SRC=ue9CommConfig.c ue9.c
UE9COMMCONFIG_OBJ=$(UE9COMMCONFIG_SRC:.c=.o)

UE9CONTROLCONFIG_SRC=ue9ControlConfig.c ue9.c
UE9CONTROLCONFIG_OBJ=$(UE9CONTROLCONFIG_SRC:.c=.o)

UE9FEEDBACK_SRC=ue9Feedback.c ue9.c
UE9FEEDBACK_OBJ=$(UE9FEEDBACK_SRC:.c=.o)

UE9STREAM_SRC=ue9Stream.c ue9.c
UE9STREAM_OBJ=$(UE9STREAM_SRC:.c=.o)

UE9TIMERCOUNTER_SRC=ue9TimerCounter.c ue9.c
UE9TIMERCOUNTER_OBJ=$(UE9TIMERCOUNTER_SRC:.c=.o)

UE9ALLIO_SRC=ue9allio.c ue9.c
UE9ALLIO_OBJ=$(UE9ALLIO_SRC:.c=.o)

UE9EASY_SRC=ue9Easy.c ue9.c
UE9EASY_OBJ=$(UE9EASY_SRC:.c=.o)

UE9LJTDAC_SRC=ue9LJTDAC.c ue9.c
UE9LJTDAC_OBJ=$(UE9LJTDAC_SRC:.c=.o)

SRCS=$(wildcard *.c)
HDRS=$(wildcard *.h)

CFLAGS=-Wall -g
CC=gcc $(CFLAGS)
LDFLAGS=
LIBS=-lm

all: ue9SingleIO ue9CommConfig ue9ControlConfig ue9Feedback ue9Stream ue9TimerCounter ue9allio ue9Easy ue9LJTDAC

ue9SingleIO: $(UE9SINGLEIO_OBJ)
	$(CC) -o ue9SingleIO $(UE9SINGLEIO_OBJ) $(LDFLAGS) $(LIBS)

ue9CommConfig: $(UE9COMMCONFIG_OBJ)
	$(CC) -o ue9CommConfig $(UE9COMMCONFIG_OBJ) $(LDFLAGS) $(LIBS)

ue9ControlConfig: $(UE9CONTROLCONFIG_OBJ)
	$(CC) -o ue9ControlConfig $(UE9CONTROLCONFIG_OBJ) $(LDFLAGS) $(LIBS)

ue9Feedback: $(UE9FEEDBACK_OBJ)
	$(CC) -o ue9Feedback $(UE9FEEDBACK_OBJ) $(LDFLAGS) $(LIBS)

ue9Stream: $(UE9STREAM_OBJ)
	$(CC) -o ue9Stream $(UE9STREAM_OBJ) $(LDFLAGS) $(LIBS)

ue9TimerCounter: $(UE9TIMERCOUNTER_OBJ)
	$(CC) -o ue9TimerCounter $(UE9TIMERCOUNTER_OBJ) $(LDFLAGS) $(LIBS)

ue9allio: $(UE9ALLIO_OBJ)
	$(CC) -o ue9allio $(UE9ALLIO_OBJ) $(LDFLAGS) $(LIBS)

ue9Easy: $(UE9EASY_OBJ)
	$(CC) -o ue9Easy $(UE9EASY_OBJ) $(LDFLAGS) $(LIBS)

ue9LJTDAC: $(UE9LJTDAC_OBJ)
	$(CC) -o ue9LJTDAC $(UE9LJTDAC_OBJ) $(LDFLAGS) $(LIBS)
	
clean: 
	rm -f *.o ue9CommConfig ue9SingleIO ue9ControlConfig ue9Feedback ue9Stream ue9TimerCounter ue9allio ue9Easy ue9LJTDAC
