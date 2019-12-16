//gcc -o read_gord_eu read_gord_eu.c tipsyxdr.c Tipsy.c tipsmall_defs3.h -lm 
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
  FILE *fpord, *fpeu, *fpout; 
  struct gassmall *gord;
  struct gasout *gout; 
  int i,j,k,nord, nfiles=400, norigin;
  char filename[200], filename1[200], filename2[200]; 
  int *gid, *gid_new, *uniq, nuniq, count, count1, nread, npeu,result,id, n, nwrite;
  float eumass, mass; 
  
  count = 0; 
  npeu = 0; 
  for(i=0;i<=nfiles-1;i++){
    sprintf(filename1, "/pfs/shens/Eris/L90Mpc8000_hithres.%05d.painteu.gidlist_128nbr",i+1);
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
    sprintf(filename, "/pfs/shens/Eris/L90Mpc8000_hithres.%05d.gord_eu",i+1);
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
    printf("number in this step %d, total %d \n", count1, count);
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

  printf("go through each file again..."); 
  /*  for (i=0;i<nuniq;i++){
    printf("%d \n", uniq[i]);
    } */
  for(i=0;i<=nfiles-1;i++){
    sprintf(filename, "/pfs/shens/Eris/L90Mpc8000_hithres.%05d.gord_eu",i+1);
    fpord = fopen(filename, "r"); 
    if(fpord == NULL){
      printf("file %d doesn't exist \n", i+1); 
      continue; 
    }
    
    fread(&norigin,sizeof(int),1, fpord);
    gord = (struct gassmall *)malloc(norigin*sizeof(struct gassmall));
    nread=fread(gord, sizeof(struct gassmall), norigin, fpord); 
    assert(nread == norigin);
    
    for (k=0;k<=nuniq-1;k++){
      gout[k].iord = uniq[k];  /* absolute ID */ 
      gout[k].id = gord[uniq[k]].id; /* tipsy ID */ 
      gout[k].eu = gord[uniq[k]].eu;  /* Eu mass in code units */ 
      gout[k].mass = gord[uniq[k]].mass;  /* gas particle mass */ 
    }
    
    sprintf(filename2, "/pfs/shens/Eris/L90Mpc8000_hithres.%05d.gord_euonly_128nbr",i+1);
    fpout = fopen(filename2, "w"); 
    fwrite(&nuniq, sizeof(int), 1, fpout);
    // fprintf(fpout, "%d \n", nuniq); 
    /*for (k=0;k<=nuniq-1;k++){
      fprintf(fpout, "%d %d %g %g \n", gout[k].iord, gout[k].id, gout[k].eu, gout[k].mass); 
    }
    fclose(fpout); */
    nwrite = fwrite(gout, sizeof(struct gasout), nuniq, fpout); 
    assert(nwrite == nuniq);
    printf("Done file %d \n", i+1); 
  }
  
  return 0; 
}
