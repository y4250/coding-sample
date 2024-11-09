%%% question3
clear all; close all; clc;
rgdp = readtable("GDPC1.csv");
inv = readtable("GCEC1.csv");

rgdp.Properties.VariableNames= {'date','rdgp'};
inv.Properties.VariableNames= {'date','inv'};

rgdp.date = datetime(rgdp.date);
inv.date = datetime(inv.date);

data = outerjoin(rgdp,inv,'LeftKeys','date','Rightkeys','date','mergekeys',true);
data = rmmissing(data); % remove rows with NaN
data.Properties.VariableNames = {'date', 'rgdp', 'inv'};

D=data; date = D.date; rgdp = D.rgdp; inv = D.inv; % variables

Y = [rgdp,inv];
log_rgdp = log(Y(:,1)); % take logs
log_inv = log(Y(:,2)); % take logs

set(0,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');

%Log rgdp
plot(date,log_rgdp,'b','LineWidth',2);
ylabel('Log Real GDP');
xlabel('$t$');
grid on
set(gcf,'color','w');


% Log inv
close all
plot(date,log_inv,'b','LineWidth',2);
ylabel('Log Consumption and Investment');
xlabel('$t$');
grid on
set(gcf,'color','w');

lambda = 1600;

[trend_rgdp,cycle_rgdp] = hpfilter(log_rgdp,lambda);
[trend_inv,cycle_inv] = hpfilter(log_inv,lambda);


%% part a
% time-series vs. trend:
% Log RGDP:
close all
plot(date,log_rgdp,'b','LineWidth',2);
hold on
plot(date,trend_rgdp,'r','LineWidth',2);
ylabel('Log Values');
xlabel('$t$');
grid on
set(gcf,'color','w');
legend('Log Real GDP','Trend','location','best');
%Detrend a time-series
rgdp_detrended = log_rgdp - trend_rgdp;
% Plot:
% Log rgdp
close all
plot(date,rgdp_detrended,'b','LineWidth',2);
ylabel('Detrended Log RGDP');
xlabel('$t$');
grid on
set(gcf,'color','w');


%% part b 
% Log C&I:
close all
plot(date,log_inv,'b','LineWidth',2);
hold on
plot(date,trend_inv,'r','LineWidth',2);
ylabel('Log Values');
xlabel('$t$');
grid on
set(gcf,'color','w');
legend('Log C&I','Trend','location','best');

% Detrend a time-series
inv_detrended = log_inv - trend_inv;

% Plot:
% Log rgdp
close all
plot(date,inv_detrended,'b','LineWidth',2);
ylabel('Detrended Log RGDP');
xlabel('$t$');
grid on
set(gcf,'color','w');

%% part c 
%plot detrends in same graph
close all
plot(date,inv_detrended,'b','LineWidth',2);
hold on
plot(date,rgdp_detrended,'r','LineWidth',2);
ylabel('Detrended Log');
xlabel('$t$');
grid on
set(gcf,'color','w');

%% part d

corr_detrended = corr(rgdp_detrended,inv_detrended)
%precorr
inv_detrended(220)=[];
rgdp_detrended(1,:)=[];
corr_detrendedpre = corr(rgdp_detrended,inv_detrended)

% renew the data
rgdp_detrended = log_rgdp - trend_rgdp;
inv_detrended = log_inv - trend_inv;
%laycoor
rgdp_detrended(220)=[];
inv_detrended(1,:)=[];
corr_detrendedprelag = corr(rgdp_detrended,inv_detrended)

%since | -0.2175|>|-0.1873|, this is a leading variable.

%% part e
rgdp_detrended = log_rgdp - trend_rgdp;
inv_detrended = log_inv - trend_inv;
% Log :
rgdp_detrended_std = std(rgdp_detrended);

% Log employment:
inv_detrended_std = std(inv_detrended);

% Ratio:
ratio = inv_detrended_std/rgdp_detrended_std




