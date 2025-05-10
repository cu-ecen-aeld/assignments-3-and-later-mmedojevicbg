CC = $(CROSS_COMPILE)gcc
OBJS = writer.o
writer: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
clean:
	rm -f writer *.o
