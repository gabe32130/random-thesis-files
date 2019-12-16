// typedef float Real;
#define NGRP 2
struct tipsmall{
  float dist;
  float mass; 
};

struct tipsmall *tipsmall; 

struct gassmall{
  int id; 
  float eu;
  float mass; 
  float fmassloss; 
};
struct gassmall *gassmall; 

struct grlist{
  int id;
};
struct grlist *grlist;

struct gord_dist{
  int id;  /*tipsy id */
  float dist[NGRP];
  float mass;
};
struct gord_dist *gord_dist; 

struct starorigin{
  int sid;
  int gtipid;
  int gordid; 
  float massform;
};

struct starorigin *starorigin; 

struct gasout{
  int iord;
  int id; 
  float eu;
  float mass;
  float fmassloss;
};
struct gasout *gasout; 

struct gout_dist{
  int iord;
  int id; 
  float dist;
  float mass; 
};
struct gout_dist *gout_dist; 

struct gassort{
  int id; 
  int sid; 
  float dist; 
  float eu;
  float mass;
};
struct gassort *gassort; 

struct gassort_metal{
  int id;  
  float dist; 
  float fe; 
  float oxy; 
  float mass;
  float temp; 
  float vx; 
  float vy; 
  float vz; 
};
struct gassort_metal *gassort_metal; 


struct gassort_large{
  int id; 
  int sid; 
  float dist; 
  float eu;
  float mass;
  float rho; 
  float temp;
  float metals; 
};
struct gassort_large *gassort_large; 

struct gassort1{
  int id; 
  int sid; 
  float dist; 
  float f1;
  float f2;
  float mass;
};
struct gassort1 *gassort1; 



struct starsmall{
  int id; 
  int grp; 
  float mass; 
  float metals; 
  // float cooltime; 
};

struct starsmall *starsmall; 


struct starlog{
  int iordstar; 
  int iordgas;
  double tform; 
  double x; 
  double y;
  double z; 
  double vx; 
  double vy;
  double vz; 
  double massform;
  double rhoform;
  double tempform; 
  // float cooltime; 
};

struct starlog *starlog; 

struct starout{
  int id; 
  float mass; 
  float oxy;
  float fe; 
  float tform;
  float x; 
  float y;
  float z; 
  float vx; 
  float vy;
  float vz; 
  float massg; 
  float rhog;
  float tempg;  
  float oxyg; 
  float feg; 
  float vxg; 
  float vyg; 
  float vzg;
};

struct starout *starout; 



struct gasid{
  int id; 
};

struct gasid *gasid; 
