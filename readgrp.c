/* gcc -o readgrp readgrp.c tipsyxdr.c Tipsy.c -lm */ 
#include "stdio.h"
#include "assert.h"
#include "malloc.h"
#include "Tipsy.h"
#include <rpc/types.h>
#include <rpc/xdr.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char*argv[]){
  FILE *fptip, *fpgrp, *fpout1, *fpout2; 
   int nread, bStandard;
   int igroup, ntot, i, j, igmax, idmax, ngrp; 
   XDR xdrs; 
   struct dump h;
   struct gas_particle gas; 
   struct dark_particle dark; 
   struct star_particle star;
   float *massg, *metalg, *masss, *metals, *massd; 
   
   fptip = fopen(argv[1], "r");
   fpgrp = fopen(argv[2], "r");
   
   assert(fptip != NULL);
   assert(fpgrp != NULL);
    nread = fread(&h, sizeof(h), 1, fptip);
    assert(nread == 1);
    bStandard =0; 
    if (h.ndim < 1 || h.ndim > 3){
      rewind(fptip);
      xdrstdio_create(&xdrs, fptip, XDR_DECODE); 
      xdr_header(&xdrs, &h); 
      if (h.ndim > 0 && h.ndim < 4){
	bStandard = 1; 
      }else assert(0); 
    }
    assert(h.nsph >=0); 
    assert(h.ndark >=0);
    assert(h.nstar >=0); 
 
    printf("header nsph, ndark, nstar, nstandard %d, %d %d %d \n", h.nsph, h.ndark, h.nstar, bStandard);  
    
    fscanf(fpgrp, "%d \n", &ntot); 
    igmax = 0; 
    idmax = 0; 
    for (i=0; i<h.nsph; i++){
      fscanf(fpgrp, "%d \n", &igroup); 
      if(igroup > igmax) igmax = igroup; 
    }
    for (i=0; i<h.ndark; i++){
      fscanf(fpgrp, "%d \n", &igroup); 
      if (igroup > idmax) idmax = igroup; 
    }
    
    if (idmax >= igmax){
      ngrp = idmax+1; 
      if (idmax == igmax) printf("same number of groups for gas and dark matter %d \n", idmax);
    }    
    else {
      ngrp = igmax+1;
      printf("gas groups > dm groups: gas %d, dark %d \n", igmax, idmax); 
    }
    massg = (float *)malloc(ngrp*sizeof(float)); 
    metalg = (float *)malloc(ngrp*sizeof(float)); 
    masss = (float *)malloc(ngrp*sizeof(float)); 
    metals = (float *)malloc(ngrp*sizeof(float)); 
    massd = (float *)malloc(ngrp*sizeof(float));

    rewind(fpgrp); 
    fscanf(fpgrp, "%d \n", &ntot);
    printf("ntot %d \n", ntot); 
 
    for (i=0; i<h.nsph; i++){
       if (bStandard) xdr_gas(&xdrs, &gas, 1);
       else {
	 nread = fread(&gas, sizeof(gas), 1, fptip); 
	 assert(nread == 1); 
       } 
       fscanf(fpgrp, "%d \n",&igroup); 
       massg[igroup] = massg[igroup] + gas.mass; 
       metalg[igroup] = metalg[igroup] + gas.metals * gas.mass; 
    }
    for (i=0; i<h.ndark; i++){
       if(bStandard) xdr_dark(&xdrs, &dark, 1); 
       else{
	 nread = fread(&dark, sizeof(dark), 1, fptip);
	 assert(nread == 1); 
       }
       fscanf(fpgrp, "%d \n", &igroup);
       massd[igroup] = massd[igroup] + dark.mass; 
    }

    for (i=0; i<h.nstar; i++){
       if(bStandard) xdr_star(&xdrs, &star, 1); 
       else{
	 nread = fread(&star, sizeof(star), 1, fptip);
	 assert(nread == 1); 
       }
       fscanf(fpgrp, "%d \n", &igroup);
       masss[igroup] = masss[igroup] + star.mass; 
       metals[igroup] = metals[igroup] + star.mass*star.metals;  
    }
    fclose(fptip); 
    // fclose(fpgrp); 
    fpout1 = fopen(argv[3], "w"); 
    assert(fpout1 != NULL ); 
    fprintf(fpout1, "%d \n", ngrp); 
    
    for (j=0; j<ngrp;j++){
      fprintf(fpout1, "%g %g %g %g %g  \n",massg[j], massd[j],masss[j], metalg[j], metals[j]);
    }
    fclose(fpout1);
    fpout2 = fopen(argv[4],"w"); 
    assert(fpout2 != NULL); 
    fprintf(fpout2, "%d \n", h.nstar);
    rewind(fpgrp); 
    
    
    fscanf(fpgrp, "%d \n", &ntot); 
    for (i=0; i<h.nsph; i++){
      fscanf(fpgrp, "%d \n", &igroup); 
    }
    for (i=0; i<h.ndark; i++){
      fscanf(fpgrp, "%d, \n", &igroup); 
    }
    
    for (i=0; i<h.nstar; i++){
      fscanf(fpgrp, "%d \n", &igroup); 
      fprintf(fpout2, "%g \n", massg[igroup] + masss[igroup] + massd[igroup]); 
    }

    fclose(fpgrp); 
    fclose(fpout2);
}

