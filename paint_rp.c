//gcc -o paint_rp paint_rp.c tipsyxdr.c Tipsy.c tipsmall_defs3.h -lm 
//use ./runpaint_eu_serial.sh for all 400 jobs
#include <stdio.h>
#include <stdlib.h>
#include "math.h"
#include "Tipsy.h"
#include "assert.h"
#include "rpc/xdr.h"
#include "tipsmall_defs3.h"
#include <malloc.h>
#include <rpc/types.h>

#define pi  3.14159265358979323846
#define msolunit 1.078e17 
#define kpcunit 90000.
#define Eutot 0.00093*5.0e-2/1.078e17  //0.00093 is the ratio Eu/r in code units 
//#define Eutot 0.00093*0.01/1.078e17 

float kernel3D(float r, float hsm){
  float x; 
  if(r/hsm > 0. && r/hsm <= 1.0) x= 1./pi/hsm/hsm/hsm*(1-1.5*(r/hsm)*(r/hsm) + 3.0/4.0*(r/hsm)*(r/hsm)*(r/hsm)); 
  if(r/hsm > 1. && r/hsm <= 2.0) x = 1./pi/hsm/hsm/hsm*(0.25*pow((2-r/hsm), 3));
  if(r/hsm > 2.0) x= 0; 
  return x; 
}

int compare_function(const void *a, const void *b){
  //  float x = *(float *)a; 
  //float y = *(float *)b; 
  float x =((const struct gassort*)a)->dist; 
  float y =((const struct gassort*)b)->dist; 
  if (x < y) return -1; 
  else if (x > y) return 1; 
  return 0; 
}

int main(int argc, char *argv[]){
  FILE *fptipsy, *fplist, *fpout, *fplog;
  struct Tipsy parts;
  struct gassort *gas; 
  int i, j, k, l, ng,nd,count, npick, npaint, nsm=32; 
  float *masseu, z, dist, hsm, xc, yc, zc, mtot, search_r; 
  int *ideu, *ipick;    //list of gas ID (in tipsy) who receives r-process injection
  
  fptipsy = fopen(argv[1], "r"); 
  assert(fptipsy != NULL); 
  Tipsy_in(fptipsy, &parts); 
  ng = parts.h.nsph;
  nd = parts.h.ndark;
  fclose(fptipsy); 
  printf("Number of Gas particles:  %d \n", ng);
  printf("total number of particles %d \n", ng+nd+parts.h.nstar);

  z = 1./parts.h.time -1; 
  printf("z  %f \n", z); 
  /* list of stellar particles randomly chosen to paint its neighboring gas with Eu */  

  fplist = fopen(argv[2], "r"); 
  assert(fplist !=NULL); 
  fscanf(fplist, "%d \n", &npick); 
  printf("total stellar particles picked at this time step %d \n", npick);
  if (npick == 0){
    printf("no NSNS mergers occured at this timestep \n"); 
    return 0; 
  }
  ipick = (int *)malloc(npick*sizeof(int)); 
  for (i=0; i<=npick-1; i++){
    fscanf(fplist, "%d", &ipick[i]); 
  }
  
  fclose(fplist); 
  for (i=0; i<=npick-1; i++){
    printf("selected stars ID %d\n", ipick[i]); 
  }
  
  fpout=fopen(argv[3], "w");
  assert(fpout != NULL);
  fprintf(fpout, "%d \n", npick*nsm);
  //fclose(fpout); 
  // dist = (float *)malloc(ng*sizeof(float));
  fplog = fopen(argv[4], "w"); 
  assert(fplog !=NULL); 
  
  for (i=0;i<=npick-1;i++){
    fprintf(fplog,"stellar particle ID %d \n", ipick[i]);
    xc = parts.sp[ipick[i]].pos[0];
    yc = parts.sp[ipick[i]].pos[1]; 
    zc = parts.sp[ipick[i]].pos[2];
    search_r = 2.0; 
    //   count = 0; 
    for(l=0;l<=6;l++){
	count = 0;
	k = 0;
	for (j=0;j<=ng-1;j++){
	  dist = sqrt((parts.gp[j].pos[0]-xc)*(parts.gp[j].pos[0]-xc) + (parts.gp[j].pos[1]-yc)*(parts.gp[j].pos[1]-yc) + (parts.gp[j].pos[2]-zc)*(parts.gp[j].pos[2]-zc)); 
      //count = 0;
      /* assume the kernel 2h wont be larger than 5 kpc */ 
	  if(dist*kpcunit/(1+z) <= search_r){
	    count = count+1; 
	  }
	}
	if (count >=nsm) break; 
	search_r = search_r + 2.0; 
    }
    assert(count >=nsm &&"search-r too small, not enough neighbors");
    gas = (struct gassort *)malloc(count*sizeof(struct gassort));
    k = 0;
    for(j=0;j<=ng-1;j++){
      dist = sqrt((parts.gp[j].pos[0]-xc)*(parts.gp[j].pos[0]-xc) + (parts.gp[j].pos[1]-yc)*(parts.gp[j].pos[1]-yc) + (parts.gp[j].pos[2]-zc)*(parts.gp[j].pos[2]-zc));
       
      if(dist*kpcunit/(1+z) <= search_r){
	gas[k].dist=dist;
	gas[k].id = j;   /* id of gas */ 
	gas[k].sid = ipick[i]; /* ID of the star */
	gas[k].eu = 0.0;
	gas[k].mass = parts.gp[j].mass;
	k=k+1; 
      }
    }
    qsort(gas, count, sizeof(struct gassort), compare_function); 
    //qsort((gas*)->dist, count, sizeof(float), compare_function); 
    /* debug */
    /*  printf("after sorting..."); 
    for(k=0;k<=count-1;k++){
      printf("distance to star particle %g \n", gas[k].dist*kpcunit/(1+z)); 
      } */

    hsm = gas[nsm-1].dist/2;  // the smoothing length 
    fprintf(fplog, "smoothing length for star particle %d is %g kpc \n", ipick[i], hsm*kpcunit/(1+z));
    assert(hsm*2.0 <=search_r);
    mtot = 0.0; 
    for(k=0;k<=nsm-1;k++){
      mtot = mtot+gas[k].mass*kernel3D(gas[k].dist, hsm); 
    }
    for(k=0;k<=nsm-1;k++){
      gas[k].eu = gas[k].mass*kernel3D(gas[k].dist, hsm)/mtot*Eutot;
    }
    //fpout=fopen(argv[3], "a"); 
    //assert(fpout != NULL); 
    for(k=0;k<=nsm-1; k++){
      fprintf(fpout, "%d %d %g %g \n", gas[k].id, gas[k].sid, gas[k].dist,gas[k].eu); 
    }
  }
  fclose(fpout); 
  fclose(fplog);
  return 0; 
}
