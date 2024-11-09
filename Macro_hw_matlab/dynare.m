%part a
clear all; close all; clc;
global phi alpha delta rho beta
phi = 0.7;
alpha = 0.32;
delta = 0.025;
rho = 0.95;
beta = 0.9;
save('param.mat','phi','alpha','delta','rho','beta');
dynare HW3.mod
load('simulation .mat')
fig1 = figure(1);
plot (100*oo_.irfs.y_eps_z)
title('y% change from SS in a')
exportgraphics(fig1,'fig1.pdf');
fig2 = figure(2);
plot (100*oo_.irfs.I_eps_z)
title('I% change from SS in a')
exportgraphics(fig2,'fig2.pdf');
fig3 = figure(3);
plot (100*oo_.irfs.c_eps_z)
title('c% change from SS in a')
exportgraphics(fig3,'fig3.pdf');
fig4 = figure(4);
plot (100*oo_.irfs.l_eps_z)
title('z% change from SS in a')
exportgraphics(fig4,'fig4.pdf');
fig5 = figure(5);
plot (100*oo_.irfs.k_eps_z)
title('k% change from SS in a')
exportgraphics(fig5,'fig5.pdf');
fig6 = figure(6);
plot (100*oo_.irfs.w_eps_z)
title('w% change from SS in a')
exportgraphics(fig6,'fig6.pdf');
fig7 = figure(7);
plot (100*oo_.irfs.r_eps_z)
title('r% change from SS in a')
exportgraphics(fig7,'fig7.pdf');

%part bi
global phi alpha delta rho beta
phi = 0.3;
alpha = 0.32;
delta = 0.025;
rho = 0.95;
beta = 0.9;
save('param.mat','phi','alpha','delta','rho','beta');
dynare HW3.mod
load('simulation .mat')
fig8 = figure(8);
plot (100*oo_.irfs.y_eps_z)
title('y% change from SS in bi')
exportgraphics(fig8,'fig8.pdf');
fig9 = figure(9);
plot (100*oo_.irfs.I_eps_z)
title('I% change from SS in bi')
exportgraphics(fig9,'fig9.pdf');
fig10 = figure(10);
plot (100*oo_.irfs.c_eps_z)
title('c% change from SS in bi')
exportgraphics(fig10,'fig10.pdf');
fig11 = figure(11);
plot (100*oo_.irfs.l_eps_z)
title('l% change from SS in bi')
exportgraphics(fig11,'fig11.pdf');
fig12 = figure(12);
plot (100*oo_.irfs.k_eps_z)
title('k% change from SS in bi')
exportgraphics(fig12,'fig12.pdf');
fig13 = figure(13);
plot (100*oo_.irfs.w_eps_z)
title('w% change from SS in bi')
exportgraphics(fig13,'fig13.pdf');
fig14 = figure(14);
plot (100*oo_.irfs.r_eps_z)
title('r% change from SS in bi')
exportgraphics(fig14,'fig14.pdf');

%part bii
global phi alpha delta rho beta
phi = 0.7;
alpha = 0.32;
delta = 0.025;
rho = 0;
beta = 0.9;
save('param.mat','phi','alpha','delta','rho','beta');
dynare HW3.mod
load('simulation .mat')
fig15 = figure(15);
plot (100*oo_.irfs.y_eps_z)
title('y% change from SS in bii')
exportgraphics(fig15,'fig15.pdf');
fig16 = figure(16);
plot (100*oo_.irfs.I_eps_z)
title('I% change from SS in bii')
exportgraphics(fig16,'fig16.pdf');
fig17 = figure(17);
plot (100*oo_.irfs.c_eps_z)
title('c% change from SS in bii')
exportgraphics(fig17,'fig17.pdf');
fig18 = figure(18);
plot (100*oo_.irfs.l_eps_z)
title('l% change from SS in bii')
exportgraphics(fig18,'fig18.pdf');
fig19 = figure(19);
plot (100*oo_.irfs.k_eps_z)
title('k% change from SS in bii')
exportgraphics(fig19,'fig19.pdf');
fig20 = figure(20);
plot (100*oo_.irfs.w_eps_z)
title('w% change from SS in bii')
exportgraphics(fig20,'fig20.pdf');
fig21 = figure(21);
plot (100*oo_.irfs.r_eps_z)
title('r% change from SS in bii')
exportgraphics(fig21,'fig21.pdf');

%part biii
global phi alpha delta rho beta
phi = 0.7;
alpha = 0.32;
delta = 0.025;
rho = 0.95;
beta = 0.5;
save('param.mat','phi','alpha','delta','rho','beta');
dynare HW3.mod
load('simulation .mat')
fig22 = figure(22);
plot (100*oo_.irfs.y_eps_z)
title('y% change from SS in biii')
exportgraphics(fig22,'fig22.pdf');
fig23 = figure(23);
plot (100*oo_.irfs.I_eps_z)
title('I% change from SS in biii')
exportgraphics(fig23,'fig23.pdf');
fig24 = figure(24);
plot (100*oo_.irfs.c_eps_z)
title('c% change from SS in biii')
exportgraphics(fig24,'fig24.pdf');
fig25 = figure(25);
plot (100*oo_.irfs.l_eps_z)
title('l% change from SS in biii')
exportgraphics(fig25,'fig25.pdf');
fig26 = figure(26);
plot (100*oo_.irfs.k_eps_z)
title('k% change from SS in biii')
exportgraphics(fig26,'fig26.pdf');
fig27 = figure(27);
plot (100*oo_.irfs.w_eps_z)
title('w% change from SS in biii')
exportgraphics(fig27,'fig27.pdf');
fig28 = figure(28);
plot (100*oo_.irfs.r_eps_z)
title('r% change from SS in biii')
exportgraphics(fig28,'fig28.pdf');