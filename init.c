#include <sys/mount.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <linux/vt.h>
#include <sys/reboot.h>

int main() {
	// Mount /dev/
	if (mount("dev", "/dev", "devtmpfs", MS_RELATIME | MS_NOSUID | MS_NOEXEC, NULL)) {
		perror("mount");
		return 1;
	}

	// Prepare a virtual terminal
	close(STDIN_FILENO);
	close(STDOUT_FILENO);
	close(STDERR_FILENO);

	open("/dev/tty1", O_RDWR);

	ioctl(STDIN_FILENO, VT_ACTIVATE, 1);
	ioctl(STDIN_FILENO, VT_WAITACTIVE, 1);

	dup2(STDIN_FILENO, STDOUT_FILENO);
	dup2(STDIN_FILENO, STDERR_FILENO);

	// Fork and exec fbdoom
	int pid = fork();
	if (pid == 0) {
		if (execl("/fbdoom", "fbdoom", "-iwad", "doom.wad", NULL)) {
			perror("exec");
			return 3;
		}
	} else if (pid > 0) {
		// Reboot once it exits
		int sts;
		waitpid(pid, &sts, 0);
		reboot(RB_AUTOBOOT);
	} else {
		perror("fork");
		return 4;
	}
}
