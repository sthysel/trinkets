/*
It's important to note that the information visible in ps can be completely
overwritten by the running program.
*/

#include <string.h>
#include <unistd.h>

int main (int argc, char **argv) {
        memset(argv[0], ' ', strlen(argv[0]));
        strcpy(argv[0], "hahaIdoWhatIWant");
        sleep(30);
        return(0);
}
