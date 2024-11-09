clear all; close all; clc;
infrate = readtable("Book2.csv");
moneyrate = readtable("Book3.csv");

infrate.Properties.VariableNames= {'date','infreta'};
moneyrate.Properties.VariableNames= {'date','moneyrate'};

infrate.date = datetime(infrate.date);
moneyrate.date = datetime(moneyrate.date);

data = outerjoin(infrate,moneyrate,'LeftKeys','date','Rightkeys','date','mergekeys',true);
data = rmmissing(data); % remove rows with NaN
data.Properties.VariableNames = {'date', 'infrate', 'moneyrate'};

D=data; date = D.date; infrate = D.infrate; moneyrate = D.moneyrate; % variables

set(0,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');

lambda = 14400;
[trend_infrate,cycle_infrate] = hpfilter(infrate,lambda);
[trend_moneyrate,cycle_moneyrate] = hpfilter(moneyrate,lambda);
%%plot
close all
plot(date,infrate,'b','LineWidth',2);
hold on
plot(date,moneyrate,'r','LineWidth',2);
ylabel('rate');
xlabel('$t$');
grid on
set(gcf,'color','w');
legend('Inflation rate','money increase rate','location','best');
saveas(gcf, '2line.png');

saveas(gcf, '2line.jpg', 'jpeg');


saveas(gcf, '2line.pdf', 'pdf');



%%plot
close all;
plot(date, infrate, 'LineWidth', 2); 
title('Four Curves');
xlabel('data-axis');
ylabel('rate-axis');
hold on; 

plot(date, trend_infrate, 'LineWidth', 2);

plot(date, moneyrate, 'b','LineWidth', 2);
plot(date, trend_moneyrate,'r', 'LineWidth', 2);


legend('INF rate', 'INF trend', 'M2rate', 'M2trend');

hold off; 
saveas(gcf, '4line.png');

saveas(gcf, '4line.jpg', 'jpeg');


saveas(gcf, '4line.pdf', 'pdf');

correlationoftrend = corr(trend_infrate,trend_moneyrate)