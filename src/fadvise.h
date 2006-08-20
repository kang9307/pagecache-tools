#include <asm/unistd.h>

#ifndef __NR_fadvise64
#if defined (__i386__)
#define __NR_fadvise64          250
#elif defined(__powerpc__)
#define __NR_fadvise64          233
#elif defined(__ia64__)
#define __NR_fadvise64		1234
#endif
#endif

_syscall5(int,fadvise64, int,fd, long,offset_lo,
		long,offset_hi, size_t,len, int,advice)

/* Works by luck on ppc32, fails on ppc64 */
#if defined(__i386__)
int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
{
	return fadvise64(fd, offset, 0, len, advice);
}

int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
{
	return fadvise64(fd, offset, offset >> 32, len, advice);
}
#elif defined(__powerpc64__)
int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
{
	return fadvise64(fd, offset, len, advice);
}

int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
{
	return fadvise64(fd, offset, len, advice);
}
#elif defined(__powerpc__)

/* 
 * long longs are passed in an odd even register pair on ppc32 so
 * we need to pad before offset
 *
 * Note also the glibc syscall() function for ppc has been broken for
 * 6 argument syscalls until recently (~2.3.1 CVS)
 */
#define ppc_fadvise64(fd, offset_hi, offset_lo, len, advice) \
	syscall(__NR_fadvise64, fd, 0, offset_hi, offset_lo, len, advice)

int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
{
	return ppc_fadvise64(fd, 0, offset, len, advice);
}

/* big endian, akpm. */
int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
{
	return ppc_fadvise64(fd, (unsigned int)(offset >> 32),
			(unsigned int)(offset & 0xffffffff), len, advice);
}
#elif defined(__ia64__)
int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
{
	return fadvise64(fd, offset, len, advice);
}

int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
{
	return fadvise64(fd, offset, len, advice);
}

#endif
