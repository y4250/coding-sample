
%%Question4
clear all; close all; clc;
%(a)
% When g is very small, the slope log(1+g)=g, and this means the growth
% rate of GDP.
%(b)
k=.2; f=.2; g=.08;
x=rand(100,1); % 100 uniform random numbers in [0,1]
eps(x<=.5)=+k; % heads
eps(x>.5)=-f; % tails
% Plot:
t = [1:1:100];
log_Y = t*log(1+g) + log(1+eps);
fig3 = figure(3);
plot(t,log_Y,'b','LineWidth',2);
xlabel('$\log{Y_t}$');
xlabel('$t$');
grid on
set(gcf,'color','w');
exportgraphics(fig3,'fig3.pdf');
%(c)
f=f+.4; 
eps(x>.5)=-f;
% Plot:
log_Y_rec = t*log(1+g) + log(1+eps);
fig4 = figure(4);
plot(t,log_Y,'b','LineWidth',2);
hold on
plot(t,log_Y_rec,'r','linewidth',2);
xlabel('$\log{Y_t}$');
xlabel('$t$');
grid on
legend('Normal Recessions','Stronger Recessions','location','best');
set(gcf,'color','w');
exportgraphics(fig4,'fig4.pdf');
%(d)
g=.1;
f=.2; eps(x>.5)=-f;
% Plot:
log_Y_g = t*log(1+g) + log(1+eps);
fig5 = figure(5);
plot(t,log_Y,'b','LineWidth',2);
hold on
plot(t,log_Y_g,'r','linewidth',2);
xlabel('$\log{Y_t}$');
xlabel('$t$');
grid on
legend('Normal Growth Rate','Faster Growth Rate','location','best');
set(gcf,'color','w');
exportgraphics(fig5,'fig5.pdf');
%(e)
%If there was a recession in last period, we can flip the "recession" coin,
%which comes up a "recession" with probability 0.9.
e=NaN(1,100);
e(1)=eps(1);
for i=2:100
if e(i-1)==+k
e(x<=.9)=+k;
e(x>.9)=-f;
else
e(x<=.1)=+k;
e(x>.1)=-f;
end
end
g=.08;
log_Y_pers = t*log(1+g) + log(1+e);
fig6 = figure(6);
plot(t,log_Y,'b','LineWidth',2);
hold on
plot(t,log_Y_pers,'r','linewidth',2);
xlabel('$\log{Y_t}$');
xlabel('$t$');
grid on
legend('Normal Output','Persistent Output','location','best');
set(gcf,'color','w');
exportgraphics(fig6,'fig6.pdf');