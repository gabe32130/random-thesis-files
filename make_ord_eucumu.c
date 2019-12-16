// gcc -o make_ord_eucumu make_ord_eucumu.c tipsyxdr.c Tipsy.c tipsmall_defs3.h -lm 
// Mac version, changes: add #include <stdlib.h>, change %d to %ld. 
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

  FILE *fpord, *fpout,*fpslog, *fpeu, *fptipsy, *fphis, *fpiord, *fpparam;
  struct Tipsy parts; 
  struct gassmall *gord; 
  struct gasout *geu; 
  struct starlog *slog;
  struct gassort *gas, *gas1;
  XDR xdrs; 
  int i, j, k, l, ng, nd, ns, nslog, norigin, nwrite, ntot,ntoteu, nread, nuniq, nfiles=400, n, nstart, nend, ns_step, nsm=128, count, count1, giord, gid, neu; 
  int *iord, *igrp, *ideu, *sid, *ns_hist;
  float *nseu_out, *nseu_sm, dist, search_r, xc, yc, zc, z, mtot, meu_tot; 
  fphis= fopen("/uio/hume/student-u56/gabrierg/Desktop/thesis_code/analysis/los_hyades/L90Mpc8000_hithres.ns_hist", "r"); 
  assert(fphis != NULL); 
  ns_hist = (int *)malloc(nfiles*sizeof(int));
  fscanf(fphis,"%d", &n); 
  for(i=0;i<=nfiles-1;i++){
    fscanf(fphis, "%d", &ns_hist[i]); 
  }
  fclose(fphis); 

  fpslog=fopen("/uio/hume/student-u56/gabrierg/Desktop/thesis_code/analysis/los_hyades/L90Mpc8000_hithres.starlog.bin", "r"); 
  assert(fpslog !=NULL); 
  fread(&nslog,sizeof(int),1, fpslog);
  printf("total particles in the starlog file: %d \n", nslog);
  slog = (struct starlog *)malloc(nslog*sizeof(struct starlog)); 
  nread=fread(slog, sizeof(struct starlog), nslog, fpslog); 
  assert(nread ==nslog); 
  fclose(fpslog); 
  for (j=nslog-3;j<=nslog-1;j++){
    printf("ordstar %d, ordgas %d, x %g, y %g, z %g, vx%g, vy %g, vz %g, mass %g, rho %g T %g \n", slog[j].iordstar, slog[j].iordgas, slog[j].x, slog[j].y, slog[j].z, slog[j].vx, slog[j].vy, slog[j].vz, slog[j].massform,slog[j].rhoform,slog[j].tempform); 
  }
  // return 0; 
  // fplog = fopen(argv[6], "w"); 
  //assert(fplog != NULL);
  //  fpparam = fopen(argv[1], "r");
  //assert(fpparam !=NULL); 
  //fscanf(fpparam, "%d", &nsm); 
  //printf("nsm = %d \n", nsm);
  //return 0;
  fptipsy = fopen(argv[1], "r"); 
  assert(fptipsy != NULL); 
  Tipsy_in(fptipsy, &parts); 
  ng = parts.h.nsph;
  nd = parts.h.ndark;
  ns = parts.h.nstar;
  fclose(fptipsy); 
  printf("Number of Gas particles:  %d \n", ng);
  printf("total number of particles %d \n", ng+nd+ns);
  z = (1-parts.h.time)/parts.h.time; 
  printf("redshift %f \n", z); 

  /* determine the start and end ID formed between this step and next step, note that the formation will occur in the future */ 
  for (i=0;i<=nfiles-1;i++){
    if(ns == ns_hist[i]){
      nstart=ns_hist[i]; 
      nend = ns_hist[i+1]-1; 
    }
  }
  if (nend < nstart){
    printf("no new SF"); 
    fprintf(stderr, "no new SF"); 
    return 0; 
  }
  ns_step = nend-nstart+1; 
  assert(ns_step >0); 
  printf("number of stars formed in this step %d \n", ns_step); 
  fprintf(stderr, "number of stars formed in this step %d \n", ns_step); 

  // this is the file from step 2; 
  fpord = fopen(argv[2], "r"); 
  if(fpord == NULL){
    printf("gord file %d doesn't exist \n", i); 
    fprintf(stderr, "gord file %d doesn't exist \n", i); 
      return 0; 
  }
  fread(&norigin,sizeof(int),1, fpord);
  printf("norigin = %d \n", norigin); 
  fprintf(stderr, "norigin = %d \n", norigin); 
  gord = (struct gassmall *)malloc(norigin*sizeof(struct gassmall));
  nread=fread(gord, sizeof(struct gassmall), norigin, fpord); 
  assert(nread == norigin);
  fclose(fpord);

  // this is the file from step 3; 
  fpeu = fopen(argv[3], "r"); 
  assert(fpeu != NULL);
  fread(&nuniq,sizeof(int),1, fpeu);
  printf("number of particles in the eu-only file: %d \n", nuniq);
  fprintf(stderr, "number of particles in the eu-only file: %d \n", nuniq);
  geu = (struct gasout *)malloc(nuniq*sizeof(struct gasout));
  nread = fread(geu, sizeof(struct gasout), nuniq, fpeu); 
  assert(nread == nuniq); 
  fclose(fpeu); 
 
  for (i=0;i<=nuniq-1;i++){
    gord[geu[i].iord].eu = geu[i].eu; /* updated to cumulative Eu */
  }
  neu = 0; 
  for (i=0;i<=norigin-1;i++){
    if(gord[i].eu >1e-37) neu++; /* updated to cumulative Eu */
  }
  printf("total number of particles with eumass non zero, %d \n",neu);
  fprintf(stderr, "total number of particles with eumass non zero, %d \n",neu);
  /* .iord file still necessary for smoothing */
  // this is the file with extension of .iord in the data directory  
  fpiord = fopen(argv[4], "rb"); 
  assert(fpiord != NULL); 
  xdrstdio_create(&xdrs, fpiord, XDR_DECODE); 
  xdr_int(&xdrs, &ntot); 
  printf("total particles in the iord file: %d \n", ntot);
  fprintf(stderr, "total particles in the iord file: %d \n", ntot);
  //return 0;
  iord = (int *)malloc(ntot*sizeof(int)); 
  for (i=0; i<=ntot-1; i++){
    xdr_int(&xdrs, &iord[i]); 
  }
  
  fclose(fpiord); 

  /* for(i=0; i<=20; i++){
    printf("first 20 data \n");
    printf("%d, %g, %g \n", gout[i].id, gout[i].eu, gout[i].mass); 
  }
  
  for(i=norigin-1; i>=norigin-21; i--){
    printf("last 20 data \n");
    printf("%d, %g, %g \n", gout[i].id, gout[i].eu, gout[i].mass); 
    } */

  /* paint stars */ 
  nseu_out = (float *)malloc(ns_step*sizeof(float));
  nseu_sm = (float *)malloc(ns_step*sizeof(float));

  for(i=0;i<=ns_step-1;i++){
    nseu_out[i]=0.0; 
    nseu_sm[i]=0.0; 
  }

  count = 0; 
  
  for (i=nstart;i<=nend;i++){
    if(i/100*100 == i) {
      printf("i, nend, %d, %d \n", i, nend); 
      fprintf(stderr, "i, nend, %d, %d \n", i, nend); 
    }
    giord = slog[i].iordgas; 
    gid = gord[giord].id; 
    if(gord[giord].eu >1e-37){
      count++; 
      if(gid == -1) {
	printf("error: gas doesn't exist but expect to form a star %d\n", giord);
	fprintf(stderr, "error: gas doesn't exist but expect to form a star %d\n", giord);
	fclose(stderr); 
	return 1; 
      } 
      nseu_out[i-nstart]=gord[giord].eu/gord[giord].mass;   /*direct painting*/
      /* smoothed painting */
      xc =parts.gp[gid].pos[0]; 
      yc =parts.gp[gid].pos[1]; 
      zc =parts.gp[gid].pos[2]; 
      gas = (struct gassort *)malloc(ng*sizeof(struct gassort));
      search_r = 4.0; 
      for(l=0;l<=6;l++){
	count1 = 0;
	k = 0;
	
	for (j=0;j<=ng-1;j++){
	  dist = sqrt((parts.gp[j].pos[0]-xc)*(parts.gp[j].pos[0]-xc) + (parts.gp[j].pos[1]-yc)*(parts.gp[j].pos[1]-yc) + (parts.gp[j].pos[2]-zc)*(parts.gp[j].pos[2]-zc)); 

	  if(dist*kpcunit/(1+z) <=search_r){ 
	    count1++;
	    gas[k].dist=dist;
	    gas[k].id = j;   /* id of gas */ 
	    gas[k].sid = gid; /* ID of the star */
	    gas[k].eu = gord[iord[j]].eu;
	    gas[k].mass = parts.gp[j].mass;
	    k=k+1; 
	  }
	}
	if (count1 >=nsm) break; 
	search_r = search_r + 2.0; 
      }
      assert(count1 >=nsm &&"search-r too small, not enough neighbors"); 
      gas1 = (struct gassort *)malloc(count1*sizeof(struct gassort));
      for (j=0; j<=count1-1; j++){
	gas1[j].dist = gas[j].dist; 
	gas1[j].id = gas[j].id;
	gas1[j].sid = gas[j].sid;
	gas1[j].eu = gas[j].eu;
	gas1[j].mass = gas[j].mass;
      } 
      /*      for(j=0;j<=ng-1;j++){
	dist = sqrt((parts.gp[j].pos[0]-xc)*(parts.gp[j].pos[0]-xc) + (parts.gp[j].pos[1]-yc)*(parts.gp[j].pos[1]-yc) + (parts.gp[j].pos[2]-zc)*(parts.gp[j].pos[2]-zc));
       
	
       	if(dist*kpcunit/(1+z) <= search_r){
	  gas[k].dist=dist;
	  gas[k].id = j;  
	  gas[k].sid = gid; 
	  gas[k].eu = gord[iord[j]].eu;
	  gas[k].mass = parts.gp[j].mass;
	  k=k+1; 
	}
      } */
      qsort(gas1, count1, sizeof(struct gassort), compare_function); 
      mtot = 0.0; 
      meu_tot = 0.0;
      for(k=0;k<=nsm-1;k++){
	 mtot = mtot+gas1[k].mass; 
	 meu_tot = meu_tot + gas1[k].eu; 
      }
      nseu_sm[i-nstart]=meu_tot/mtot;
      free(gas); 
      free(gas1);
    }
    
  }
    printf("number of contaminated particles %d \n", count);
    fprintf(stderr, "number of contaminated particles %d \n", count);
  
    // return 0;
  printf("write to file \n");
  /* this is output file */ 
  fpout = fopen(argv[5], "w"); 
  assert(fpout != NULL); 
  fwrite(&nstart, sizeof(int), 1, fpout);
  fwrite(&nend, sizeof(int), 1, fpout);
  //  fprintf(fpout, "%d \n", norigin); 
  nwrite = fwrite(nseu_out, sizeof(float), ns_step, fpout); 
  assert(nwrite == ns_step);
  nwrite = fwrite(nseu_sm, sizeof(float), ns_step, fpout); 
  assert(nwrite == ns_step);

  // for (i=0; i<=norigin-1; i++){
  //  fwrite(gout[i], sizeof(struct gassmall), 1, fpout); 
  //  fprintf(fpout, "%d %g %g \n",gout[i].id, gout[i].eu, gout[i].mass); 
  //  } 
  fclose(fpout); 
  
  //fclose(fplog); 

  return 0; 
}

