#include "tipsydefs.h"

struct Tipsy {
  int bStandard;
  struct dump h;
  struct gas_particle *gp;
  struct dark_particle *dp;
  struct star_particle *sp;
};

void Tipsy_dup(struct Tipsy old, struct Tipsy *new);
void Tipsy_in(FILE *f, struct Tipsy *t);
void Tipsy_out(FILE *f, struct Tipsy t);
