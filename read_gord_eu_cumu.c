//gcc -o read_gord_eu_cumu read_gord_eu_cumu.c tipsyxdr.c Tipsy.c tipsmall_defs3.h -lm 
/* read the gord structure and extract the gas particles that ever had received Eu injection at certain time, should be a smaller number than the total gas particles */
#include <stdio.h>
#include <stdlib.h>
#include "math.h"
#include "Tipsy.h"
#include "assert.h"
#include "rpc/xdr.h"
#include "tipsmall_defs3.h"
#include <malloc.h>
#include <rpc/types.h>

int compare_integer(const void *a, const void *b){
  return (*(int*)a - *(int*)b); 
}

int unique(int *array, int ntot, int *uniq, int nuniq){
  /* array -- sorted array with ascending values */
  /* ntot -- total number of elements in the array */
  /* uniq -- return value */ 
  int i, j, count;
  if (nuniq == -1){
    count = 1;  /* the first element is always unique */
    for(i=0;i<ntot-1;i++){
      if (array[i+1]!=array[i]){
	count = count+1; 
      }
    }
    return count; 
  } else 
    {
      j=0; 
      uniq[j]=array[0]; 
      for(i=0; i<ntot-1; i++){
	if (array[i+1]!=array[i]){
	  j=j+1; 
	  uniq[j]=array[i+1];
	}
      }
    }
  return 0; 
 }

int main(int argc, char *argv[]){
  FILE *fpord, *fpeu, *fpout, *fpprev; 
  struct gassmall *gord;
  struct gasout *gout, *gprev;
  struct starlog *slog;
  //nfiles=400
  int i,j,k,nord, nfiles=250, norigin, nslog;
  char filename[200], filename1[200], filename2[200], filename3[200]; 
  int *gid, *gid_new, *uniq, nuniq, count, count1, nread, npeu,result,id, n, nwrite, *ns_hist;
  float eumass, mass;
  int ngd, ndark;

  for(i=0;i<=nfiles-1;i++){
    // input files here are the output files for step 1, from paint_rp.c, only the path and the extension needs to be changed, please do not change L90Mpc8000_hithres.%05d. because that's the main name and step number. 
    // in the extension I used idx2p0 or idx2 below, because it was for a case with dalay time distribution of index n = -2, but for the fidual case the index is -1  
    sprintf(filename1, "/uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/L90Mpc8000_hithres.%05d.painteu.gidlist_idx1p0",i+1);
    fpeu = fopen(filename1, "r"); 
     if(fpeu == NULL){
      printf("file %d doesn't exist \n", i+1); 
      continue; 
    }
     //assert(fpeu !=NULL); 
    fscanf(fpeu,"%d", &npeu);
    printf("number of gas particles painted %d, step %d \n", npeu, i+1);
    count = count + npeu;
    fclose(fpeu);
  } 
  nord = count; 
  printf("total number of painted gas particles %d \n", nord); 
  gid = (int*)malloc(nord*sizeof(int)); 
  
  count = 0; 
  for(i=0;i<=nfiles-1;i++){
    count1 = 0; 
    // input files here are the output files from step 2, i.e. from make_ord_sml.c, again only path and extension needs to be changed 
    sprintf(filename, "/uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/L90Mpc8000_hithres.%05d.gord_eu_idx1",i+1);
    fpord = fopen(filename, "r"); 
    if(fpord == NULL){
      printf("file %d doesn't exist \n", i+1); 
      continue; 
    }
    fread(&norigin,sizeof(int),1, fpord);
    gord = (struct gassmall *)malloc(norigin*sizeof(struct gassmall));
    nread=fread(gord, sizeof(struct gassmall), norigin, fpord); 
    assert(nread == norigin);
    for(j=0;j<=norigin-1;j++){
      if(gord[j].eu > 1e-37){
	gid[count]=j; 
	count=count+1;
	count1=count1+1; 
      }
      
    }
    printf("number in this step %d, total %d, step %d \n", count1, count, i);
    free(gord);
    fclose(fpord); 
  }
  
  printf("number gas particles painted in gord file %d %d \n", nord, count);
  assert(nord >=count);
  /* trim off */
  gid_new = (int*)malloc(count*sizeof(int)); 
  for(i=0;i<=count-1;i++){
    gid_new[i]=gid[i];
  }
  qsort(gid_new,count,sizeof(int), compare_integer); 
  n = -1; 
  nuniq = unique(gid_new,count, uniq, n); 
  uniq = (int*)malloc(nuniq*sizeof(int)); 
  result=unique(gid_new, count, uniq, nuniq); 
  
  printf("number of unique gas particles gets painted %d \n", nuniq); 
  gout = (struct gasout *)malloc(nuniq*sizeof(struct gasout));

  printf("go through each file again... \n"); 
  /*  for (i=0;i<nuniq;i++){
    printf("%d \n", uniq[i]);
    } */
  for(i=0;i<=nfiles-1;i++){
    // this is the output file from a previous time step of the current routine, so change names and extension only; 
    sprintf(filename3, "/uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/L90Mpc8000_hithres.%05d.gord_euonly_cumu_idx1",i);
    fpprev = fopen(filename3, "r"); 
    if(fpprev == NULL){
      printf("previous time step file %d doesn't exist \n", i); 
      printf("norigin %d \n", norigin); 
      gprev = (struct gasout *)malloc(nuniq*sizeof(struct gasout));
      for (k=0;k<=nuniq-1;k++){
	gprev[k].iord = -1; 
	gprev[k].id = -1; 
	gprev[k].eu = 0.0; 
	gprev[k].mass = 0.0;
	gprev[k].fmassloss = 0.0; 
      }
    } else {
       fread(&nuniq,sizeof(int),1, fpprev);
       gprev = (struct gasout *)malloc(nuniq*sizeof(struct gasout));
       nread=fread(gprev, sizeof(struct gasout), nuniq, fpprev); 
       assert(nread == nuniq);
       fclose(fpprev);
       
    }
    
    //  return 0;  
    // this is again the input file from step 2.     
    sprintf(filename, "/uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/L90Mpc8000_hithres.%05d.gord_eu_idx1",i+1);
    fpord = fopen(filename, "r"); 
    if(fpord == NULL){
      printf("current file %d doesn't exist \n", i+1); 
      continue; 
    }
    
    fread(&norigin,sizeof(int),1, fpord);
    gord = (struct gassmall *)malloc(norigin*sizeof(struct gassmall));
    nread=fread(gord, sizeof(struct gassmall), norigin, fpord); 
    assert(nread == norigin);
    
    for (k=0;k<=nuniq-1;k++){
      gout[k].iord = uniq[k];  /* absolute ID */ 
      gout[k].id = gord[uniq[k]].id; /* tipsy ID */ 
      gout[k].eu = gord[uniq[k]].eu+gprev[k].eu-gprev[k].eu*gprev[k].fmassloss;  /* Eu mass in code units , cumulative*/ 
      /* subtract the Eu loss in previous star formation */ 
      
      gout[k].mass = gord[uniq[k]].mass; /* gas particle mass */ 
      gout[k].fmassloss = gord[uniq[k]].fmassloss; 
    }
    // this is  output file from the current time step, change extensions but just to be consistent with the previous ones   
    sprintf(filename2, "/uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/L90Mpc8000_hithres.%05d.gord_euonly_cumu_idx1",i+1);
    fpout = fopen(filename2, "w"); 
    fwrite(&nuniq, sizeof(int), 1, fpout);
    // fprintf(fpout, "%d \n", nuniq); 
    /*for (k=0;k<=nuniq-1;k++){
      fprintf(fpout, "%d %d %g %g \n", gout[k].iord, gout[k].id, gout[k].eu, gout[k].mass); 
    }
    fclose(fpout); */
    nwrite = fwrite(gout, sizeof(struct gasout), nuniq, fpout); 
    assert(nwrite == nuniq);
    fclose(fpout); 
    printf("Done file %d \n", i+1); 
    free(gord);
  }
  
  return 0; 
}
