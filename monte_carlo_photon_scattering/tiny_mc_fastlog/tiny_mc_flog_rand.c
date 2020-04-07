/* Tiny Monte Carlo by Scott Prahl (http://omlc.ogi.edu)"
 * 1 W Point Source Heating in Infinite Isotropic Scattering Medium
 * http://omlc.ogi.edu/software/mc/tiny_mc.c
 *
 * Adaptado para CP2014, Nicolas Wolovick
 */


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <omp.h> // handy omp_get_wtime()
#include <string.h> // strlen
#include <time.h> // time
#include <math.h>
#include <stdint.h>
#include "SFMT.h"

char t1[] = "Tiny Monte Carlo by Scott Prahl (http://omlc.ogi.edu)";
char t2[] = "1 W Point Source Heating in Infinite Isotropic Scattering Medium";
char t3[] = "CPU version, adapted for PEAGPGPU by Gustavo Castellano"
			" and Nicolas Wolovick";


// Default parameters

#ifndef SHELLS
#define SHELLS 101 // discretization level
#endif

#ifndef PHOTONS
#define PHOTONS 32768 // 32K photons
#endif

#ifndef MU_A
#define MU_A 2.0f // Absorption Coefficient in 1/cm !!non-zero!!
#endif

#ifndef MU_S
#define MU_S 20.0f // Reduced Scattering Coefficient in 1/cm
#endif

#ifndef MICRONS_PER_SHELL
#define MICRONS_PER_SHELL 50 // Thickness of spherical shells in microns
#endif



// Internal definitions and functions
#define SEED (time(NULL)) // random seed
#define MILLISEC 1E-3
#define RNGS 131072

// global state, heat and heat square in each shell
float heat[SHELLS];
float heat2[SHELLS];

static inline float 
fastlog2 (float x)
{
      union { float f; uint32_t i; } vx = { x };
      union { uint32_t i; float f; } mx = { (vx.i & 0x007FFFFF) | 0x3f000000 };
      float y = vx.i;
      y *= 1.1920928955078125e-7f;

      return y - 124.22551499f - 1.498030302f * mx.f 
               - 1.72587999f / (0.3520887068f + mx.f);
}

static inline float
fastlog (float x)
{
      return 0.69314718f * fastlog2 (x);
}

/***
 * Mersenne Twister Random
 ***/
sfmt_t tinymt;
float mtrand(void) {
    return sfmt_genrand_uint32(&tinymt) * (1.0f / 4294967295.0f);
}



/***
 * Photon
 ***/

static void photon(void) {
	unsigned int shell;
	float x, y, z, u, v, w, weight;
	float xi1, xi2, t;
	const float albedo = MU_S / (MU_S + MU_A);
	const float shells_per_mfp = 1e4/MICRONS_PER_SHELL/(MU_A+MU_S);

	x = 0.0f; y = 0.0f; z = 0.0f; /* launch */
	u = 0.0f; v = 0.0f; w = 1.0f;
	weight = 1.0f;

	for (;;) {
		t = -fastlog(mtrand()); /* move */
		x += t * u;
		y += t * v;
		z += t * w;

		shell=sqrtf(x*x+y*y+z*z)*shells_per_mfp; /* absorb */
		if (shell > SHELLS-1) {
			shell = SHELLS-1;
		}
		heat[shell] += (1.0f-albedo)*weight;
		heat2[shell] += (1.0f-albedo)*(1.0f-albedo)*weight*weight;  /* add up squares */
		weight *= albedo;

		/* New direction, rejection method */
		do {
			xi1 = 2.0f*mtrand() - 1.0f;
			xi2 = 2.0f*mtrand() - 1.0f;
			t = xi1*xi1+xi2*xi2;
		} while (1.0f<t);
		u = 2.0f * t - 1.0f;
		v = xi1 * sqrtf((1.0f-u*u)/t);
		w = xi2 * sqrtf((1.0f-u*u)/t);

		if (weight < 0.001f) { /* roulette */
			if (mtrand() > 0.1f) break;
			weight /= 0.1f;
		}
	}
}


/***
 * Main matter
 ***/

int main(void)
{
	double start = 0.0, end = 0.0, elapsed = 0.0;
	float t = 0.0f;
	unsigned int i = 0;

	// heading
	printf("# %s\n# %s\n# %s\n", t1, t2, t3);
	printf("# Scattering = %8.3f/cm\n", MU_S);
	printf("# Absorption = %8.3f/cm\n", MU_A);
	printf("# Photons    = %8d\n#\n", PHOTONS);

	// configure RNG
	sfmt_init_gen_rand(&tinymt, SEED);
	// start timer
	start = omp_get_wtime();
	// simulation
	for (i=0; i<PHOTONS; ++i) {
		photon();
	}
	// stop timer
	end = omp_get_wtime();
	assert(start<=end);
	elapsed = end-start;

	printf("# %lf seconds\n", elapsed);
	printf("# %lf K photons per second\n", PHOTONS/elapsed * MILLISEC);

	printf("# Radius\tHeat\n");
	printf("# [microns]\t[W/cm^3]\tError\n");
	t = 4.0f*M_PI*powf(MICRONS_PER_SHELL, 3.0f)*PHOTONS/1e12;
	for (i=0; i<SHELLS-1; ++i) {
		printf("%6.0f\t%12.5f\t%12.5f\n", i*(float)MICRONS_PER_SHELL,
				heat[i]/t/(i*i+i+1.0/3.0),
				sqrt(heat2[i]-heat[i]*heat[i]/PHOTONS)/t/(i*i+i+1.0f/3.0f));
	}
	printf("# extra\t%12.5f\n", heat[SHELLS-1]/PHOTONS);

	return 0;
}
