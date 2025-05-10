#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <errno.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        syslog(LOG_ERR, "Missing two arguments");
        exit(EXIT_FAILURE);
    }
    openlog("writer", 0, LOG_USER);
    syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);
    FILE *fp = fopen(argv[1], "w");
    if (!fp) {
        syslog(LOG_ERR, "Failed to open file %s: %s", argv[1], strerror(errno));
        closelog();
        exit(EXIT_FAILURE);
    }
    if (fprintf(fp, "%s", argv[2]) < 0) {
        syslog(LOG_ERR, "Error writing to file %s: %s", argv[1], strerror(errno));
        fclose(fp);
        closelog();
        exit(EXIT_FAILURE);
    }
    if (fclose(fp) != 0) {
        syslog(LOG_ERR, "Error closing file %s: %s", argv[1], strerror(errno));
        closelog();
        exit(EXIT_FAILURE);
    }
    closelog();
    exit(EXIT_SUCCESS);
}
