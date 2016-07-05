// mach_inject_bundle_stub.c semver:1.2.0
//   Copyright (c) 2003-2012 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/mach_inject
//
//   Design inspired by SCPatchLoader by Jon Gotow of St. Clair Software:
//   http://www.stclairsoft.com

#include "mach_inject_bundle_stub.h"
#include "mach_inject.h" // for INJECT_ENTRY

#include <assert.h>
#include <mach/mach_init.h>
#include <mach/thread_act.h>
#include <pthread.h>
#include <dlfcn.h>

#include <sys/mman.h>

/**************************
*	
*	Funky Protos
*	
**************************/
#pragma mark	(Funky Protos)

	void
INJECT_ENTRY(
		ptrdiff_t						codeOffset,
		mach_inject_bundle_stub_param	*param,
		size_t							paramSize,
		char							*dummy_pthread_struc );
		
	void*
pthread_entry(
		mach_inject_bundle_stub_param	*param );
	

typedef void * (*dlopen_f)(const char * __path, int __mode);

/*******************************************************************************
*	
*	Implementation
*	
*******************************************************************************/
#pragma mark	-
#pragma mark	(Implementation)

	void
INJECT_ENTRY(
		ptrdiff_t						codeOffset,
		mach_inject_bundle_stub_param	*param,
		size_t							paramSize,
		char							*dummy_pthread_struct )
{
	assert( param );
	
#if defined (__i386__) || defined(__x86_64__)
	// On intel, per-pthread data is a zone of data that must be allocated.
	// if not, all function trying to access per-pthread data (all mig functions for instance)
	// will crash. 
	extern void __pthread_set_self(char*);
	__pthread_set_self(dummy_pthread_struct);
#endif

//	fprintf(stderr, "mach_inject_bundle: entered in %s, codeOffset: %td, param: %p, paramSize: %lu\n",
//			INJECT_ENTRY_SYMBOL, codeOffset, param, paramSize);

	pthread_attr_t attr;
	pthread_attr_init(&attr); 
	
	int policy;
	pthread_attr_getschedpolicy( &attr, &policy );
	pthread_attr_setdetachstate( &attr, PTHREAD_CREATE_DETACHED );
	pthread_attr_setinheritsched( &attr, PTHREAD_EXPLICIT_SCHED );
	
	struct sched_param sched;
	sched.sched_priority = sched_get_priority_max( policy );
	pthread_attr_setschedparam( &attr, &sched );
	
	pthread_t thread;
	pthread_create( &thread,
					&attr,
					(void* (*)(void*))((long)pthread_entry + codeOffset),
					(void*) param );
	pthread_attr_destroy(&attr);
	
	thread_suspend(mach_thread_self());
}

void*
pthread_entry(
              mach_inject_bundle_stub_param	*param ) {

    char vec, *loadAddress = (char *)0x100000000;
    while ( !(mincore( loadAddress, PAGE_SIZE, &vec ) == 0 && vec & MINCORE_INCORE) )
        loadAddress += PAGE_SIZE;

    static unsigned char dlopenInstrux[] = {0x55, 0x48, 0x89, 0xe5, 0x41, 0x56, 0x53, 0x41, 0x89, 0xf6, 0x48, 0x89, 0xfb, 0x48, 0x8b, 0x0d};
    dlopen_f dlopen_ = NULL;

    for ( char *searchAddress = loadAddress + param->dlopenPageOffset ; searchAddress < (char *)0x200000000 ; searchAddress += PAGE_SIZE )
        if (memcmp( searchAddress, dlopenInstrux, sizeof dlopenInstrux ) == 0) {
            dlopen_ = (dlopen_f)searchAddress;
            break;
        }

    if (dlopen_)
        dlopen_(param->bundleExecutableFileSystemRepresentation, RTLD_NOW);

    return NULL;
}

