#include "stdio.h"
#include "stdlib.h"
#include "assert.h"
#include "malloc.h"
#include "Tipsy.h"
#include <rpc/types.h>
#include <rpc/xdr.h> 
void
Tipsy_dup(struct Tipsy old, struct Tipsy *new)
{
  new->h = old.h;
  new->bStandard = old.bStandard;
  if(new->h.nsph)
    new->gp = malloc(sizeof(*new->gp)*new->h.nsph);
  if(new->h.ndark)
    new->dp = malloc(sizeof(*new->dp)*new->h.ndark);
  if(new->h.nstar)
    new->sp = malloc(sizeof(*new->sp)*new->h.nstar);
}

void
Tipsy_in(FILE *f, struct Tipsy *t)
{
  int nread;
  XDR xdrs;

  nread = fread(&t->h, sizeof(t->h), 1, f);
  assert(nread == 1);
  t->bStandard = 0;
  if(t->h.ndim < 1 || t->h.ndim > 3) {
    rewind(f);
    xdrstdio_create(&xdrs,f,XDR_DECODE);
    xdr_header(&xdrs,&t->h);
    if(t->h.ndim > 0 && t->h.ndim < 4) {
      t->bStandard = 1;
    }else assert(0);
  } 

  assert(t->h.nsph >= 0);
  assert(t->h.ndark >= 0);
  assert(t->h.nstar >= 0);
  
  if(t->h.nsph)
    t->gp = malloc(sizeof(*t->gp)*t->h.nsph);
  if(t->h.ndark)
    t->dp = malloc(sizeof(*t->dp)*t->h.ndark);
  if(t->h.nstar)
    t->sp = malloc(sizeof(*t->sp)*t->h.nstar);

  if(t->bStandard) xdr_gas(&xdrs,t->gp,t->h.nsph);
  else {
    nread = fread(t->gp, sizeof(*t->gp), t->h.nsph, f);
    assert(nread == t->h.nsph);
  }
  if(t->bStandard) xdr_dark(&xdrs,t->dp,t->h.ndark);
  else {
    nread = fread(t->dp, sizeof(*t->dp), t->h.ndark, f);
    assert(nread == t->h.ndark);
  }
  if(t->bStandard) xdr_star(&xdrs,t->sp,t->h.nstar);
  else {
    nread = fread(t->sp, sizeof(*t->sp), t->h.nstar, f);
    assert(nread == t->h.nstar);
  }
  if(t->bStandard) xdr_destroy(&xdrs);
}

void
Tipsy_out(FILE *f, struct Tipsy t)
{
  int nwrite;
  XDR xdrs;

  if(t.bStandard) {
    xdrstdio_create(&xdrs,f,XDR_ENCODE);
    xdr_header(&xdrs,&t.h);
  } else {
    nwrite = fwrite(&t.h, sizeof(t.h), 1, f);
    assert(nwrite == 1);
  }
  
  if(t.bStandard) xdr_gas(&xdrs,t.gp,t.h.nsph);
  else {
    nwrite = fwrite(t.gp, sizeof(*t.gp), t.h.nsph, f);
    assert(nwrite == t.h.nsph);
  }
  if(t.bStandard) xdr_dark(&xdrs,t.dp,t.h.ndark);
  else {
    nwrite = fwrite(t.dp, sizeof(*t.dp), t.h.ndark, f);
    assert(nwrite == t.h.ndark);
  }
  if(t.bStandard) xdr_star(&xdrs,t.sp,t.h.nstar);
  else {
    nwrite = fwrite(t.sp, sizeof(*t.sp), t.h.nstar, f);
    assert(nwrite == t.h.nstar);
  }
}
